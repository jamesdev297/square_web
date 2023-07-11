import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/chat_message_bloc.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/chat/twin_chat_player.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';
import 'package:square_web/widget/square/square_chat_header.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';

class ChatHeader extends StatefulWidget {
  RoomModel room;
  ChatMessageBloc messageBloc;
  ChatHeader({Key? key, required this.room, required this.messageBloc}) : super(key: key);

  @override
  _ChatHeaderState createState() => _ChatHeaderState();
}

class _ChatHeaderState extends State<ChatHeader> {
  bool isShown = false;
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;

  @override
  void initState() {
    super.initState();

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
      Offset offset = Offset(startOffset.dx - popUpSize.width + 20, startOffset.dy +20);
      return GetPopUpOffsetCallbackResponse(offset);
    }, onCancel: () => onShowFunc(false));
  }

  void onSelected(TwinChatPopupType value) {
    switch(value) {
      case TwinChatPopupType.blockContact:
        String targetPlayerId = RoomManager().getTargetPlayerIdFromTwinRoomId(widget.room.roomId!);
        if(widget.room.isBlocked) {
          BlocManager.getBloc<BlockedContactsBloc>()!.add(UnblockContactEvent(MeModel().playerId!, targetPlayerId, successFunc: () {
            widget.room.blockedTime = null;
            BlocManager.getBloc<ChatPageBloc>()?.add(Update());

            SquareRoomDialog.showAddContactOverlay(widget.room.contact!.playerId, widget.room.searchName!, successFunc: (contact) {
              RoomManager().updateChatPage(contactModel: contact);
            });

          }));
        } else {
          ContactModel targetPlayer = ContactModel.fromMap(ContactManager().globalPlayerMap[targetPlayerId]!);
          SquareRoomDialog.showBlockRoomOverlay(widget.room, targetPlayer);
        }
        break;
      case TwinChatPopupType.archiveRoom:
        SquareRoomDialog.showArchiveRoomOverlay(widget.room);
        isShown = false;
        break;
      case TwinChatPopupType.close:
        SquarePopUpMenu.hide;
        HomeNavigator.popTwoDepth();
        break;
    }

    if(value != TwinChatPopupType.close)
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    bool isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;
    widget.room = RoomManager().currentChatRoom ?? widget.room;
    squarePopUpItems = [
      if(!widget.room.isBlocked)
        SquarePopUpItem(
            assetPath: Assets.img.ico_36_storage_bk,
            name: L10n.contacts_01_01_contacts,
            nameWidget: Row(
              children: [
                Icon46(Assets.img.ico_36_storage_bk),
                SizedBox(width: Zeplin.size(12)),
                Text(widget.room.isArchived ? L10n.archive_05_01_unarchive : L10n.chat_10_01_archive, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
              ],
            ),
            onTap: () => onSelected(TwinChatPopupType.archiveRoom)),
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_block_bla,
          name: L10n.contacts_02_01_block_list,
          nameWidget: Row(
            children: [
              Icon46(Assets.img.ico_36_block_bla),
              SizedBox(width: Zeplin.size(12)),
              Text(widget.room.isBlocked ? L10n.contacts_02_02_unblock_user : L10n.chat_room_06_01_block_user, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
            ],
          ),
          onTap: () => onSelected(TwinChatPopupType.blockContact)),
      if(isSideNavi)
        SquarePopUpItem(
            assetPath: Assets.img.ico_36_block_bla,
            name: L10n.contacts_02_01_block_list,
            nameWidget: Row(
              children: [
                Icon46(Assets.img.ico_46_x_bk),
                SizedBox(width: Zeplin.size(12)),
                Text(L10n.chat_01_03_close_chat, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
              ],
            ),
            onTap: () => onSelected(TwinChatPopupType.close)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CustomColor.paleGrey, width: 1))
      ),
      height: Zeplin.size(54, isPcSize: true),
      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(20)),
      child: Row(
        children: [
          if(!isSideNavi)
            Padding(
              padding: EdgeInsets.only(right: Zeplin.size(30)),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    HomeNavigator.pop();
                  },
                  child: Icon46(Assets.img.ico_46_arrow_bk)
                ),
              ),
            ),
          TwinChatPlayerProfile(playerId: widget.room.contact!.playerId, isKnown: widget.room.isKnown),
          Spacer(),
          _buildPopup(),
        ]
      ),
    );
  }

  Widget _buildPopup() {

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: globalKey,
        onTap: () => showToolTip(),
        child: Icon46(Assets.img.ico_46_more),
      ),
    );
  }
}
