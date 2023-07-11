import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/more/block_setting_page.dart';
import 'package:square_web/page/more/more_page.dart';
import 'package:square_web/page/more/more_page_top_menu.dart';
import 'package:square_web/page/more/user_feedback/send_feedback_page_home.dart';

class MorePageHome extends StatefulWidget with HomeWidget {
  @override
  TabCode get targetNavigator => TabCode.more;

  @override
  double? get maxHeight => PageSize.myPageHeight;

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "MorePageHome";

  @override
  State<MorePageHome> createState() => _MorePageHomeState();
}

class _MorePageHomeState extends State<MorePageHome> {
  PreloadPageController pageController = PreloadPageController();
  int pageIndex = 0;

  late HomeWidget morePage;
  late HomeWidget blockSettingsPage;
  late HomeWidget feedbackPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    morePage = MorePage(showPage: showPage, rootWidget: widget,);
    blockSettingsPage = BlockSettingPage(showPage: showPage,);
    feedbackPage = SendFeedbackPageHome(showPage: showPage);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void showPage(int index) {
    pageIndex = index;
    if(MeModel().showTransition) {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut);
    }
    if(index == 1) {
      HomeNavigator.pushHomeWidget(blockSettingsPage);
    } else if(index == 2) {
      HomeNavigator.pushHomeWidget(feedbackPage);
    }
    setState(() {});
  }

  Widget _buildInternal() {
    if(pageIndex == 0) {
      return morePage;
    }else if(pageIndex == 1) {
      return blockSettingsPage;
    }else {
      return feedbackPage;
    }
  }

  Widget _buildNoTransition() {
    return Stack(
      children: [
        _buildInternal(),
        Align(
          alignment: Alignment.topCenter,
          child: MorePageTopMenu(
            pageIndex: pageIndex,
            showPage: showPage,
            rootWidget: widget,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MeModel().showTransition ? Stack(
        children: [
          PreloadPageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              morePage,
              blockSettingsPage,
              feedbackPage
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: MorePageTopMenu(
              pageIndex: pageIndex,
              showPage: showPage,
              rootWidget: widget,
            )
          )
        ],
      ) : _buildNoTransition(),
    );
  }
}