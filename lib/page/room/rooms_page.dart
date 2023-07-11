import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/chat/archived_room_list.dart';
import 'package:square_web/widget/chat/blocked_room_list.dart';
import 'package:square_web/widget/chat/room_list.dart';

class RoomsPage extends StatefulWidget with HomeWidget {
  final ValueNotifier<RoomFolder> selectedRoomFolder;
  final Function showPage;

  RoomsPage({required this.selectedRoomFolder, required this.showPage});

  @override
  TabCode get targetNavigator => TabCode.chat;

  @override
  State createState() => RoomsPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "RoomsPage";
}

class RoomsPageState extends State<RoomsPage> {
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    LogWidget.debug("Rooms Page INIT");
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HomeNavigator.tapOutSideOfTwoDepthPopUp();

        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: _buildRooms(),
        ),
      ),
    );
  }

  Widget _buildRooms() {
    return ValueListenableBuilder(valueListenable: widget.selectedRoomFolder,
        builder: (context, value, child) {
          if(value == RoomFolder.chat)
            return RoomList(focusNode: _focusNode, showPage: widget.showPage);
          else if(value == RoomFolder.archives)
            return ArchivedRoomList(focusNode: _focusNode);
          else
            return BlockedRoomList(focusNode: _focusNode);
        });
  }
}