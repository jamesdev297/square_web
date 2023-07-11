import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/more/edit_profile_page.dart';
import 'package:square_web/page/more/player_profile_page.dart';


class PlayerProfilePageHome extends StatefulWidget with HomeWidget {
  final String playerId;
  final PreloadPageController? squareMemberPageController;
  final HomeWidget? rootWidget;


  PlayerProfilePageHome(this.playerId, {Key? key, this.squareMemberPageController, this.rootWidget}) : super(key: key);

  @override
  State createState() => PlayerProfilePageHomeState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;

  @override
  bool get slideShowUpInMobile => true;

  @override
  String pageName() => "PlayerProfilePageHome";
}

class PlayerProfilePageHomeState extends State<PlayerProfilePageHome> {
  PreloadPageController? pageController;
  int pageIndex = 0;

  HomeWidget? editProfilePage;
  late HomeWidget playerProfilePage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(MeModel().playerId == widget.playerId) {
      pageController = PreloadPageController();
      editProfilePage = EditProfilePage(showEditPage: showPage);
    }
    playerProfilePage = PlayerProfilePage(widget.playerId, widget.rootWidget ?? widget, squareMemberPageController: widget.squareMemberPageController, showEditPage: showPage);
  }

  void showPage(int index) {
    pageIndex = index;
    if(MeModel().showTransition) {
      pageController?.animateToPage(index, duration: Duration(milliseconds: SquareTransition.defaultDuration), curve: Curves.easeInOut);
    }
    if(mounted)
      setState(() {});
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  Widget _buildNoTransition() {
    return pageIndex == 0 ? Stack(
      children: [
        playerProfilePage,
        HomeTopMenu(playerProfilePage.getMenuPack)
      ],
    ) : Stack(
      children: [
        editProfilePage!,
        HomeTopMenu(editProfilePage!.getMenuPack)
      ],
    );
  }

  Widget _buildMyProfile() {
    if(MeModel().showTransition) {
      return PreloadPageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          Stack(
            children: [
              playerProfilePage,
              HomeTopMenu(playerProfilePage.getMenuPack)
            ],
          ),
          Stack(
            children: [
              editProfilePage!,
              HomeTopMenu(editProfilePage!.getMenuPack)
            ],
          ),
        ],
      );
    } else {
      return _buildNoTransition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: editProfilePage != null ? _buildMyProfile() : Stack(
        children: [
          playerProfilePage,
          HomeTopMenu(playerProfilePage.getMenuPack)
        ],
      )
    );
  }
}