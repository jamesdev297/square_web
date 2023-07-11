import 'dart:async';
import 'dart:typed_data';

import 'package:highlight/languages/q.dart';
import 'package:intl/intl.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/command/command.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/dao/http_dao.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/squarepacket.dart';
import 'package:square_web/service/room_manager.dart';



class CreateTwinRoomCommand extends WsCommand {
  String? playerId;
  List<String?> roomMemberIds;
  RoomModel? roomModel;

  CreateTwinRoomCommand(this.playerId, this.roomMemberIds);

  @override
  String getUri() => Uris.room.createTwinRoom;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "roomMemberIds": roomMemberIds,
      }));
    return false;
    if(!await processRequest(packet)) {
      return false;
    }

    roomModel = RoomModel.fromMap(this.content["room"]);
    return true;
  }
}

// class GetUpdatedRoomsCommand extends WsCommand {
//   String? playerId;
//   String? cursor;
//   int limit;
//   int lastRoomModTime;
//
//   int? refreshTime;
//
//   GetUpdatedRoomsCommand(this.playerId, this.lastRoomModTime, this.cursor, this.limit);
//
//   @override
//   String getUri() => Uris.room.getUpdatedRoom;
//
//   @override
//   Future<bool> execute() async {
//     var packet = SquarePacket(
//         uri: getUri(),
//         body: JsonMap({
//           "playerId": playerId,
//           "lastRoomModTime": lastRoomModTime,
//           "cursor": cursor,
//           "limit": limit,
//         }));
//     if(!await processRequest(packet)) {
//       return false;
//     }
//
//     cursor = this.content["cursor"];
//     refreshTime = this.content["refreshTime"];
//
//     List<dynamic> rooms = this.content["rooms"];
//     List<RoomModel> roomModels = rooms.map((e) => RoomModel.fromMap(e)).toList();
//     for(RoomModel room in roomModels) {
//       // LogWidget.info("async message call! / roomId: ${room.roomId}");
//       // LogWidget.info("command on room : ${room.toJson()}");
//       RoomManager().addRoom(room);
//       // LogWidget.debug("room read ${room.roomId} / ${room.regTime} /");
//       // await RoomManager().loadNewMessageFromServer(room);
//     }
//
//     return true;
//   }
//
// }

class GetRoomCommand extends WsCommand {
  String? roomId;
  RoomModel? roomModel;
  GetRoomCommand(this.roomId);

  @override
  String getUri() => Uris.room.get;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "roomId": roomId,
      }));

    var temp = RoomManager().globalRoomMap[roomId!];
    if(temp != null) {
      roomModel = RoomModel.fromMap(temp);
      return true;
    }
    return false;

    if(!await processRequest(packet)) {
      return false;
    }

    dynamic room = this.content["room"];

    if(room == null)
      return false;

    roomModel = RoomModel.fromMap(room);
    LogWidget.info("getRoomCommand roomModel : ${roomModel!.toJson()}");
    return true;
  }
}

class UploadVideoCommand extends WsCommand {
  Uint8List? video;
  String? videoFormat;
  String? roomId;

  UploadVideoCommand({this.video, this.videoFormat = "mp4", this.roomId});

  String? uploadedUrl;

  @override
  String getUri() => Uris.room.uploadVideo;

  @override
  Future<bool> execute() async {
    if (video == null) {
      LogWidget.debug("video is null");
      return false;
    }

    var packet = SquarePacket(uri: getUri(), body: JsonMap({"playerId": "${MeModel().playerId}", "roomId": "$roomId"}));
    return false;
    if (!await processRequest(packet)) {
      return false;
    }

    String putUrl = resPacket!.getContent().get("url");
    LogWidget.debug("url : $putUrl");

    List<Future> futures = [];
    futures.add(HttpDao().uploadMedia(putUrl, headers: { "Content-Type": "video/$videoFormat" }, body: this.video));

    return await Future.wait(futures).then((value) {
      if (value[0].status == 200) {
        uploadedUrl = resPacket!.getContent().get("uploadedUrl");
        return true;
      }
      return false;
    });
  }
}

class UploadImageCommand extends WsCommand {
  final String roomId;
  final Uint8List image;
  final Uint8List thImage;
  String mimeType;

  UploadImageCommand({ required this.roomId, required this.image, required  this.thImage, this.mimeType = "image/png" });

  String? uploadedUrl;
  String? uploadedThUrl;

  @override
  String getUri() => Uris.room.uploadImage;

  @override
  Future<bool> execute() async {

    var packet = SquarePacket(uri: getUri(), body: JsonMap({"playerId": "${MeModel().playerId}", "roomId": "$roomId"}));
    return false;

    if (!await processRequest(packet)) {
      return false;
    }

    String putUrl = resPacket!.getContent().get("url");
    String putThUrl = resPacket!.getContent().get("thUrl");
    LogWidget.debug("url : $putUrl, thUrl : $putThUrl");

    List<Future> futures = [];

    futures.add(HttpDao().uploadMedia(putUrl, headers: { "Content-Type": mimeType }, body: this.image));
    futures.add(HttpDao().uploadMedia(putThUrl, headers: { "Content-Type": mimeType }, body: this.thImage));

    return await Future.wait(futures).then((value) {
      if (value[0].status == 200 && value[1].status == 200) {
        uploadedUrl = resPacket!.getContent().get("uploadedUrl");
        uploadedThUrl = resPacket!.getContent().get("thUploadedUrl");
        return true;
      }
      return false;
    });
  }
}

class SayCommand extends WsCommand {
  MessageModel model;
  List<String>? roomMemberIds;
  SayCommand(this.model, { this.roomMemberIds });

  @override
  String getUri() => Uris.room.say;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "roomId": model.roomId,
        "playerId": model.sender!.playerId,
        "messageType" : model.messageType.name,
        if(model.messageBody != null)
          "messageBody": model.messageBody,
        if(model.thumbnailUrl != null)
          "thumbnailUrl": model.thumbnailUrl,
        if(model.fullContentUrl != null)
          "fullContentUrl": model.fullContentUrl,
        if(model.contentId != null)
          "contentId": model.contentId,
        if(roomMemberIds != null)
          "roomMemberIds": roomMemberIds,
        if(model.isAiChat != null)
          "isMsgToAi" : model.isAiChat
      })
    );

    model.sendCompleter?.complete(true);
    model.sendTime = DateTime.now().millisecondsSinceEpoch;
    model.status = MessageStatus.normal;
    return true;

    if(!WebsocketDao().isOpen() || !await processRequest(packet)) {
      model.sendCompleter?.complete(false);
      RoomManager().currentMessageBloc?.add(SendFailedMessage(model));
      return false;
    }

    model.sendCompleter?.complete(true);
    model.sendTime = this.content["sendTime"];
    model.status = MessageStatus.normal;

    return true;
  }
}


/*
class NewRoomCommand extends WsCommand {
  String playerId;
  RoomModel roomModel;
  NewRoomCommand(this.playerId, this.roomModel);

  @override
  String getUri() => "pepper_core://v1/inroom/newRoom";

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": "${playerId}",
          "roomMembers": this.roomModel.contacts,
        }));
    if(!await processRequest(packet)) {
      return false;
    }

    roomModel = RoomModel(map: this.content["room"]);
    await roomModel.loadRoomMembersNotFriend();
    RoomModelPool().add(roomModel, notify: true);

    List<Future> futures = [];
    futures.add(DbDao().updateRoom(roomModel));
    if (roomModel.roomType == twinType) {
      roomModel.contact.roomId = roomModel.roomId;
      futures.add(DbDao().updateFriend(roomModel.contact));
    }
    await Future.wait(futures);
    return true;
  }
}
*/

class LoadRoomsCommand extends WsCommand {
  String? playerId;
  bool withCount;
  int limit;
  int? cursor;
  String? keyword;
  int? totalCount;

  List<dynamic>? rooms;

  LoadRoomsCommand(this.playerId, this.limit, { this.cursor, this.keyword, this.withCount = false });

  @override
  String getUri() => Uris.profile.getRooms;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "limit": limit,
        if(cursor != null)
          "cursor": cursor,
        if(keyword != "" && keyword != null)
          "keyword": keyword,
        if(withCount == true)
          "withCount": true,
      }));

    rooms = RoomManager().activeRoomIdList.map((e) => RoomManager().globalRoomMap[e]).toList();
    totalCount = rooms!.length;
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    rooms = content["rooms"];
    totalCount = this.content["totalCount"];

    return true;
  }
}


class GetMessageCommand extends WsCommand {
  final String roomId;
  final String playerId;
  final int sendTime;
  MessageModel? message;
  GetMessageCommand(this.roomId, this.playerId, this.sendTime);

  @override
  String getUri() => Uris.room.message;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": playerId,
          "roomId": roomId,
          "sendTime": sendTime,
        }));
    if(!await processRequest(packet)) {
      return false;
    }
    dynamic messageMap = this.content["message"];
    if(messageMap != null) {
      message = MessageModel.fromMap(messageMap);
    }
    return true;
  }
}

class GetMessagesCommand extends WsCommand {
  final String roomId;
  final int? baseCursorTime;
  final int limit;
  final bool? setReadTime;
  final bool isForward;
  List<MessageModel>? messages;
  GetMessagesCommand(this.roomId, this.baseCursorTime, this.limit, this.setReadTime, this.isForward);

  int? lastMessageTime;
  MessageModel? lastMessage;

  @override
  String getUri() => Uris.room.messages;

  @override
  Future<bool> execute() async {

    LogWidget.debug("setReadTime/ ${RoomManager().currentChatRoom?.roomId} == ${roomId}");

    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": MeModel().playerId,
        "roomId": roomId,
        "baseSendTime": baseCursorTime,
        "limit": limit,
        "isForward": isForward,
        "setReadTime": setReadTime ?? RoomManager().currentChatRoom?.roomId == roomId,
      }));


    List<dynamic> roomMessages = RoomManager().globalRoomMap[roomId]?["messages"] ?? [];
    messages = [];
    roomMessages.forEach((element) {
      messages!.add(MessageModel.fromMap(element..putIfAbsent("roomId", () => roomId)));
    });
    return true;
    if(!await processRequest(packet)) {
      return false;
    }

    lastMessageTime = this.content["lastMsgTime"];

    List<dynamic> messageMapList = this.content["messages"];

    messages = MessageModel.getListFromMapList(messageMapList);
    Map<String, MessageModel> insertDates = {};

    messages!.removeWhere((message) {
      if(message.messageType == MessageType.skill) {
        return true;
      } else {
        String dateString = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(message.sendTime!));

        insertDates.putIfAbsent(dateString, () => MessageModel.dateSystemMessage(roomId, dateString: dateString));

        return false;
      }
    });

    if (messages!.isNotEmpty) {
      lastMessage = messages!.where((e) => e.status != MessageStatus.aiSaying).toList().last;
    }

    messages!.addAll(insertDates.values); //시간메세지 추가

    return true;
  }
}

class GetTwinRoomMembersCommand extends WsCommand {
  String roomId;
  List<RoomMemberModel> roomMembers = [];
  int? limit;

  GetTwinRoomMembersCommand(this.roomId, { this.limit = 2});

  @override
  String getUri() => Uris.room.members;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "roomId": roomId,
        "limit": limit
      }));
    if(!await processRequest(packet)) {
      return false;
    }

    dynamic members = content["members"];
    LogWidget.debug("members $members");

    members.forEach((element) {
      roomMembers.add(RoomMemberModel.fromMap(element));
    });

    return true;
  }
}

class TypingForTwinRoomCommand extends WsCommand {
  String playerId;
  String targetPlayerId;
  String roomId;
  bool isTyping;

  TypingForTwinRoomCommand(this.playerId, this.targetPlayerId, this.roomId, this.isTyping);

  @override
  String getUri() => Uris.room.typing;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "targetPlayerId": targetPlayerId,
        "roomId": roomId,
        "isTyping": isTyping
      }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class LoadBlockedRoomsCommand extends WsCommand {
  String? playerId;
  bool withCount;
  int limit;
  int? cursor;
  String? keyword;
  int? totalCount;

  List<dynamic>? blockedRooms;

  LoadBlockedRoomsCommand(this.playerId, this.limit, { this.cursor, this.keyword, this.withCount = false });

  @override
  String getUri() => Uris.profile.getBlockedRooms;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        if(cursor != null)
          "cursor": cursor,
        if(keyword != "" && keyword != null)
          "keyword": keyword,
        if(withCount == true)
          "withCount": true,
        "limit": limit,
      }));

    blockedRooms = RoomManager().blockedRoomIdList.map((e) => RoomManager().globalRoomMap[e]).toList();
    totalCount = blockedRooms!.length;
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    blockedRooms = content["rooms"];
    totalCount = this.content["totalCount"];
    return true;
  }
}

class LoadArchivedRoomsCommand extends WsCommand {
  String? playerId;
  bool withCount;
  int limit;
  int? cursor;
  String? keyword;
  int? totalCount;

  List<dynamic>? archivedRooms;

  LoadArchivedRoomsCommand(this.playerId, this.limit, { this.cursor, this.keyword, this.withCount = false });

  @override
  String getUri() => Uris.profile.getArchivedRooms;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        if(cursor != null)
          "cursor": cursor,
        if(keyword != "" && keyword != null)
          "keyword": keyword,
        if(withCount == true)
          "withCount": true,
        "limit": limit,
      }));

    archivedRooms = RoomManager().archivedRoomIdList.map((e) => RoomManager().globalRoomMap[e]).toList();
    totalCount = archivedRooms!.length;
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    archivedRooms = content["rooms"];
    totalCount = this.content["totalCount"];

    return true;
  }
}

class GetUnreadCountRoomCommand extends WsCommand {
  String playerId;
  String roomId;
  int? unreadCount;

  GetUnreadCountRoomCommand(this.playerId, this.roomId);

  @override
  String getUri() => Uris.profile.unreadCount;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "roomId": roomId,
      }));

    unreadCount = 0;
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    unreadCount = content["unreadCount"];

    return true;
  }
}

class UnblockRoomsCommand extends WsCommand {
  String playerId;
  String roomId;

  UnblockRoomsCommand(this.playerId, this.roomId);

  @override
  String getUri() => Uris.room.unblockBlocked;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": this.playerId,
          "roomId" : this.roomId,
        }));
    return true;
    if(!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class ArchiveRoomCommand extends WsCommand {
  String roomId;

  ArchiveRoomCommand(this.roomId);

  @override
  String getUri() => Uris.room.archive;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "roomId" : this.roomId,
      }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}


class UnarchiveRoomCommand extends WsCommand {
  String roomId;

  UnarchiveRoomCommand(this.roomId);

  @override
  String getUri() => Uris.room.unarchive;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "roomId" : this.roomId,
      }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class ResetAiHistoryRoomCommand extends WsCommand {

  final String aiPlayerId;
  ResetAiHistoryRoomCommand(this.aiPlayerId);

  @override
  String getUri() => Uris.room.resetAiHistory;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "aiPlayerId" : aiPlayerId,
        }));
    return false;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}


