import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/square/square_list_page.dart';
import 'package:square_web/page/square/square_list_page_top_menu.dart';
import 'package:square_web/page/square/square_search_page.dart';
import 'package:square_web/service/square_manager.dart';

class SquareListPageHome extends StatefulWidget with HomeWidget {
  @override
  TabCode get targetNavigator => TabCode.square;

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  static bool isIconView = true;

  static int pageIndex = 0;

  @override
  bool get expanded => isIconView;

  @override
  String pageName() => "SquareListPageHome";

  @override
  State<SquareListPageHome> createState() => _SquareListPageHomeState();
}

class _SquareListPageHomeState extends State<SquareListPageHome> {
  PreloadPageController pageController = PreloadPageController();

  late HomeWidget squareListPage;
  late HomeWidget squareSearchPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    squareListPage = SquareListPage(selectedSquareFolder: SquareManager().selectedSquareFolder);
    squareSearchPage = SquareSearchPage(showPage: showPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(SquareListPageHome.pageIndex == 1) {
        pageController.jumpToPage(SquareListPageHome.pageIndex);
        HomeNavigator.pushHomeWidget(squareSearchPage);
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void showPage(int index) {
    bool isMobile = screenWidthNotifier.value < maxWidthMobile;

    SquareListPageHome.pageIndex = index;
    if(MeModel().showTransition && (isMobile || (!isMobile && !SquareListPageHome.isIconView))) {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut);
    }
    if(index == 1) {
      HomeNavigator.pushHomeWidget(squareSearchPage);
    }
    setState(() {

    });
  }

  Widget _buildNoTransition() {
    return Stack(
      children: [
        SquareListPageHome.pageIndex == 0 ? squareListPage : squareSearchPage,
        Align(
          alignment: Alignment.topCenter,
          child: SquareListPageTopMenu(
            selectedSquareFolder: SquareManager().selectedSquareFolder,
            pageIndex: SquareListPageHome.pageIndex,
            showPage: showPage,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenWidthNotifier.value < maxWidthMobile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MeModel().showTransition && (isMobile || (!isMobile && !SquareListPageHome.isIconView))? Stack(
        children: [
          PreloadPageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              squareListPage,
              squareSearchPage,
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SquareListPageTopMenu(
              selectedSquareFolder: SquareManager().selectedSquareFolder,
              pageIndex: SquareListPageHome.pageIndex,
              showPage: showPage,
            ),
          )
        ],
      ) : _buildNoTransition(),
    );
  }
}