import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/room/rooms_page.dart';
import 'package:square_web/page/room/rooms_top_menu.dart';
import 'package:square_web/page/room/start_new_chat_page.dart';
import 'package:square_web/service/room_manager.dart';


class RoomsHome extends StatefulWidget with HomeWidget {
  RoomsHome();

  @override
  TabCode get targetNavigator => TabCode.chat;

  @override
  State createState() => RoomsHomeState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "RoomsHome";
}

class RoomsHomeState extends State<RoomsHome> {
  PreloadPageController pageController = PreloadPageController();
  int pageIndex = 0;

  late HomeWidget startNewChatPage;
  late HomeWidget roomsPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomsPage = RoomsPage(selectedRoomFolder: RoomManager().selectedRoomFolder, showPage: showPage);
    startNewChatPage = StartNewChatPage(pageIndex: pageIndex, showPage: showPage);
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

    startNewChatPage = StartNewChatPage(pageIndex: pageIndex, showPage: showPage,);
    if(index == 1) {
      HomeNavigator.pushHomeWidget(startNewChatPage);
    }
    setState(() {

    });
  }

  Widget _buildNoTransition() {
    return Stack(
      children: [
        pageIndex == 0 ? roomsPage : startNewChatPage,
        Align(
          alignment: Alignment.topCenter,
          child: RoomsPageTopMenu(
            pageIndex: pageIndex,
            showPage: showPage,
            selectedRoomFolder: RoomManager().selectedRoomFolder,
          )
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
              roomsPage,
              startNewChatPage,
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoomsPageTopMenu(
                pageIndex: pageIndex,
                showPage: showPage,
                selectedRoomFolder: RoomManager().selectedRoomFolder,
              ),
          )
        ],
      ) : _buildNoTransition(),
    );
  }
}