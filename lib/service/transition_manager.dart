
import 'package:flutter/animation.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';

class TransitionManager {
  static TransitionManager? _instance;
  TransitionManager._internal();
  factory TransitionManager() => _instance ??= TransitionManager._internal();

  static void destroy() {
    _instance = null;
  }

  Map<HomeWidget, AnimationController> _transitionMap = {};
  TickerProvider? tickerProvider;

  void registerTickerProvider(TickerProvider tickerProvider) {
    this.tickerProvider = tickerProvider;
  }
  
  AnimationController getTransition(HomeWidget homeWidget, bool isMobile) {
    if(!_transitionMap.containsKey(homeWidget)) {
      initTransition(homeWidget, isMobile);
    }
    return _transitionMap[homeWidget]!;
  }
  
  void initTransition(HomeWidget homeWidget, bool isMobile) {
    _transitionMap.putIfAbsent(homeWidget, () => AnimationController(vsync: tickerProvider!, duration: Duration(milliseconds: isMobile ? SquareTransition.slideUpDuration : SquareTransition.defaultDuration)));
    // _transitionMap.putIfAbsent(homeWidget, () => AnimationController(vsync: tickerProvider!, duration: Duration(milliseconds: 3000)));
  }

  void reverseWidget(HomeWidget homeWidget) {
    AnimationController? animController = _transitionMap[homeWidget];
    if(animController == null) return ;
    animController.reverse();

    animController.addStatusListener((status) {
      if(status == AnimationStatus.dismissed) {
        HomeNavigator.clearWillbeClosedTwoDepthWidget();
        _transitionMap.remove(homeWidget);
      }
    });
  }


}