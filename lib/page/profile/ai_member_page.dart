import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/bloc/square/square_members_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_member_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class AiMemberPage extends StatefulWidget with HomeWidget {
  final SquareModel _model;
  final String channel;
  final PreloadPageController? pageController;
  final ValueNotifier<String?>? playerProfilePagePlayerId;
  final HomeWidget rootWidget;

  @override
  String pageName() => "AiMemberPage";

  AiMemberPage(this._model, this.channel, this.rootWidget, {this.pageController, this.playerProfilePagePlayerId});

  @override
  State<StatefulWidget> createState() => _AiMemberPageState();

  @override
  MenuPack get getMenuPack => MenuPack(
      padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)),
      title: Text(L10n.square_01_03_participating_member,
          style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
      rightMenu: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            HomeNavigator.clearTwoDepthPopUp();
          },
          child: Icon46(Assets.img.ico_46_x_bk),
        ),
      ));

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.only(top: Zeplin.size(54, isPcSize: true), left: Zeplin.size(20));
}

class _AiMemberPageState extends State<AiMemberPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  FocusNode _focusNode = FocusNode();

  late SquareMembersBloc _bloc;
  final copiedTooltipKey = GlobalKey();
  final List<String> _toggleList = [L10n.contacts_01_04_abc, L10n.contacts_01_05_online];
  int _toggleSelectIndex = 0;

  bool isShowButton = true;
  bool showHeader = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = SquareMembersBloc(widget._model, OrderType.name)..add(FetchSquareMembersEvent());
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
      isShowButton = false;
    } else {
      isShowButton = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Zeplin.size(110)),
      child: BlocBuilder<SquareMembersBloc, SquareMembersBlocState>(
          bloc: _bloc,
          builder: (context, state) {
            List<Widget> items = [];
            SliverChildBuilderDelegate childBuilder;
            if (state is SquareMembersUninitialized || state is OnSearchingSquareMembers) {
              childBuilder = SliverChildBuilderDelegate(
                      (context, index) => Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: Zeplin.size(70)),
                        child:
                        SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80),
                      )),
                  childCount: 1);
            } else if (state is SquareMembersLoaded || state is SquareMembersSearched) {
              List<SquareMember> members =
              state is SquareMembersSearched ? state.members : (state as SquareMembersLoaded).members;
              int count = 1;
              items = members
                  .map((e) => Container(
                child: ContactItem(
                  contactModel: e,
                  squareMemberStatus: e.memberStatus,
                  onTap: () {
                    widget.pageController?.animateToPage(1,
                        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                    widget.playerProfilePagePlayerId?.value = e.playerId;
                    // HomeNavigator.push(RoutePaths.profile.player, arguments: e.playerId, addedPadding: EdgeInsets.symmetric(vertical: Zeplin.size(84)));
                    setState(() {
                      ContactManager().selectedContactBloc.add(Update(param: e.playerId));
                    });
                  },
                ),
              ))
                  .toList();
              LogWidget.debug("state === $state && joined = ${widget._model.joined}");
              if (state is SquareMembersLoaded && (widget._model.joined ?? false)) {
                items = [
                  Container(
                      child: ContactItem(
                          contactModel: MeModel().contact!,
                          squareMemberStatus: MeModel().isRestrictedOnSquare ? MemberStatus.restricted : null,
                          onTap: () {
                            widget.pageController?.animateToPage(1,
                                duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                            widget.playerProfilePagePlayerId?.value = MeModel().playerId;
                            // HomeNavigator.push(RoutePaths.profile.player, arguments: e.playerId, addedPadding: EdgeInsets.symmetric(vertical: Zeplin.size(84)));
                            setState(() {
                              ContactManager().selectedContactBloc.add(Update(param: MeModel().playerId));
                            });
                          }))
                ]..addAll(items);
              }
              if (state is SquareMembersLoaded && state.nextCursor != null && items.length < 10) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _bloc.add(FetchSquareMembersEvent(isScroll: true));
                });
                items.add(Container(
                    padding: EdgeInsets.only(top: Zeplin.size(50)),
                    child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)));
              } else if (items.isEmpty) {
                items = [
                  Container(
                      height: Zeplin.size(120),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        L10n.square_01_15_no_matches_found,
                        style: TextStyle(
                            color: CustomColor.paleGreyDarkL,
                            fontSize: Zeplin.size(26),
                            fontFamily: Zeplin.robotoMedium),
                      ))
                ];
              }

              childBuilder = SliverChildBuilderDelegate((context, index) {
                return items[index];
              }, childCount: items.length);
            } else {
              childBuilder = SliverChildBuilderDelegate((context, index) => Container());
            }
            // LogWidget.debug("------scroll ${_scrollController.position.maxScrollExtent} / ${PageSize.profilePageHeight} ------");

            return CustomScrollView(
              slivers: [
                SliverList(delegate: childBuilder)
              ],
            );
          }),
    );
  }

}
