import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/blue_dot.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';

class RoomsPageTopMenu extends StatefulWidget {
  final ValueNotifier<RoomFolder> selectedRoomFolder;
  final Function showPage;
  final int pageIndex;

  const RoomsPageTopMenu({
    Key? key,
    required this.selectedRoomFolder,
    required this.showPage,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<RoomsPageTopMenu> createState() => _RoomsPageTopMenuState();
}

class _RoomsPageTopMenuState extends State<RoomsPageTopMenu> {
  bool isShown = false;
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectedRoomFolder.addListener(() {
      setState(() {});
    });

    screenWidthNotifier.addListener(() {
      if (isShown) {
        isShown = false;
        SquarePopUpMenu.hide;
        setState(() {});
      }
    });
  }

  void onShowFunc(bool isShow) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isShown = isShow;
    });
  }

  void showToolTip() {

    onShowFunc(true);
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset startOffset, Size rootWidgetSize, Size popUpSize) {
      Offset offset = Offset(startOffset.dx, startOffset.dy +30);
      return GetPopUpOffsetCallbackResponse(offset);
    }, onCancel: () => onShowFunc(false));
  }

  void onSelected(RoomFolder roomFolder) {
    widget.selectedRoomFolder.value = roomFolder;
    isShown = false;
    setState(() {});
  }

  Widget _buildSelectChat() {
    return BlocBuilder<BlueDotBloc, BlueDotState>(
        bloc: BlocManager.getBloc(),
        builder: (context, state) {

          squarePopUpItems = [
            SquarePopUpItem(
              assetPath: Assets.img.ico_36_talk_bla,
              name: L10n.chat_01_01_chat,
              nameWidget: Row(
                children: [
                  Icon36(Assets.img.ico_36_talk_bla),
                  SizedBox(width: Zeplin.size(12)),
                  Text(L10n.chat_01_01_chat,
                      style: TextStyle(
                          color: CustomColor.darkGrey,
                          fontSize: Zeplin.size(28),
                          fontWeight: FontWeight.w500)),
                  Spacer(),
                  if(state.hasBlueDot(TabCode.chat, key: BlueDotKey.unreadRoom))
                    BlueDot()
                ],
              ),
              onTap: () => onSelected(RoomFolder.chat)),
            SquarePopUpItem(
              assetPath: Assets.img.ico_36_storage_bk,
              name: L10n.archive_02_01_archived_room,
              nameWidget: Row(
                children: [
                  Icon36(Assets.img.ico_36_storage_bk),
                  SizedBox(width: Zeplin.size(12)),
                  Text(L10n.archive_02_01_archived_room,
                      style: TextStyle(
                          color: CustomColor.darkGrey,
                          fontSize: Zeplin.size(28),
                          fontWeight: FontWeight.w500)),
                  Spacer(),
                  if (state.hasBlueDot(TabCode.chat,
                      key: BlueDotKey.unreadArchivedRoom))
                    BlueDot()
                ],
              ),
              onTap: () => onSelected(RoomFolder.archives)),
            SquarePopUpItem(
              assetPath: Assets.img.ico_36_block_bla,
              name: L10n.chat_02_01_block_box,
              nameWidget: Row(
                children: [
                  Icon36(Assets.img.ico_36_block_bla),
                  SizedBox(width: Zeplin.size(12)),
                  Text(L10n.chat_02_01_block_box,
                      style: TextStyle(
                          color: CustomColor.darkGrey,
                          fontSize: Zeplin.size(28),
                          fontWeight: FontWeight.w500)),
                ],
              ),
              onTap: () => onSelected(RoomFolder.block)),
          ];

          late String name;

          if(widget.selectedRoomFolder.value == RoomFolder.chat) {
            name = L10n.chat_01_01_chat;
          } else if(widget.selectedRoomFolder.value == RoomFolder.archives) {
            name = L10n.archive_02_01_archived_room;
          } else {
            name = L10n.chat_02_01_block_box;
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              key: globalKey,
              onTap: showToolTip,
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: TextStyle(fontSize: Zeplin.size(34), color: CustomColor.darkGrey, fontWeight: FontWeight.w500)),
                    SizedBox(width: Zeplin.size(10)),
                    AnimatedRotation(
                        turns: isShown ? 0.5 : 0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInBack,
                        child: Icon26(Assets.img.ico_h_26_ud_gy))
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildFirstMenu() {
    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: _buildSelectChat()),
        Align(
          alignment: Alignment.topRight,
          child: Transform.translate(
            offset: Offset(0, 1),
            child: ValueListenableBuilder(
              valueListenable: widget.selectedRoomFolder,
              builder: (context, value, child) {
                if(value == RoomFolder.chat) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Image.asset(Assets.img.ico_36_plus_bla, width: Zeplin.size(36)),
                      onTap: () {
                        widget.showPage(1);
                      }),
                  );
                }
                return Container();
              }),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondMenu() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                  },
                  child: Icon46(Assets.img.ico_46_arrow_bk)),
            )),
        Align(alignment: Alignment.topCenter, child: Text(L10n.chat_open_01_03_start_new_chat, style: centerTitleTextStyle)),
      ],
    );
  }

  Widget _buildNoTransition() {
    return widget.pageIndex == 0 ? _buildFirstMenu() : _buildSecondMenu();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: Padding(
        padding: EdgeInsets.only(
            top: Zeplin.size(32),
            left: Zeplin.size(16),
            right: Zeplin.size(16)),
        child: MeModel().showTransition ? AnimatedCrossFade(
          duration: Duration(milliseconds: 100),
          crossFadeState: widget.pageIndex == 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: _buildFirstMenu(),
          secondChild: _buildSecondMenu(),
        ) : _buildNoTransition()
      ),
    );
  }
}
