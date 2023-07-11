import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/common/route/slide_route.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/home/navigator/tab/home_tab_navigator.dart';
import 'package:square_web/home/navigator/tab/home_tab_navigator_route.dart';
import 'package:square_web/home/navigator/two_depth_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/transition_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/square_navigation_bar.dart';

part 'part/home_widget.dart';

typedef void PopActionCallback(Object? value);
typedef void PushPopCallBack(String? path, HomeWidget? widget, bool isPush);
typedef void NavigationProcess(Uri uri, Object arguments);

ValueNotifier<double> screenWidthNotifier = ValueNotifier(0);

class HomeNaviObserver extends NavigatorObserver {
  final PushPopCallBack pushPopCallback;

  HomeNaviObserver({required this.pushPopCallback});

  @override
  void didPop(Route route, Route? previousRoute) {
    LogWidget.info("pop!!!!! $route / $previousRoute");
    pushPopCallback.call(previousRoute!.settings.name,
        previousRoute.settings.arguments as HomeWidget?, false);

    return;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    LogWidget.info("push!!!!! $route / $previousRoute");
    if (!(route.settings.name == "/" && previousRoute == null))
      pushPopCallback.call(
          route.settings.name, route.settings.arguments as HomeWidget?, true);

    return;
  }
}

typedef void OnChangedCallback(int index);

class HomeNavigator extends StatefulWidget {
  static HomeNavigator? _instance;

  static bool get isInit => _instance != null;

  static ValueNotifier<TabCode> currentTab = ValueNotifier(TabCode.square);

  // static HomeTabBloc _tabChangedBloc = HomeTabBloc(TabCode.chat);

  // static HomeTabBloc get tabChangedBloc => _tabChangedBloc;

  // static TabCode get currentTab => _tabChangedBloc.state;

  static HomeNavigatorTab? get currentTabNavigator =>
      _instance?._currentTabNavigator;


  static HomeNaviObserver? get observer => _instance?._homeNaviObserver?.call();

  static void moveToTab(TabCode tabCode) {
    int? index = _instance?.navigatorWithNaviCode[tabCode]!.key;
    if (index == null || index < 0 || index == _instance?.navigatorWithNaviCode[currentTab.value]!.key) return;

    homeNaviStateKey.currentState?.tabController.index = index;
    homeNaviStateKey.currentState?.clearAllStack(index);

    homeNaviStateKey.currentState?._onTapTab(index, moveWithTabBar: true);
  }

  GlobalKey<NavigatorState> homeScreenNavigatorKey;
  static final GlobalKey<HomeNavigatorState> homeNaviStateKey = GlobalKey();
  final List<Widget> underNavigatorWidgets = [];
  final List<HomeNavigatorTab> homeTabs = [];
  final List<Widget> overNavigatorWidgets = [];
  StreamController<HomeWidget> popStreamController = StreamController.broadcast();
  static StreamController<HomeWidget>? get popHomeWidgetStreamController => _instance?.popStreamController;

  HomeNavigatorTab get _currentTabNavigator =>
      navigatorWithNaviCode[currentTab.value]!.value;

  static int? get currentTabIndex => _instance?.navigatorWithNaviCode[currentTab.value]!.key;

  static HomeWidget? getPeekTwoDepthPopUp() {
    if(homeNaviStateKey.currentState != null) {
      if(homeNaviStateKey.currentState!.twoDepthPopUpWidgetList.length > 0) {
        return homeNaviStateKey.currentState!.twoDepthPopUpWidgetList.last;
      }
    }
    return null;
  }

  final Map<TabCode, MapEntry<int, HomeNavigatorTab>> navigatorWithNaviCode =
      {};

  HomeNaviObserver Function()? _homeNaviObserver;

  HomeNavigator(this.homeScreenNavigatorKey,
      {List<Widget>? underNavigatorWidgets,
      List<HomeNavigatorTab>? homeTabNavigators,
      List<Widget>? overNavigatorWidgets,
      })
      : super(key: homeNaviStateKey) {
    _instance = this;

    if (underNavigatorWidgets != null)
      this.underNavigatorWidgets.addAll(underNavigatorWidgets);
    if (homeTabNavigators != null) this.homeTabs.addAll(homeTabNavigators);
    if (overNavigatorWidgets != null)
      this.overNavigatorWidgets.addAll(overNavigatorWidgets);

    for (int index = 0; index < this.homeTabs.length; index++)
      this.navigatorWithNaviCode[this.homeTabs[index].tabCode] =
          MapEntry(index, this.homeTabs[index]);

  }

  static Future<bool> pop({dynamic value, HomeWidget? targetPage, bool ignoreOneDepth = false}) async {
    if(ignoreOneDepth) {
      if(homeNaviStateKey.currentState != null && homeNaviStateKey.currentState!.widgetStack.length == 1) {
        if(homeNaviStateKey.currentState?.widgetStack.last.widgetType == HomeWidgetType.oneDepth) {
          return false;
        }
      }
    }
    return homeNaviStateKey.currentState
            ?.popWidget(value: value, homeWidget: targetPage) ??
        false;
  }

  static Future<bool> popTwoDepth({dynamic value}) async {
    return homeNaviStateKey.currentState?.popTwoDepthWidget(value: value) ?? false;
  }

  static void clearTwoDepthPopUp() {
    homeNaviStateKey.currentState?.clearTwoDepthPopUp();
  }

  static bool isStackedTwoDepthPopUp() {
    return (homeNaviStateKey.currentState?.twoDepthPopUpWidgetList.length ?? 0) > 1;
  }

  static void popUntilMain() {
    // homeNaviStateKey.currentState?._onTapTab(currentTab.value.index);
    // homeNaviStateKey.currentState?.popWidget(untilTapRoot: true);
  }

  static void expandOneDepth(bool expand) {
    if(expand) {
      if(homeNaviStateKey.currentState?.twoDepthWidget?.isEmptyPage == false) {
        homeNaviStateKey.currentState?.prevTwoDepthWidget = homeNaviStateKey.currentState?.twoDepthWidget;
      }
      homeNaviStateKey.currentState?.pushWidget(EmptyTwoDepthWidget());
    } else {
      if(homeNaviStateKey.currentState?.prevTwoDepthWidget != null) {
        homeNaviStateKey.currentState?.pushWidget(homeNaviStateKey.currentState!.prevTwoDepthWidget!);
      } else {
        popTwoDepth();
      }
      clearTwoDepthPopUp();
    }
  }

  static void initCurrentTab() {
    homeNaviStateKey.currentState?.initCurrentTab();
  }

  static void clearWillbeClosedTwoDepthWidget() {
    homeNaviStateKey.currentState?.willBeClosedTwoDepthWidget = null;
    homeNaviStateKey.currentState?.setState(() {

    });
  }

  static void tapOutSideOfTwoDepthPopUp() {
    homeNaviStateKey.currentState?.tabOutsideOfTwoDepthPopUp();
  }

  static Future<void> push(String path,
      {PopActionCallback? popAction,
      SlideRouteDirection? slideDirection,
      bool doPopUntilMain = false,
      TabCode? moveTab,
      bool popBefore = false,
      Object? arguments,
      EdgeInsetsGeometry? addedPadding}) async {
    LogWidget.debug(
        "pushed $path, instance: $_instance, key: ${_instance?.homeScreenNavigatorKey} " +
            "currentState: ${_instance?.homeScreenNavigatorKey.currentState}");
    if (doPopUntilMain) {
      LogWidget.debug("do pop until main!");
      popUntilMain();
    } else if (popBefore) {
      homeNaviStateKey.currentState?.popWidget();
    }

    LogWidget.debug("do pop end!");

    if (moveTab != null && currentTab.value != moveTab) {
      moveToTab(moveTab);
    }

    var uri = Uri.parse(path);
    HomeWidget nextWidget = TabNavigatorRoute.getNextWidget(uri, arguments);
    nextWidget.popActionCallback = popAction;

    LogWidget.debug("next widget is ${nextWidget.runtimeType}");
    homeNaviStateKey.currentState
        ?.pushWidget(nextWidget, padding: addedPadding);
  }

  static RenderBox? getHomeWidgetRenderBox(HomeWidget homeWidget) {
    HomeNavigatorState? homeNavigatorState = homeNaviStateKey.currentState;
    if(homeNavigatorState == null) return null;

    GlobalKey? globalKey;
    if(homeNavigatorState.oneDepthWidgetList.contains(homeWidget)) {
      globalKey = homeNavigatorState.oneDepthWidgetKey;
    } else if(homeNavigatorState.twoDepthWidget == homeWidget) {
      globalKey = homeNavigatorState.twoDepthWidgetKey;
    } else if(homeNavigatorState.twoDepthPopUpWidgetList.contains(homeWidget)) {
      globalKey = homeNavigatorState.twoDepthPopUpWidgetKey;
    } else if(homeNavigatorState.overlayWidgetList.contains(homeWidget)) {
      globalKey = homeNavigatorState.overlayWidgetKey;
    } else {
      return null;
    }
    return globalKey.currentContext?.findRenderObject() as RenderBox?;
  }

  static void pushHomeWidget(HomeWidget homeWidget) {
    homeNaviStateKey.currentState?.pushWidget(homeWidget);
  }

  static void popHomeWidget<T extends HomeWidget>(T homeWidget,
      {String? path,
      PopActionCallback? popAction,
      SlideRouteDirection? slideDirection,
      bool popBefore = false,
      bool doPopUntilMain = false}) {
    if (doPopUntilMain) {
      _instance?.homeScreenNavigatorKey.currentState
          ?.popUntil((route) => route.settings.name == "/");
    } else if (popBefore &&
        _instance?.homeScreenNavigatorKey.currentState?.canPop() == true) {
      _instance?.homeScreenNavigatorKey.currentState?.pop();
    }
  }

  @override
  State<StatefulWidget> createState() => HomeNavigatorState();
}

class HomeNavigatorState extends State<HomeNavigator>
    with TickerProviderStateMixin {
  static const double tabBarHeight = 87;
  static const double slideBarSize = 700;

  List<HomeWidget> widgetStack = [];

  HomeNavigatorTab? get nowTabNavi =>
      selectedIndex == null ? null : widget.homeTabs[selectedIndex!];

  late AnimationController _tabMenuAnimationController;

  // late NoTransitionTabController _tabController;
  int? selectedIndex = HomeNavigator.currentTab.value.index;

  GlobalKey oneDepthWidgetKey = GlobalKey();
  GlobalKey twoDepthWidgetKey = GlobalKey();
  GlobalKey twoDepthPopUpWidgetKey = GlobalKey();
  GlobalKey overlayWidgetKey = GlobalKey();

  HomeWidget? willBeClosedTwoDepthWidget;
  List<HomeWidget> oneDepthWidgetList = [];
  HomeWidget? twoDepthWidget;
  HomeWidget? prevTwoDepthWidget;
  List<HomeWidget> twoDepthPopUpWidgetList = [];
  List<HomeWidget> overlayWidgetList = [];
  // List<HomeWidget> mergedOneDepthWidgetList = [];
  late TabController tabController = TabController(length: 4, vsync: this);

  bool get dimmedUnderTwoDepthPopUp =>
      twoDepthPopUpWidgetList.length > 0 ? twoDepthPopUpWidgetList.last.dimmedBackground : false;

  void _pushPopCallBack(HomeWidget? nextWidget) {
    if (nextWidget == null) {
      // pop
      if(widgetStack.isNotEmpty)
        nextWidget = widgetStack.last;
    }

    if (nextWidget != null) {
      switch (nextWidget.homeWidgetLayer) {
        case HomeWidgetLayer.underNavi:
          break;
        case HomeWidgetLayer.onSlidePanel:
          break;
        case HomeWidgetLayer.overNavi:
          break;
      }
    }
  }

  void clearTwoDepthPopUp() async {
    int targetWidgetCnt = twoDepthPopUpWidgetList.length;
    List<HomeWidget> widgetList = List.from(twoDepthPopUpWidgetList);
    for(var widget in widgetList) {
      popWidget(homeWidget: widget, ignoreSetState: true);
    }
    twoDepthPopUpWidgetList.clear();
    setState(() {

    });
  }

  void pushWidget(HomeWidget homeWidget, {EdgeInsetsGeometry? padding}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (padding != null) {
      homeWidget.addedPadding = padding;
    }
    if (widgetStack.isNotEmpty) {
      HomeWidget prevWidget = widgetStack.last;
      if (prevWidget.pageType ==
          homeWidget.pageType) {
        widgetStack.removeLast();
      }
    }
    if(!homeWidget.isEmptyPage)
      widgetStack.add(homeWidget);
    _pushPopCallBack(homeWidget);

    if(!homeWidget.isInternalImplement) {
      switch (homeWidget.widgetType) {
        case HomeWidgetType.oneDepth:
          oneDepthWidgetList.add(homeWidget);
          break;
        case HomeWidgetType.twoDepth:
          if(PageType.isSquarePage(homeWidget) || PageType.isChatPage(homeWidget) ||
              twoDepthWidget == null || homeWidget.isEmptyPage == true) {
            twoDepthWidget = homeWidget;
            if(PageType.isChatPage(twoDepthWidget) || PageType.isSquarePage(twoDepthWidget)) {
              prevTwoDepthWidget = twoDepthWidget;
              LogWidget.debug("${homeWidget.runtimeType}");
            }
          } else if(prevTwoDepthWidget != null) {
            twoDepthWidget = prevTwoDepthWidget;
          }
          break;
        case HomeWidgetType.twoDepthPopUp:
          twoDepthPopUpWidgetList.add(homeWidget);
          break;
        case HomeWidgetType.overlay:
        case HomeWidgetType.overlayPopUp:
          overlayWidgetList.add(homeWidget);
          break;
      }
      setState(() {});
    }
  }

  bool popInternal(HomeWidget prevWidget, {dynamic value, bool? untilTapRoot, bool ignoreSetState = false}) {

    if(prevWidget.widgetType == HomeWidgetType.oneDepth) {
      HomeWidget? lastOneDepthWidget = widgetStack.lastWhereOrNull((element) => element.widgetType == HomeWidgetType.oneDepth);
    }

    if(prevWidget.isInternalImplement) {
      widget.popStreamController.add(prevWidget);
    }

    if (twoDepthPopUpWidgetList.contains(prevWidget)) {
      twoDepthPopUpWidgetList.remove(prevWidget);
      if(MeModel().showTransition) {
        bool isMobile = MediaQuery.of(context).size.width < DeviceUtil.minSideNaviWidth;
        if(!isMobile || (isMobile && prevWidget.slideShowUpInMobile)) {
          willBeClosedTwoDepthWidget = prevWidget;
        }
        TransitionManager().reverseWidget(prevWidget);
      }
    } else if (prevWidget == twoDepthWidget) {
      prevTwoDepthWidget = null;
      twoDepthWidget = EmptyExpandTwoDepthWidget();
    } else if (oneDepthWidgetList.contains(prevWidget)) {
      oneDepthWidgetList.remove(prevWidget);
    } else if (overlayWidgetList.contains(prevWidget)) {
      overlayWidgetList.remove(prevWidget);
    }

    LogWidget.debug("pop widget! current: ${prevWidget} / prev ");
    if (prevWidget == null) return false;

    _pushPopCallBack(null);
    prevWidget.popActionCallback?.call(value);
    if(!ignoreSetState) {
      setState(() {});
    }
    return true;
  }

  bool popWidget({dynamic value, bool? untilTapRoot, HomeWidget? homeWidget, bool ignoreSetState = false}) {
    HomeWidget? prevWidget = homeWidget != null
        ? popWidgetTarget(homeWidget)
        : widgetStack.removeLast();
    if (prevWidget != null) {
      return popInternal(prevWidget, value: value, untilTapRoot: untilTapRoot, ignoreSetState: ignoreSetState);
    }
    return false;
  }

  bool popTwoDepthWidget({dynamic value}) {
    if(twoDepthWidget == null) return false;
    bool ret = popInternal(twoDepthWidget!, value: value);
    widgetStack.remove(twoDepthWidget);
    return ret;
  }

  HomeWidget? popWidgetTarget(HomeWidget homeWidget) {
    HomeWidget? prevWidget = homeWidget;
    if (prevWidget != null) {
      widgetStack.remove(homeWidget);
    }
    return prevWidget;
  }

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogWidget.debug(
          "home navigator init ------- ${HomeNavigator.currentTab.value}");
      _onTapTab(
          widget.navigatorWithNaviCode[HomeNavigator.currentTab.value]!.key,
          moveWithTabBar: true);
    });
  }

  Widget _buildForMobile() {
    List<HomeWidget> listed = List.from(widgetStack.where((element) => !element.isInternalImplement).toList());
    if(willBeClosedTwoDepthWidget != null)
      listed.add(willBeClosedTwoDepthWidget!);

    List<Widget> resultUnderNaviBar = [];
    List<Widget> resultOverNaviBar = [];
    for (HomeWidget element in listed) {
      Widget child = Stack(
        children: [
          element,
          HomeTopMenu(element.getMenuPack)
        ],
      );
      if(element.slideShowUpInMobile && MeModel().showTransition) {
        AnimationController transitionController = TransitionManager().getTransition(element, true);
        CurvedAnimation curvedAnimation = CurvedAnimation(parent: transitionController, curve: SquareTransition.twoDepthPopUpTransitionCurve);
        if(willBeClosedTwoDepthWidget == null) {
          transitionController.forward();
        }

        resultOverNaviBar.add(
          AnimatedBuilder(animation: transitionController, builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, DeviceUtil.screenHeight * (1 - curvedAnimation.value)),
              child: child!,
            );
          }, child: child)
        );
      } else {
        if(element.widgetType != HomeWidgetType.oneDepth) {
          resultOverNaviBar.add(child);
        } else {
          resultUnderNaviBar.add(child);
        }
      }
    }

    bool showNaviBar = listed.length == oneDepthWidgetList.length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              top: Zeplin.size(90),
              child: Stack(children: resultUnderNaviBar)
          ),
          SquareNavigationBar(tabController, selectedIndex, (index) {
                  _onTapTab(index, moveWithTabBar: true);
                }),
          Positioned.fill(
              child: Stack(children: resultOverNaviBar)
          ),
        ],
      ),
    );
  }

  Widget _buildOneDepthWidgetForDesktop() {
    if (oneDepthWidgetList.isEmpty) return Container();
    List<Widget> list = [];
    for (HomeWidget element in oneDepthWidgetList) {
      list.add(element);
      list.add(HomeTopMenu(element.getMenuPack));
    }

    if (oneDepthWidgetList.last.maxWidth == null || twoDepthWidget == null || twoDepthWidget?.maxWidth == 0) {
      return Expanded(
          key: oneDepthWidgetKey,
          child: Stack(
            children: list,
          ));
    }
    return SizedBox(
      key: oneDepthWidgetKey,
      width: min(oneDepthWidgetList.last.maxWidth!,
          (DeviceUtil.screenWidth) / 2.0 - Zeplin.size(72)),
      child: Stack(
          children: dimmedUnderTwoDepthPopUp
              ? list +
              <Widget>[
                Container(
                  color: CustomColor.dimColor,
                )
              ]
              : list),
    );
  }

  Widget _buildTwoDepthWidgetForDesktop() {
    if (twoDepthWidget == null) {
      twoDepthWidget = EmptyTwoDepthWidget();
    }

    Widget? popUp;
    if (twoDepthPopUpWidgetList.length > 0 || willBeClosedTwoDepthWidget != null) {
      final twoDepthPopUpWidget = twoDepthPopUpWidgetList.length > 0 ? twoDepthPopUpWidgetList.last : willBeClosedTwoDepthWidget!;
      EdgeInsetsGeometry oldPadding =
          twoDepthPopUpWidget.padding ?? EdgeInsets.zero;
      EdgeInsetsGeometry? addedPadding = twoDepthPopUpWidget.addedPadding;

      AnimationController? transitionController;
      CurvedAnimation? curvedAnimation;

      if(MeModel().showTransition) {
        transitionController = TransitionManager().getTransition(twoDepthPopUpWidget, false);
        curvedAnimation = CurvedAnimation(parent: transitionController, curve: SquareTransition.twoDepthPopUpTransitionCurve);
        if(willBeClosedTwoDepthWidget == null) {
          transitionController.forward();
        }
      }


      Widget child = SizedBox(

        width: twoDepthPopUpWidget.maxWidth,
        height: twoDepthPopUpWidget.maxHeight,
        child: Padding(
          padding: addedPadding != null
              ? EdgeInsets.symmetric(
              vertical:
              addedPadding.vertical / 2 + oldPadding.vertical / 2,
              horizontal: addedPadding.horizontal / 2 +
                  oldPadding.horizontal / 2)
              : oldPadding,
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset.zero, // changes position of shadow
              ),
            ], borderRadius: BorderRadius.all(Radius.circular(18))),
            child: Stack(
              children: [
                ClipRRect(child: twoDepthPopUpWidget, borderRadius: BorderRadius.circular(18.0)),
                HomeTopMenu(twoDepthPopUpWidget.getMenuPack),
              ],
            ),
          ),
        ),
      );

      popUp = Stack(
        key: ValueKey("${twoDepthPopUpWidget.hashCode}"),
        children: [
          twoDepthPopUpWidget.dimmedBackground
              ? Container(
                  color: CustomColor.dimColor,
                )
              : Container(),
          TwoDepthWidget(
              key: twoDepthPopUpWidgetKey,
              transitionController: transitionController, curvedAnimation: curvedAnimation, child: child)
        ],
      );
    }

    Widget stack = Stack(
      children: [
        Stack(
          children: [
            twoDepthWidget!,
            HomeTopMenu(twoDepthWidget!.getMenuPack),
          ],
        ),
        popUp ?? Container(),
        oneDepthWidgetList.any((element) => element.dimmedBackground)
            ? Container(
                color: CustomColor.dimColor,
              )
            : Container()
      ],
    );

   /* Widget divider = Container(
      width: 1,
      color: CustomColor.veryLightGrey,
      height: DeviceUtil.screenHeight,
    );*/

    if (twoDepthWidget!.maxWidth == null) {
      return Expanded(
        key: twoDepthWidgetKey,
        child: stack);
    }

    return  Row(
      children: [
        VerticalDivider(
          width: 1,
          color: CustomColor.veryLightGrey,
        ),
        SizedBox(
          key: twoDepthWidgetKey,
          width: twoDepthWidget!.maxWidth, child: stack),
      ],
    );
  }

  BoxConstraints? getOverlayConstraints(HomeWidget overlayWidget) {
    if(overlayWidget.maxWidth != null && overlayWidget.maxHeight != null) {
       return BoxConstraints(
         maxHeight: overlayWidget.maxHeight!,
         maxWidth: overlayWidget.maxWidth!
       );
    } else if(overlayWidget.maxWidth != null) {
      return BoxConstraints(
          maxWidth: overlayWidget.maxWidth!
      );
    } else if(overlayWidget.maxHeight != null) {
      return BoxConstraints(
          maxHeight: overlayWidget.maxHeight!,
      );
    }
    return null;
  }

  Widget _buildOverlayForDesktop() {
    if (overlayWidgetList.isEmpty) return Container();
    List<Widget> withDimmed = [];
    overlayWidgetList.forEach((element) {
      if (element.dimmedBackground) {
        withDimmed.add(Container(
          color: element.widgetType == HomeWidgetType.overlayPopUp ? CustomColor.dimColor : CustomColor.dimColor2,
        ));
      }
      Widget child = Stack(
        children: [
          element,
          Align(
            alignment: Alignment.topCenter,
            child: HomeTopMenu(element.getMenuPack),
          ),
        ],
      );

      if(element.widgetType == HomeWidgetType.overlayPopUp) {
        withDimmed.add(Padding(
          padding: element.padding ?? EdgeInsets.zero,
          child:  Center(child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Container(
                constraints: getOverlayConstraints(element),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset.zero, // changes position of shadow
                    ),
                  ]),
                child:child),
          )),
        ));
      } else {
        withDimmed.add(child);
      }
    });
    return Center(
      key: overlayWidgetKey,
        child: Stack(
      children: withDimmed,
    ));
  }

  Widget _buildForDesktop() {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          colorScheme: ColorScheme.light(primary: Colors.white),
                          highlightColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: NavigationRail(
                          selectedIndex: selectedIndex,
                          onDestinationSelected: (index) => _onTapTab(index, moveWithTabBar: true),
                          destinations: widget.homeTabs.map((e) => e.navigationRailDestination).toList(),
                          labelType: NavigationRailLabelType.all,
                          selectedLabelTextStyle: TextStyle(color: Colors.black, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, height: 1.6),
                          unselectedLabelTextStyle: TextStyle(color: CustomColor.unselectedTextGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, height: 1.6),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: CustomColor.veryLightGrey,
                      ),
                    ],
                  ),
                  Positioned.fill(
                      child: dimmedUnderTwoDepthPopUp
                          ? Container(
                              color: CustomColor.dimColor,
                            )
                          : Container())
                ],
              ),
              /*Listener(
                onPointerDown: (evt) {
                  _tabOutsideOfTwoDepthPopUp();
                },
                child: _buildOneDepthWidgetForDesktop()
              ),*/
              _buildOneDepthWidgetForDesktop(),
              Stack(
                children: [
                  VerticalDivider(
                    width: 1,
                    color: CustomColor.veryLightGrey,
                  ),
                  Positioned.fill(
                      child: dimmedUnderTwoDepthPopUp
                          ? Container(
                              color: CustomColor.dimColor,
                            )
                          : Container())
                ],
              ),
              _buildTwoDepthWidgetForDesktop()
            ],
          ),
          _buildOverlayForDesktop()
        ],
      ),
    );
  }

  void tabOutsideOfTwoDepthPopUp() {
    if(twoDepthPopUpWidgetList.length > 0) {
      for (var value in twoDepthPopUpWidgetList) {
        if(PageType.isPlayerProfilePage(value)) {
          ContactManager().selectedContactBloc.add(Update());
          break;
        }
      }
      clearTwoDepthPopUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSideNavi =
        MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;
    screenWidthNotifier.value = MediaQuery.of(context).size.width;

    LogWidget.debug(
        "rebuild~~ : ${ModalRoute.of(widget.homeScreenNavigatorKey.currentContext ?? context)?.settings.name}, isSideNavi: $isSideNavi");

    if (isSideNavi)
      return _buildForDesktop();
    else
      return _buildForMobile();
  }

  void initCurrentTab({bool rollbackPrevTwoDepth = false}) {
    int? index = HomeNavigator.currentTabIndex;
    if(index == null) return ;

    clearAllStack(index);

    HomeNavigatorTab nextTab = widget.homeTabs[index];
    pushWidget(nextTab.rootHomeWidget);
    if(rollbackPrevTwoDepth) {
     if (prevTwoDepthWidget != null && !nextTab.rootHomeWidget.expanded) {
        twoDepthWidget = prevTwoDepthWidget;
        // prevTwoDepthWidget = null;
      }else if (nextTab.twoDepthWidget != null) {
        pushWidget(nextTab.twoDepthWidget!);
      }
    } else {
      prevTwoDepthWidget = null;
      twoDepthWidget = null;
      pushWidget(nextTab.twoDepthWidget!);
    }

    setState(() {

    });
  }

  void clearAllStack(int tabIndex) {
    oneDepthWidgetList.clear();
    if(tabIndex == TabCode.square.index || !(PageType.isChatPage(twoDepthWidget) || PageType.isSquarePage(twoDepthWidget))) {
      twoDepthWidget = null;
    }
    twoDepthPopUpWidgetList.clear();
    overlayWidgetList.clear();
    willBeClosedTwoDepthWidget = null;
    // mergedOneDepthWidgetList.clear();
  }

  void _onTapTab(int? index, {bool? moveWithTabBar}) {
    while (index == selectedIndex
        ? widgetStack.length > 1
        : widgetStack.isNotEmpty) {
      HomeWidget? prevWidget = widgetStack.removeLast();
    }

    if (index == null) {
      setState(() => selectedIndex = null);
      return;
    }

    HomeNavigatorTab nextTab = widget.homeTabs[index];
    LogWidget.debug("next tab index: $index, nextTab : $nextTab");

    clearAllStack(index);

    pushWidget(nextTab.rootHomeWidget);
    if (prevTwoDepthWidget != null && !nextTab.rootHomeWidget.expanded) {
      twoDepthWidget = prevTwoDepthWidget;
      // prevTwoDepthWidget = null;
    }else if (nextTab.twoDepthWidget != null) {
      pushWidget(nextTab.twoDepthWidget!);
    }

    HomeNavigator.currentTab.value = nextTab.tabCode;
    setState(() => selectedIndex = index);
  }
}
