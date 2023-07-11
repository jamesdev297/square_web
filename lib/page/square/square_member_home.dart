import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/page/square/square_member_page.dart';
import 'package:square_web/page/profile/player_profile_page_home.dart';


class SquareMemberHome extends StatefulWidget with HomeWidget {
  final SquareModel model;
  final String channel;

  SquareMemberHome(this.model, this.channel);

  @override
  State createState() => SquareMemberHomeState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.only(top: Zeplin.size(54, isPcSize: true), left: Zeplin.size(20));

  @override
  bool get slideShowUpInMobile => true;

  @override
  String pageName() => "SquareMemberHome";
}

class SquareMemberHomeState extends State<SquareMemberHome> {
  PreloadPageController pageController = PreloadPageController();
  ValueNotifier<String?> playerProfilePagePlayerId = ValueNotifier(null);

  late HomeWidget squareMemberPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    squareMemberPage = SquareMemberPage(widget.model, widget.channel, widget,
        pageController: pageController, playerProfilePagePlayerId: playerProfilePagePlayerId);
  }

  @override
  void dispose() {
    pageController.dispose();
    playerProfilePagePlayerId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PreloadPageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          Stack(
            children: [
              squareMemberPage,
              HomeTopMenu(squareMemberPage.getMenuPack)
            ],
          ),
          ValueListenableBuilder<String?>(valueListenable: playerProfilePagePlayerId,
              builder: (context, value, child) {
                if(value == null) return Container();
                HomeWidget playerProfilePage = PlayerProfilePageHome(value, rootWidget: widget, key: ValueKey("ProfilePage:${value}"), squareMemberPageController: pageController);
                return Stack(
                  children: [
                    playerProfilePage,
                    HomeTopMenu(playerProfilePage.getMenuPack)
                  ],
                );
              })
        ],
      ),
    );
  }
}