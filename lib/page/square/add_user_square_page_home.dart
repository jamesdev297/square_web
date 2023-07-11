import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/bloc/ai/select_ai_player_bloc.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/square/add_user_square_page.dart';
import 'package:square_web/page/square/select_ai_player_page.dart';
import 'package:square_web/util/device_util.dart';


class AddUserSquarePageHome extends StatefulWidget with HomeWidget {
  AddUserSquarePageHome({Key? key}) : super(key: key);

  @override
  State createState() => AddUserSquarePageHomeState();

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
  String pageName() => "AddUserSquarePageHome";
}

class AddUserSquarePageHomeState extends State<AddUserSquarePageHome> {
  final PreloadPageController pageController = PreloadPageController();
  int pageIndex = 0;

  late HomeWidget addSquarePage = AddUserSquarePage(onNext: showPage);
  // late HomeWidget selectAiPlayerPage = SelectAiPlayerPage(onPrevious: showPage, aiPlayerId: aiPlayerId);


  void showPage(int index) {
    pageIndex = index;
    if(MeModel().showTransition) {
      pageController.animateToPage(index, duration: Duration(milliseconds: SquareTransition.defaultDuration), curve: Curves.easeInOut);
    }

    if(mounted)
      setState(() {});
  }


  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget _buildNoTransition() {
    return _buildPage(addSquarePage);
    // return pageIndex == 0 ? _buildPage(addSquarePage) : _buildPage(selectAiPlayerPage);
  }

  Widget _buildPage(HomeWidget homeWidget) {
    return Stack(
      children: [
        homeWidget,
        HomeTopMenu(homeWidget.getMenuPack)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  MeModel().showTransition ? PreloadPageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          _buildPage(addSquarePage),
          // _buildPage(selectAiPlayerPage)
        ]
      ) : _buildNoTransition()
    );
  }


  /*void onSelectAiPlayer(ContactModel contactModel) {
    selectAiPlayerBloc.add(SelectAiPlayerEvent(contactModel));

    showPage(0);
  }*/
}