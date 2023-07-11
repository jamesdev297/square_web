import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/bloc/square/square_bloc.dart';
import 'package:square_web/bloc/square/square_members_bloc.dart';
import 'package:square_web/bloc/profile/square_profile_bloc.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_member_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/share_link_square.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/profile/square_profile_image.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';


class AiSquareProfilePage extends StatefulWidget with HomeWidget {
  final SquareModel squareModel;
  final String channel;
  final PreloadPageController? pageController;
  final HomeWidget rootWidget;
  final ValueNotifier<String?>? playerProfilePagePlayerId;


  @override
  String pageName() => "AiSquareProfilePage";

  // final bool isDimmedBackground;
  AiSquareProfilePage(this.squareModel, this.channel, this.rootWidget, {Key? key, this.pageController, this.playerProfilePagePlayerId}):super(key: key);

  @override
  State<StatefulWidget> createState() => _AiSquareProfilePageState();

  @override
  MenuPack get getMenuPack => MenuPack(
      padding: EdgeInsets.only(top: Zeplin.size(36)),
      rightFullMenu: Builder(
          builder: (context) {
            return Row(
              children: [
                Spacer(),
                ShareLinkSquare(squareId: squareModel.squareId, contractAddress: squareModel.contractAddress, chainNetType: squareModel.chainNetType, rootWidget: rootWidget),
                SizedBox(width: Zeplin.size(30)),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      ContactManager().selectedContactBloc.add(Update());
                      HomeNavigator.clearTwoDepthPopUp();
                    },
                    child: Icon46(Assets.img.ico_46_x_bk),
                  ),
                ),
              ],
            );
          }
      )
  );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.squareProfilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;

  @override
  bool get slideShowUpInMobile => true;

}

class _AiSquareProfilePageState extends State<AiSquareProfilePage> with TickerProviderStateMixin {
  late SquareProfileBloc squareProfileBloc;
  bool isMe = false;
  late SquareModel? _squareModel;
  late SquareMembersBloc squareMembersBloc = SquareMembersBloc(widget.squareModel, OrderType.name)..add(FetchSquareMembersEvent());
  TextStyle squareIdTextStyle = TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500);
  SquareBloc? squareBloc;
  ValueNotifier<ChainNetType> selectedChainNetType = MeModel().selectedChainNetType;
  ChainNetType? lastSelectedChainNetType;
  late ScrollDefault scrollDefault = ScrollDefault();
  bool lastStatus = true;
  double height = Zeplin.size(300);
  Timer? retryTimer;
  ValueNotifier<double> scrollOffsetNotifier = ValueNotifier(0);

  double _initialLoadedSize = 0;
  int _lastLoadTime = 0;
  double initialScrollOffset = 0;

  void _scrollListener() {
    scrollOffsetNotifier.value = scrollDefault.controller.offset;
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return scrollDefault.controller.hasClients && scrollDefault.controller.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    squareProfileBloc = SquareProfileBloc(widget.squareModel)..add(FetchSquareProfileEvent(squareId: widget.squareModel.squareId));
    FocusManager.instance.primaryFocus?.unfocus();

    scrollDefault.init();
    scrollDefault.controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    scrollDefault.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMe == true) {
      return _buildProfile();
    }

    return BlocBuilder<SquareProfileBloc, SquareProfileState>(
      bloc: squareProfileBloc,
      builder: (context, state) {
        if (state is PlayerProfileUninitialized) {
          return Scaffold(body: SquareCircularProgressIndicator());
        }

        if (state is SquareProfileLoaded) {
          _squareModel = state.squareModel;
          return _buildProfile();
        }
        return Container();
      },
    );
  }

  Widget _buildPlayerProfile() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => HomeNavigator.push(RoutePaths.common.fullImageView, arguments: { "imageUrl": widget.squareModel.squareImgUrl }),
        child: SquareProfileImage(squareImgUrl: widget.squareModel.squareImgUrl, size: _isShrink ? 60 : 100)
      )
    );
  }

  Widget _buildProfile() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: scrollDefault.controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: height,
              floating: false,
              pinned: true,
              elevation: 1,
              title: ValueListenableBuilder<double>(
                valueListenable: scrollOffsetNotifier,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: Zeplin.size(15)),
                      Text(L10n.profile_square_top, style: TextStyle(fontSize: Zeplin.size(32), fontWeight: FontWeight.w500, color: Colors.black.withOpacity(max(0, 1.0 - value/30)))),
                    ],
                  );
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(vertical: Zeplin.size(20)),
                centerTitle: true,
                title: _buildPlayerProfile(),
              ),
            ),
          ];
        },
        body: NotificationListener<ScrollUpdateNotification>(
          onNotification: (evt) {
            double _listGap = evt.metrics.maxScrollExtent - evt.metrics.pixels;

            if (_initialLoadedSize == 0) {
              _initialLoadedSize = _listGap;
            }
            //LogWidget.debug("_listPixelSize : ${_listGap}, ${_initialLoadedSize/3}, ${_initialLoadedSize}");
            if (evt.metrics.pixels >= evt.metrics.maxScrollExtent &&
                !evt.metrics.outOfRange) {
              squareBloc?.add(LoadSquare());
            } else if (_listGap < _initialLoadedSize / 3) {
              if (_lastLoadTime + 50 > DateTime
                  .now()
                  .millisecondsSinceEpoch) {
                return false;
              }
              squareBloc?.add(LoadSquare());

              _lastLoadTime = DateTime
                  .now()
                  .millisecondsSinceEpoch;
            }
            return true;
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: Zeplin.size(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.squareModel.name, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: Zeplin.size(30)),
              Center(child: SizedBox(
                  width: Zeplin.size(550),
                  child: Text((_squareModel?.description ?? ""), textAlign: TextAlign.center, style: TextStyle(height: 1.4, color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))))),
              SizedBox(height: Zeplin.size(49)),
              Divider(thickness: Zeplin.size(20), color: CustomColor.paleGrey),
              SizedBox(height: Zeplin.size(28)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Zeplin.size(42)),
                child: Text(L10n.profile_square_ai_member, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(27), fontWeight: FontWeight.w700)),
              ),
              SizedBox(height: Zeplin.size(28)),
              _buildAiMembers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiMembers() {
    return BlocBuilder<SquareMembersBloc, SquareMembersBlocState>(
        bloc: squareMembersBloc,
        builder: (context, state) {
          List<Widget> items = [];
          SliverChildBuilderDelegate childBuilder;
          if (state is SquareMembersUninitialized) {
            childBuilder = SliverChildBuilderDelegate(
                    (context, index) => Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: Zeplin.size(70)),
                      child:
                      SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80),
                    )),
                childCount: 1);
          } else if (state is SquareMembersLoaded) {
            List<SquareMember> members = state.members;
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
            )).toList();
            childBuilder = SliverChildBuilderDelegate((context, index) {
              return items[index];
            }, childCount: items.length);
          } else {
            childBuilder = SliverChildBuilderDelegate((context, index) => Container());
          }
          // LogWidget.debug("------scroll ${_scrollController.position.maxScrollExtent} / ${PageSize.profilePageHeight} ------");

          return CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverList(delegate: childBuilder)
            ],
          );
        });
  }


}


