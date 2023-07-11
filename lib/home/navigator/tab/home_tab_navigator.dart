import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/common/navi_blue_dot_builder.dart';

// ignore: must_be_immutable
class HomeNavigatorTab {
  //HomeTabWidget 을 구현한 위젯 반환
  final HomeWidget rootHomeWidget;
  final HomeWidget? twoDepthWidget;

  //탭바 표시용 탭 객체
  final Widget icon;
  final Widget? selectedIcon;
  final String tabText;
  final TabCode tabCode;

  NavigationRailDestination get navigationRailDestination => NavigationRailDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          NaviBlueDotBuilder(tabCode: tabCode)
        ],
      ),
      selectedIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          selectedIcon ?? icon,
          NaviBlueDotBuilder(tabCode: tabCode)
        ],
      ),
      label: Text(tabText)
  );

  Tab toTab(bool selected) => Tab(icon: selected ? icon : selectedIcon ?? icon);

  HomeNavigatorTab({
    required this.rootHomeWidget,
    required this.icon,
    this.twoDepthWidget,
    this.selectedIcon,
    required this.tabText,
    required this.tabCode,
  });
}
