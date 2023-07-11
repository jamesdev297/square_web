import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/chat_message_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/room/rooms_bloc_state.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/command/command_room.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/emoticon_manager.dart';

import 'bloc_manager.dart';

class RoomManager {
  static RoomManager? _instance;
  RoomManager._internal();
  factory RoomManager() => _instance ??= RoomManager._internal();

  static void destroy() {
    _instance = null;
  }

  SelectedRoomBloc selectedRoomBloc = SelectedRoomBloc();
  RoomModel? currentChatRoom;
  ChatMessageBloc? currentMessageBloc;
  ValueNotifier<RoomFolder> selectedRoomFolder = ValueNotifier(RoomFolder.chat);


  Map<String, dynamic> getRoomMap(String roomId, List<dynamic> msgs) {
    var contactId = RoomManager().getTargetPlayerIdFromTwinRoomId(roomId);
    var contactMap = ContactManager().globalPlayerMap[contactId];
    if(contactMap == null) {
      return {};
    }

    return {
      "roomId":roomId,
      "roomType":"twin",
      "roomTitle":null,
      "customTitle":null,
      "receiveAlarm":true,
      "searchName": contactMap["searchName"],
      "targetProfileImgUrl": contactMap["profileImgUrl"],
      "status":"active",
      "lastMsgTime": msgs.isNotEmpty ? msgs.first["sendTime"] : null,
      "regTime":1676449944462,
      "modTime":1680082288800,
      "aiCreator":null,
      "symbol":"GPT-3",
      "blockedTime":null,
      "lastMsg": msgs.isNotEmpty ? msgs.first : null,
      "members" : [
        {
          "playerId":MeModel().playerId,
          "status":"active",
          "isTyping":false,
          "lastReadTime":0,
          "regTime":1682327649046,
          "modTime":1682411112674},
        Map<String, dynamic>.from(contactMap)..putIfAbsent("lastReadTime", () => 0),
      ],
      "known":true,
      "nftTargetProfileImg":false,
      // "unread":false,
      "unread":roomId.hashCode%2==0,
      "aiChat":true,
      "messages" : msgs
    };
  }

  Map<String, dynamic> globalRoomMap = {};
  List<String> activeRoomIdList = [];
  List<String> archivedRoomIdList = [];
  List<String> blockedRoomIdList = [];


  List<dynamic> initMockMessages(String playerId) {
    List<dynamic> result = [];
    var msgCnt = random.nextInt(100);

    int lastTime = DateTime.now().millisecondsSinceEpoch - random.nextInt(100000);

    for(int i=0;i<msgCnt;i++) {
      if(random.nextBool()) {
        result.add(
            {
              "playerId" : playerId,
              "status" : "normal",
              "messageType" : "text",
              "messageBody" : "테스트입니다.",
              "sendTime" : lastTime,
            }
        );
      } else {
        result.add(
          {
            "playerId" : MeModel().playerId,
            "status" : "normal",
            "messageType" : "text",
            "messageBody" : "테스트",
            "sendTime" : lastTime,
          },
        );
      }
      lastTime -= random.nextInt(10000);
    }
    return result;
  }

  void init() {
    var ids = List.from(ContactManager().globalPlayerMap.keys)..shuffle();
    ids = ids.take(4 + random.nextInt(2)).toList();

    ids.forEach((key) {
      var roomId = ContactModel.makeTwinRoomId(key);
      globalRoomMap.putIfAbsent(roomId, () => getRoomMap(roomId, initMockMessages(key)));
    });

    activeRoomIdList.addAll(globalRoomMap.keys);
  }

  void clearData() {
    currentChatRoom = null;
    currentMessageBloc = null;
  }

  String getTargetPlayerIdFromTwinRoomId(String roomId) {
    List<String> playerIds = roomId.split(":");
    return playerIds[1] == MeModel().playerId ? playerIds[2] : playerIds[1];
  }

  Future<Map<String, dynamic>?> loadRoomsFromServer(int limit, { int? cursor, String? keyword, bool withCount = false }) async {
    LogWidget.debug("load room from server!");

    LoadRoomsCommand command = LoadRoomsCommand(MeModel().playerId, limit, cursor: cursor, keyword: keyword, withCount: withCount);
    if (await DataService().request(command)) {
      LogWidget.debug("LoadRoomsCommand success");

      Map<String, dynamic> result = {};

      Map<String, RoomModel> roomMap = {};

      List<String> targetPlayerIds = [];

      command.rooms!.map((e) => RoomModel.fromMap(e)).forEach((element) {
        roomMap.putIfAbsent(element.roomId!, () => element);

        if(element.contact != null)
          targetPlayerIds.add(element.contact!.playerId);
      });

      ContactManager().onlinePlayerStatusMap.value.addAll(await ContactManager().loadOnlineStatusContacts(targetPlayerIds));

      result.putIfAbsent("room", () => roomMap);
      result.putIfAbsent("cursor", () => command.cursor);
      if(withCount)
        result.putIfAbsent("totalCount", () => command.totalCount);

      return result;
    } else {
      LogWidget.debug("LoadRoomsCommand failed");

      return null;
    }
  }

  Future<bool> unblockRoom(String roomId) async {
    UnblockRoomsCommand command = UnblockRoomsCommand(MeModel().playerId!, roomId);
    if(await DataService().request(command) == true) {
      RoomManager().activeRoomIdList.add(roomId);
      RoomManager().blockedRoomIdList.remove(roomId);

      LogWidget.debug("UnblockRoomsCommand success!!");
      getUnreadRoom();
      return true;
    }

    LogWidget.debug("UnblockRoomsCommand failed!!");
    return false;
  }

  /*void goRoomByLink(String targetPlayerId) async {

    if(targetPlayerId == MeModel().playerId) {
      SquareDefaultDialog.showSquareDialog(
        showShadow: true,
        title: L10n.popup_09_do_not_myself_chat_title,
        content: Text(L10n.popup_10_do_not_myself_chat_content, textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
        button1Text: L10n.common_02_confirm,
      );
      return;
    }
    
    String roomId = ContactModel.makeTwinRoomId(targetPlayerId);

    RoomModel? room = await getTwinRoom(roomId);

    if(room == null) {

      ContactModel? contactModel = await ContactModelPool().searchPlayerByPlayerId(MeModel().playerId!, targetPlayerId);

      if(contactModel?.relationshipStatus == RelationshipStatus.blocked) {
        SquareDefaultDialog.showSquareDialog(
          showShadow: true,
          title: L10n.popup_09_do_not_myself_chat_title,
          content: Text(L10n.popup_11_do_not_reach_link(contactModel!.smallerName), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
          button1Text: L10n.common_03_cancel,
          button1Action: SquareDefaultDialog.closeDialog(),
          button2Text: L10n.common_02_confirm,
          button2Action: () {
            SquareDefaultDialog.closeDialog().call();

            BlocManager.getBloc<BlockedContactsBloc>()!.add(UnblockContactEvent(MeModel().playerId!, targetPlayerId, successFunc: () {
              BlocManager.getBloc<ChatPageBloc>()?.add(Update());

              Future.delayed(Duration(milliseconds: 1000), () {
                BlocManager.getBloc<RoomsBloc>()!.add(OpenRoomEvent(roomId));
              });

              SquareRoomDialog.showAddContactOverlay(contactModel.playerId, contactModel.smallerName, successFunc: (contact) {
                RoomManager().updateChatPage(contactModel: contact);
              });

            }));
          }
        );
        return;
      }

      BlocManager.getBloc<RoomsBloc>()?.add(OpenRoomByLinkEvent(roomId: roomId));
    } else {
      if(room.isBlocked) {
        SquareDefaultDialog.showSquareDialog(
          showShadow: true,
          title: L10n.popup_09_do_not_myself_chat_title,
          content: Text(L10n.popup_11_do_not_reach_link(room.smallerSearchName ?? ""), textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
          button1Text: L10n.common_03_cancel,
          button1Action: SquareDefaultDialog.closeDialog(),
          button2Text: L10n.common_02_confirm,
          button2Action: () {
            SquareDefaultDialog.closeDialog().call();

            BlocManager.getBloc<BlockedContactsBloc>()!.add(UnblockContactEvent(MeModel().playerId!, targetPlayerId, successFunc: () {
              BlocManager.getBloc<ChatPageBloc>()?.add(Update());

              Future.delayed(Duration(milliseconds: 1000), () {
                BlocManager.getBloc<RoomsBloc>()!.add(OpenRoomEvent(roomId));
              });

              SquareRoomDialog.showAddContactOverlay(targetPlayerId, room.searchName!, successFunc: (contact) {
                RoomManager().updateChatPage(contactModel: contact);
              });

            }));
          }
        );
        return;
      } else if(room.isArchived) {
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(OpenArchivedRoomByLinkEvent(room));
        return;
      } else {
        BlocManager.getBloc<RoomsBloc>()?.add(OpenRoomByLinkEvent(room: room));
      }
    }
  }*/

  Future<bool> sayMessage(MessageModel messageModel, RoomModel roomModel) async {
    messageModel.sendCompleter = Completer<bool>();
    final oldMessageManagerKey = messageModel.messageManagerKey;

    SayCommand command = SayCommand(messageModel, roomMemberIds: roomModel.isInactive ? roomModel.members.map((e) => e.playerId!).toList() : null);
    if(await DataService().request(command)) {
      LogWidget.debug("SayCommand success");
      ChatMessageManager().changeMessage(oldMessageManagerKey!, messageModel.messageManagerKey!);
      roomModel.me?.lastReadTime = messageModel.sendTime;
      roomModel.updateLastMsg(messageModel);
      String roomId;
      if(!RoomManager().globalRoomMap.containsKey(messageModel.roomId)) {
        roomModel.status = "active";
        roomId = messageModel.roomId!;

        globalRoomMap.putIfAbsent(roomId, () => getRoomMap(roomId, [messageModel.toMap()]));
        activeRoomIdList.add(roomId);
      } else {
        roomId = roomModel.roomId!;
        RoomManager().globalRoomMap[roomId]["messages"].add(messageModel.toMap());
        RoomManager().globalRoomMap[roomId]["lastMsgTime"] = messageModel.sendTime;
        RoomManager().globalRoomMap[roomId]["lastMsg"] = messageModel.toMap();
      }


      if (roomModel.isArchived) {
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(SayMessageArchivedRoom(roomModel));
      } else {
        BlocManager.getBloc<RoomsBloc>()?.add(SayMessageRoom(roomModel));
      }

      return true;
    } else {
      LogWidget.debug("SayCommand failed");
      return false;
    }
  }

  Future<MessageModel?> loadAfterLastMsgTimeFromServer(String roomId, int? baseCursorTime, { bool backward = false, bool? setReadTime }) async {

    int limit = 25;
    //TODO: command backward 변경후에 !backward 수정해야됨 : backward
    GetMessagesCommand command = GetMessagesCommand(roomId, baseCursorTime, limit, setReadTime, !backward);
    if (await DataService().request(command)) {
      LogWidget.debug("GetMessagesCommand success!!!");
      LogWidget.debug("current message bloc : ${RoomManager().currentMessageBloc}");

      if(RoomManager().currentChatRoom?.roomId == roomId)
        RoomManager().currentMessageBloc?.add(ReceivedMessage(messages: command.messages));

      command.messages?.forEach((element) {
        if(element.messageType == MessageType.link) {
          ChatMessageManager().changeLinkMessageModel(element.messageManagerKey!, element);
        }
      });

      return command.lastMessage;
    } else {
      LogWidget.debug("GetMessagesCommand fail!!!");
      return null;
    }
  }

  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
      FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<RoomModel?> makeRoom(List<String?> playerIds) async {
    CreateTwinRoomCommand command = CreateTwinRoomCommand(MeModel().playerId!, playerIds);
    if(await DataService().request(command)) {
      LogWidget.debug("CreateRoomCommand success!!!");

      return command.roomModel;
    } else {
      LogWidget.debug("CreateRoomCommand failed!!!");

      return null;
    }
  }

  Future<List<RoomMemberModel>?> getTwinRoomMembers(String roomId) async {
    GetTwinRoomMembersCommand command = GetTwinRoomMembersCommand(roomId);
    if(await DataService().request(command)) {
      LogWidget.debug("GetTwinRoomMembersCommand success!!!");

      return command.roomMembers;
    } else {
      LogWidget.debug("GetTwinRoomMembersCommand fail!!!");

      return null;
    }
  }

  Future<RoomModel?> getTwinRoom(String roomId) async {
    GetRoomCommand command = GetRoomCommand(roomId);
    if(await DataService().request(command)) {
      LogWidget.debug("twin Room getRoomCommand success!!!");

      ContactManager().updateContact(command.roomModel!.contact!.playerId, command.roomModel!.searchName, profileImgUrl: command.roomModel!.targetProfileImgUrl);
      updateTargetRoomMember(command.roomModel!.contact!, command.roomModel!.searchName, profileImgUrl: command.roomModel!.targetProfileImgUrl);
    } else {
      LogWidget.debug("twin Room getRoomCommand fail!!!");
    }

    return command.roomModel;
  }

  Future<bool> typingForTwinRoom(String roomId, bool isTyping) async {

    String targetPlayerId = getTargetPlayerIdFromTwinRoomId(roomId);

    TypingForTwinRoomCommand command = TypingForTwinRoomCommand(MeModel().playerId!, targetPlayerId, roomId, isTyping);
    if(await DataService().request(command)) {
      LogWidget.debug("TypingForTwinRoomCommand success!!!");

      return true;
    } else {
      LogWidget.debug("TypingForTwinRoomCommand failed!!!");

      return false;
    }
  }

  Future<Map<String, dynamic>?> loadBlockedRoomsFromServer(int limit, { int? cursor, String? keyword, bool withCount = false }) async {
    LogWidget.debug("load blocked room from server!");

    LoadBlockedRoomsCommand command = LoadBlockedRoomsCommand(MeModel().playerId, limit, cursor: cursor, keyword: keyword, withCount: withCount);
    if (await DataService().request(command)) {
      LogWidget.debug("LoadBlockedRoomsCommand success");

      Map<String, dynamic> result = {};

      Map<String, RoomModel> roomMap = {};
      command.blockedRooms!.map((e) => RoomModel.fromMap(e)).forEach((element) {
        roomMap.putIfAbsent(element.roomId!, () => element);
      });

      result.putIfAbsent("room", () => roomMap);
      result.putIfAbsent("cursor", () => command.cursor);
      if(withCount)
        result.putIfAbsent("totalCount", () => command.totalCount);

      return result;
    } else {
      LogWidget.debug("LoadBlockedRoomsCommand failed");

      return null;
    }
  }

  // Future<int> getUnreadCount(String playerId, String roomId) async {
  //   LogWidget.debug("load blocked room from server!");
  //
  //   GetUnreadCountRoomCommand command = GetUnreadCountRoomCommand(playerId, roomId);
  //   if (await DataService().request(command)) {
  //     LogWidget.debug("GetUnreadCountRoomCommand success");
  //
  //     return command.unreadCount ?? 0;
  //   } else {
  //     LogWidget.debug("GetUnreadCountRoomCommand failed");
  //
  //     return 0;
  //   }
  // }

  List<RoomModel> sortedRooms(List<RoomModel> rooms) {

    List<RoomModel> filteredRooms = rooms.where((element) {
      if (element.roomId == null) return false;
      return true;
    }).toList();

    filteredRooms.sort((a, b) {
      if((a.status == 'temp' && b.status != 'temp')) {
        return -1;
      } else if((b.status == 'temp' && a.status != 'temp')) {
        return 1;
      }

      if (a.lastMsgTimeOrRegTime != null && b.lastMsgTimeOrRegTime != null)
        return b.lastMsgTimeOrRegTime!.compareTo(a.lastMsgTimeOrRegTime!);
      return -1;
    });

    return filteredRooms;
  }

  void receivedMessageByOnlinePush(MessageModel message) async {

    // 내가 대화방안에 있을경우
    if (RoomManager().currentChatRoom?.roomId == message.roomId) {
      
      bool isBlocked = RoomManager().currentChatRoom!.isBlocked;
      bool isArchived = RoomManager().currentChatRoom!.isArchived;

      if(isBlocked)
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReceivedBlockedRoomMessageOnlinePush(message, isInRoom: true));
      else if(isArchived)
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReceivedArchivedRoomMessageOnlinePush(message, isInRoom: true));
      else
        BlocManager.getBloc<RoomsBloc>()?.add(ReceivedRoomMessageOnlinePush(message, isInRoom: true));
    } else {

      if(message.status == MessageStatus.aiSaying)
        return;

      if(BlocManager.getBloc<RoomsBloc>()?.state is RoomsLoaded &&
          (BlocManager.getBloc<RoomsBloc>()?.state as RoomsLoaded).roomMap.containsKey(message.roomId)) {
        BlocManager.getBloc<RoomsBloc>()?.add(ReceivedRoomMessageOnlinePush(message, isInRoom: false));
        return;
      } else if(BlocManager.getBloc<BlockedRoomsBloc>()?.state is BlockedRoomsLoaded &&
          (BlocManager.getBloc<BlockedRoomsBloc>()?.state as BlockedRoomsLoaded).roomMap.containsKey(message.roomId)) {
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReceivedBlockedRoomMessageOnlinePush(message, isInRoom: false));
        return;
      } else if(BlocManager.getBloc<ArchivedRoomsBloc>()?.state is ArchivedRoomsLoaded &&
          (BlocManager.getBloc<ArchivedRoomsBloc>()?.state as ArchivedRoomsLoaded).roomMap.containsKey(message.roomId)) {
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReceivedArchivedRoomMessageOnlinePush(message, isInRoom: false));
        return;
      }

      RoomModel? room = await RoomManager().getTwinRoom(message.roomId!);
      int? blockedTime;
      if(room != null)
        blockedTime = room.blockedTime;

      if(room == null || room.isInactive)
        room = await RoomManager().makeRoom([MeModel().playerId, RoomManager().getTargetPlayerIdFromTwinRoomId(message.roomId!)]);

      room!.blockedTime = blockedTime;

      if(room.isBlocked) {
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(AddBlockedRoom(room, moveFolder: false));
      } else if(room.isArchived) {
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(AddArchivedRoom(room, moveFolder: false));
      } else {
        BlocManager.getBloc<RoomsBloc>()?.add(AddRoom(room, moveFolder: false));
      }
    }
  }

  String getTwinRoomId(String playerId, String targetPlayerId) {
    List<String> twinPlayerIds = [playerId, targetPlayerId]..sort();
    return "TR:${twinPlayerIds.join(":")}";
  }


  void openTwinRoom(ContactModel contactModel) async {
    RoomModel? room = await getTwinRoom(contactModel.twinRoomId!);
    if(room == null) {
      bool isAiChat = (contactModel.blockchainNetType == ChainNetType.ai);
      room = RoomModel.temp(roomId: contactModel.twinRoomId, isAiChat: isAiChat, searchName: contactModel.smallerName, contacts: [ contactModel, MeModel().contact! ], roomType: "twin",);
    }

    HomeNavigator.push(RoutePaths.chat.open, arguments: room, moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

    if(room != null) {
      if(!room.isInactive && room.isBlocked) {
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(AddBlockedRoom(room));
      } else if(!room.isInactive && room.isArchived) {
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(AddArchivedRoom(room));
      } else {
        BlocManager.getBloc<RoomsBloc>()?.add(AddRoom(room));
      }
    }
  }

  void updateTargetRoomMember(ContactModel contactModel, String? nickname, { String? profileImgUrl }) {
    String twinRoomId = contactModel.twinRoomId!;
    LogWidget.debug("updateTargetRoomMember start()");
    BlocManager.getBloc<RoomsBloc>()?.add(UpdateTargetRoomMember(twinRoomId, contactModel.playerId, nickname, profileImgUrl: profileImgUrl));
    BlocManager.getBloc<BlockedRoomsBloc>()?.add(UpdateTargetBlockedRoomMember(twinRoomId, contactModel.playerId, nickname, profileImgUrl: profileImgUrl));
    BlocManager.getBloc<ArchivedRoomsBloc>()?.add(UpdateTargetArchivedRoomMember(twinRoomId, contactModel.playerId, nickname, profileImgUrl: profileImgUrl));
  }

  Future<bool> archiveRoom(String roomId) async {
    ArchiveRoomCommand command = ArchiveRoomCommand(roomId);
    if(await DataService().request(command) == true) {
      LogWidget.debug("ArchiveRoomCommand success!!");
      RoomManager().archivedRoomIdList.add(roomId);
      RoomManager().activeRoomIdList.remove(roomId);

      getUnreadRoom();
      return true;
    }

    LogWidget.debug("ArchiveRoomCommand failed!!");
    return false;
  }

  Future<bool> unarchiveRoom(String roomId) async {
    UnarchiveRoomCommand command = UnarchiveRoomCommand(roomId);
    if(await DataService().request(command) == true) {
      RoomManager().activeRoomIdList.add(roomId);
      RoomManager().archivedRoomIdList.remove(roomId);

      LogWidget.debug("UnarchiveRoomCommand success!!");
      getUnreadRoom();
      return true;
    }

    LogWidget.debug("UnarchiveRoomCommand failed!!");
    return false;
  }

  Future<bool> getUnreadRoom() async {
    return true;
  }

  Future<Map<String, dynamic>?> loadArchivedRoomsFromServer(int limit, { int? cursor, String? keyword, bool withCount = false }) async {
    LogWidget.debug("load archived room from server!");

    LoadArchivedRoomsCommand command = LoadArchivedRoomsCommand(MeModel().playerId, limit, cursor: cursor, keyword: keyword, withCount: withCount);
    if (await DataService().request(command)) {
      LogWidget.debug("LoadArchivedRoomsCommand success");

      Map<String, dynamic> result = {};

      List<String> targetPlayerIds = [];

      Map<String, RoomModel> roomMap = {};
      command.archivedRooms!.map((e) => RoomModel.fromMap(e)).forEach((element) {
        roomMap.putIfAbsent(element.roomId!, () => element);

        if(element.contact != null)
          targetPlayerIds.add(element.contact!.playerId);
      });

      ContactManager().onlinePlayerStatusMap.value.addAll(await ContactManager().loadOnlineStatusContacts(targetPlayerIds));

      result.putIfAbsent("room", () => roomMap);
      result.putIfAbsent("cursor", () => command.cursor);
      if(withCount)
        result.putIfAbsent("totalCount", () => command.totalCount);

      return result;
    } else {
      LogWidget.debug("LoadArchivedRoomsCommand failed");

      return null;
    }
  }

  void updateChatPage({ContactModel? contactModel, RoomModel? roomModel}) {
    if(contactModel == null) {
      RoomManager().currentChatRoom?.updateChatPageByRoom(roomModel!);
    } else if(RoomManager().currentChatRoom?.roomId == contactModel.twinRoomId) {
      RoomManager().currentChatRoom?.updateChatPageByContact(contactModel);
      RoomManager().currentChatRoom?.isKnown = contactModel.friendTime != null;
    }

    BlocManager.getBloc<ChatPageBloc>()?.add(Update());
    currentMessageBloc?.add(ReloadMessage());
  }

  void popActionRoom() {
    LogWidget.debug("popActionRoom!!!!!");
    BlocManager.getBloc<RoomsBloc>()?.add(RemoveTempRoomsEvent());
    RoomManager().currentMessageBloc?.close();
    RoomManager().currentMessageBloc = null;
    RoomManager().currentChatRoom = null;
    EmoticonManager().clearEmoticonSprite();
    ChatMessageManager().clearCache();
    selectedRoomBloc.add(Update());
    BlocManager.getBloc<ShowEmoticonExampleBloc>()?.add(OffEvent());
  }

  Future<bool> resetAiHistory(String aiPlayerId) async {
    ResetAiHistoryRoomCommand command = ResetAiHistoryRoomCommand(aiPlayerId);
    if(await DataService().request(command)) {

      currentMessageBloc?.add(FetchMessage(false, reload: true));

      return true;
    }

    return false;
  }
}