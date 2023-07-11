import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/page/profile/ai_square_profile_page.dart';
import 'package:square_web/page/profile/player_profile_page_home.dart';


class AiSquareProfileHome extends StatefulWidget with HomeWidget {
  final SquareModel model;
  final String channel;

  AiSquareProfileHome(this.model, this.channel, {Key? key}) : super(key: key);

  @override
  State createState() => AiSquareProfileHomeState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.squareProfilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.only(top: Zeplin.size(54, isPcSize: true), left: Zeplin.size(20));

  @override
  bool get slideShowUpInMobile => true;

  @override
  String pageName() => "AiSquareProfileHome";
}

class AiSquareProfileHomeState extends State<AiSquareProfileHome> {
  PreloadPageController pageController = PreloadPageController();
  ValueNotifier<String?> playerProfilePagePlayerId = ValueNotifier(null);

  late HomeWidget aiSquareProfilePage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    aiSquareProfilePage = AiSquareProfilePage(widget.model,
        widget.channel, widget,
        pageController: pageController,
        playerProfilePagePlayerId: playerProfilePagePlayerId);
  }

  @override
  void dispose() {
    pageController.dispose();
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
              aiSquareProfilePage,
              HomeTopMenu(aiSquareProfilePage.getMenuPack)
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