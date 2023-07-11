import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/bloc/ai/select_ai_player_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/home_top_menu.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/square/edit_user_square_page.dart';
import 'package:square_web/page/square/select_ai_player_page.dart';


class EditUserSquarePageHome extends StatefulWidget with HomeWidget {
  final SquareModel squareModel;
  final String aiPlayerId;
  EditUserSquarePageHome({Key? key, required this.squareModel, required this.aiPlayerId }) : super(key: key);

  @override
  State createState() => EditUserSquarePageHomeState();

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
  String pageName() => "EditUserSquarePageHome";
}

class EditUserSquarePageHomeState extends State<EditUserSquarePageHome> {
  final PreloadPageController pageController = PreloadPageController();
  SelectAiPlayerBloc selectAiPlayerBloc = SelectAiPlayerBloc();
  int pageIndex = 0;

  late HomeWidget editSquarePage;
  late HomeWidget selectAiPlayerPage;

  @override
  void initState() {
    super.initState();

    editSquarePage = EditUserSquarePage(squareModel: widget.squareModel, onNext: showPage);
    selectAiPlayerPage = SelectAiPlayerPage(aiPlayerId: widget.aiPlayerId, onPrevious: showPage, onSelectAiPlayer: onSelectAiPlayer);
    selectAiPlayerBloc.add(LoadAiPlayerEvent(widget.aiPlayerId));
  }

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
    return pageIndex == 0 ? _buildPage(editSquarePage) : _buildPage(selectAiPlayerPage);
  }

  Widget _buildPage(HomeWidget homeWidget) {
    return Stack(
      children: [
        homeWidget,
        HomeTopMenu(homeWidget.getMenuPack)
      ],
    );
  }

  Widget _buildMyProfile() {
    if(MeModel().showTransition) {
      return PreloadPageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          _buildPage(editSquarePage),
          _buildPage(selectAiPlayerPage)
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
        body:  MeModel().showTransition ? PreloadPageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              _buildPage(editSquarePage),
              _buildPage(selectAiPlayerPage)
            ]
        ) : _buildNoTransition()
    );
  }

  void onSelectAiPlayer(ContactModel contactModel) {
    selectAiPlayerBloc.add(SelectAiPlayerEvent(contactModel));

    showPage(0);
  }
}