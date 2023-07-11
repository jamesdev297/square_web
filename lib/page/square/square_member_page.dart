import 'dart:async';

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
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/sliver_list_with_searchbar.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';
import 'package:square_web/widget/toggle_widget.dart';

class SquareMemberPage extends StatefulWidget with HomeWidget {
  final SquareModel _model;
  final String channel;
  final PreloadPageController? pageController;
  final ValueNotifier<String?>? playerProfilePagePlayerId;
  final HomeWidget rootWidget;

  @override
  String pageName() => "SquareMemberPage";

  SquareMemberPage(this._model, this.channel, this.rootWidget, {this.pageController, this.playerProfilePagePlayerId});

  @override
  State<StatefulWidget> createState() => _SquareMemberPageState();

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

class _SquareMemberPageState extends State<SquareMemberPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  TextEditingDefault _searchTextEdit = TextEditingDefault();
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

    Timer? searchTimer;
    String beforeText = "";
    _searchTextEdit.init("squareMembers", this, onChanged: (text) {
      if (!(_bloc.state is OnSearchingSquareMembers)) _bloc.add(SearchStart());
      if (beforeText.trim() != text.trim() && text.trim().isNotEmpty) {
        beforeText = text;
        searchTimer?.cancel();
        searchTimer =
            Timer(Duration(milliseconds: searchLoadingMilliseconds), () => _bloc.add(SearchSquareMembersEvent(text)));
      } else if (text.trim().isEmpty) {
        searchTimer?.cancel();
        beforeText = "";
        _bloc.add(FetchSquareMembersEvent());
      }
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: Zeplin.size(110)),
        child: SliverListWithSearchBar(
            headerSize: 0,
            searchBarSize: Zeplin.size(110),
            focusNode: _focusNode,
            textEditDefault: _searchTextEdit,
            searchBarHintText: L10n.search_hint_01_square_member_page,
            onBottom: () {
              if (_searchTextEdit.isComposing)
                _bloc.add(SearchSquareMembersEvent(_searchTextEdit.text, isScroll: true));
              else
                _bloc.add(FetchSquareMembersEvent(isScroll: true));
            },
            slivers: [
              SliverToBoxAdapter(
                  child: BlocBuilder(
                      bloc: _bloc,
                      builder: (context, state) {
                        if (state is SquareMembersLoaded) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                            child: Row(
                              children: [
                                Text(L10n.square_01_13_member_count),
                                SizedBox(width: Zeplin.size(10)),
                                Text("${state.members.length ?? 0}"),
                                Spacer(),
                                if ((state.members.length ?? 0) > 0)
                                  ToggleWidget(
                                    initialLabel: _toggleSelectIndex,
                                    activeBgColor: CustomColor.azureBlue,
                                    activeTextColor: CustomColor.azureBlue,
                                    inactiveBgColor: CustomColor.paleGrey,
                                    inactiveTextColor: CustomColor.blueyGrey,
                                    labels: _toggleList,
                                    onToggle: (index) {
                                      _toggleSelectIndex = index;
                                      closeInputField();
                                      setState(() {});
                                      _bloc.add(ChangeSquareMembersOrderTypeEvent(
                                          _toggleSelectIndex == 0 ? OrderType.name : OrderType.online));
                                    },
                                  ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      })),
              BlocBuilder<SquareMembersBloc, SquareMembersBlocState>(
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
                      } else if (state is SquareMembersSearched && state.nextCursor != null && items.length < 10) {
                        LogWidget.debug("item count : ${items.length}");
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          _bloc.add(SearchSquareMembersEvent(_searchTextEdit.text, isScroll: true));
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

                    return SliverList(delegate: childBuilder);
                  }),
            ]),
      ),
      bottomNavigationBar: isShowButton
          ? Container(
              color: Colors.white,
              height: Zeplin.size(150),
              width: DeviceUtil.screenWidth,
              padding: EdgeInsets.symmetric(vertical: Zeplin.size(30), horizontal: Zeplin.size(34)),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: CustomColor.paleGrey,
                    primary: CustomColor.darkGrey,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  CopyUtil.copyText(DeepLinkManager.getSquareLink(widget._model.chainNetType, widget._model.contractAddress, widget._model.squareId), () {
                    ToastOverlay.show(
                        buildContext: context, text: L10n.square_01_10_url_copied, rootWidget: widget.rootWidget);
                  });
                },
                child: Text(
                  L10n.square_01_09_url_copy,
                  style: TextStyle(color: Colors.black, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500),
                ),
              ),
            )
          : null,
    );
  }

  void closeInputField() {
    if (_focusNode.hasFocus) _focusNode.unfocus();
    _searchTextEdit.resultText = "";
    _searchTextEdit.resetOnSubmit("");
  }
}
