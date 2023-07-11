import 'package:flutter/material.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';

import 'square_default_dialog.dart';

class SquareRoomDialog {

  static void showBlockRoomOverlay(RoomModel room, ContactModel targetPlayer) {
    SquareDefaultDialog.showSquareDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      title: L10n.chat_room_06_01_block_user,
      content: Text(L10n.chat_room_07_01_block_content(targetPlayer.smallerName), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
      button1Text: L10n.common_03_cancel,
      button1Action: SquareDefaultDialog.closeDialog(),
      button2Text: L10n.common_02_confirm,
      button2Action: () {

        if(!room.isTwin) {
          SquareDefaultDialog.closeDialog().call();
          return;
        }

        BlocManager.getBloc<BlockedContactsBloc>()!.add(BlockContactEvent(MeModel().playerId!, targetPlayer, successFunc: () {
          SquareDefaultDialog.closeDialog().call();
          room.blockedTime = DateTime.now().millisecondsSinceEpoch;
          room.isKnown = false;
          BlocManager.getBloc<ChatPageBloc>()?.add(Update());
        }));
      },
    );
  }

  static void showBlockPlayerOverlay(ContactModel contactModel, { VoidCallback? successFunc }) {
    SquareDefaultDialog.showSquareDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      title: L10n.chat_room_06_01_block_user,
      content: Text(L10n.chat_room_07_01_block_content(contactModel.smallerName), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
      button1Text: L10n.common_03_cancel,
      button1Action: SquareDefaultDialog.closeDialog(),
      button2Text: L10n.common_02_confirm,
      button2Action: () {

        BlocManager.getBloc<BlockedContactsBloc>()!.add(BlockContactEvent(MeModel().playerId!, contactModel, successFunc: () {
          SquareDefaultDialog.closeDialog().call();
          contactModel.friendTime = null;
          contactModel.relationshipStatus = RelationshipStatus.blocked;
          RoomManager().updateChatPage(contactModel: contactModel);
          BlocManager.getBloc<ChatPageBloc>()?.add(Update());
          successFunc?.call();
        }));
      },
    );
  }

  static void showAddContactOverlay(String playerId, String name, {Function(ContactModel)? successFunc}) {
    SquareDefaultDialog.showSquareDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      title: L10n.chat_05_04_add_contact,
      content: Text(L10n.chat_05_05_unblock_contact_content(name), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
      button1Text: L10n.common_03_cancel,
      button1Action: SquareDefaultDialog.closeDialog(),
      button2Text: L10n.common_02_confirm,
      button2Action: () {
        SquareDefaultDialog.closeDialog().call();
        BlocManager.getBloc<ContactsBloc>()!.add(AddContactEvent(MeModel().playerId!, playerId, successFunc: successFunc));
      },
    );
  }

  static void showRemoveContactOverlay(ContactModel contactModel, {Function? successFunc}) {
    SquareDefaultDialog.showSquareDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      title: L10n.profile_04_02_delete_contact,
      content: Text(L10n.profile_04_03_delete_contact_content(contactModel.smallerName), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
      button1Text: L10n.common_03_cancel,
      button1Action: SquareDefaultDialog.closeDialog(),
      button2Text: L10n.common_02_confirm,
      button2Action: () {
        SquareDefaultDialog.closeDialog().call();
        BlocManager.getBloc<ContactsBloc>()!.add(RemoveContactEvent(MeModel().playerId!, contactModel.playerId, successFunc: successFunc));
      },
    );
  }

  static void showArchiveRoomOverlay(RoomModel room) {
    SquareDefaultDialog.showSquareDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      title: room.isArchived ? L10n.archive_05_01_unarchive : L10n.chat_room_12_01_archive_title,
      content: Text(room.isArchived ? L10n.archive_06_01_unarchive_content : L10n.chat_room_12_02_archive_content, textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
      button1Text: L10n.common_03_cancel,
      button1Action: SquareDefaultDialog.closeDialog(),
      button2Text: L10n.common_02_confirm,
      button2Action: () {
        if(!room.isTwin) {
          SquareDefaultDialog.closeDialog().call();
          return;
        }

        if(room.isArchived) {
          BlocManager.getBloc<ArchivedRoomsBloc>()!.add(UnarchiveRoomEvent(room.roomId!, successFunc: () {
            room.status = "active";

            if(room.roomId == RoomManager().currentChatRoom?.roomId) {
              RoomManager().currentChatRoom?.status = "active";
            }

            SquareDefaultDialog.closeDialog().call();
          }));
        } else {
          BlocManager.getBloc<ArchivedRoomsBloc>()!.add(ArchiveRoomEvent(room, successFunc: () {
            SquareDefaultDialog.closeDialog().call();
          }));
        }
      },
    );
  }
}