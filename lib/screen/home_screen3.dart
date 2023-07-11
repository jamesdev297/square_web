import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/tab/home_tab_navigator.dart';
import 'package:square_web/home/navigator/tab/home_tab_navigator_route.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/contact/contact_page_home.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/page/more/more_page_home.dart';
import 'package:square_web/page/more/player_profile_page.dart';
import 'package:square_web/page/room/rooms_home.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/service/transition_manager.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/square/square_dialog.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

class HomeScreen3 extends StatefulWidget {
  final Key? key;

  HomeScreen3({this.key}) : super(key: key);

  @override
  State createState() => HomeScreen3State();
}

class HomeScreen3State extends State<HomeScreen3> with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<NavigatorState> homeScreenNavigatorKey = GlobalKey<NavigatorState>();

  bool canCloseApp = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool hasPaused = false;
  StreamController buildStream = StreamController.broadcast();

  late List<HomeNavigatorTab> homeTabs;

  @override
  void initState() {
    LogWidget.debug("homeScreen3 init!");

    WidgetsBinding.instance.addObserver(this);
    TransitionManager().registerTickerProvider(this);

    ContactManager().init();
    RoomManager().init();
    SquareManager().init();

    Future.wait([
      BlocManager().initHomeScreenBlocs(),
      RoomManager().getUnreadRoom(),
    ]).whenComplete(_initCont);

    homeTabs = [
      HomeNavigatorTab(
        rootHomeWidget: RoomsHome(),
        twoDepthWidget: EmptyExpandTwoDepthWidget(),
        icon: tabIconManager.callOnOff(false, TabCode.chat),
        selectedIcon: tabIconManager.callOnOff(true, TabCode.chat),
        tabText: L10n.chat_01_01_chat,
        tabCode: TabCode.chat),
      HomeNavigatorTab(
          rootHomeWidget: SquareListPageHome(),
          twoDepthWidget: EmptyTwoDepthWidget(),
          icon: tabIconManager.callOnOff(false, TabCode.square),
          selectedIcon: tabIconManager.callOnOff(true, TabCode.square),
          tabText: L10n.square_01_01_square,
          tabCode: TabCode.square),
      HomeNavigatorTab(
        rootHomeWidget: ContactPageHome(),
        twoDepthWidget: EmptyProfilePage(),
        icon: tabIconManager.callOnOff(false, TabCode.contacts),
        selectedIcon: tabIconManager.callOnOff(true, TabCode.contacts),
        tabText: L10n.contacts_01_01_contacts,
        tabCode: TabCode.contacts),
      HomeNavigatorTab(
        rootHomeWidget: MorePageHome(),
        twoDepthWidget: EmptyExpandTwoDepthWidget(),
        icon: tabIconManager.callOnOff(false, TabCode.more),
        selectedIcon: tabIconManager.callOnOff(true, TabCode.more),
        tabText: L10n.my_01_01_more,
        tabCode: TabCode.more),
    ];

    FullScreenSpinner.hide();

    window.onMessage.listen((onData) {
      if(onData.data == "termsOfUse") {
        HomeNavigator.push(RoutePaths.profile.termsOfService);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabIconManager.precache(context);
    super.didChangeDependencies();
  }

  void _initCont() async {
    _setDeepLinkCallback();
  }

  void _setDeepLinkCallback() async {
    DeepLinkManager().addHomeScreenCallbacks({
      linkChatKey : (param) {
        if(walletAddressRegExp.hasMatch(param)) {
          // RoomManager().goRoomByLink(targetWallet);
        }
      },
      linkSquareKey : (param) async {
        FullScreenSpinner.show(context);
       /* GetSquareForLinkCommand command = GetSquareForLinkCommand(squareId: param);

        if(await DataService().request(command)) {
          HomeNavigator.moveToTab(TabCode.square);
          if(command.squareModel != null) {
            if(command.squareModel?.joined == true || command.squareModel?.squareType == SquareType.token || command.squareModel?.squareType == SquareType.user) {
              HomeNavigator.push(RoutePaths.square.squareChat, arguments: command.squareModel, moveTab: TabCode.square);
            }else{
              SquareDialog.show(square: command.squareModel!, joined: command.squareModel!.squareType == SquareType.nft ? (command.squareModel?.joined ?? false) : true);
            }
          }
        }
        FullScreenSpinner.hide();*/
      },
      verifyEmailKey : (param) async {
      }
    });
  }

  Timer? closeNoticeTimer;
  void handleWillPop(BuildContext context) {
    if (closeNoticeTimer?.isActive == true) {
      closeNoticeTimer?.cancel();
      closeNoticeTimer = null;
    }

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          LogWidget.debug("closeNoticeTimer = ${closeNoticeTimer?.isActive}");
          if (closeNoticeTimer?.isActive != true)
            closeNoticeTimer =
                Timer(Duration(seconds: 2), () => Navigator.of(context).pop());

          return WillPopScope(
            onWillPop: () async {
              closeNoticeTimer?.cancel();
              SystemNavigator.pop();
              return false;
            },
            child: GestureDetector(
              onTapDown: (details) {
                closeNoticeTimer?.cancel();
                Navigator.of(context).pop();
              },
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Text(
                          L10n.common_47_close,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LogWidget.debug("home screen dispose. bye~");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LogWidget.debug("homeScreen3 rebuild");

    return WillPopScope(
      onWillPop: () async {
        bool canPop = await HomeNavigator.pop(value: true, ignoreOneDepth: true);
        LogWidget.debug("PopCalled!! $canPop");

        if (canPop == false) {
          handleWillPop(context);
        }
        return false;
      },
      child: HomeNavigator(
        homeScreenNavigatorKey,
        underNavigatorWidgets: [],
        overNavigatorWidgets: [
        ],
        homeTabNavigators: homeTabs,
      ),
    );
  }
}
