import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/room_manager.dart';

import 'bloc_manager.dart';


typedef ProcessCommandCallback = void Function(String?, String?, Map<String, dynamic>?);

class PushManager {
  static final PushManager _instance = PushManager._internal();

  factory PushManager() => _instance;
  PushManager._internal();


  Future<void> init(VoidCallback _callNowLinkAction) async {
    // tz.initializeTimeZones();

  }

  void _processFriendCommand(String? targetId, String? cmd, Map<String, dynamic>? data) async {
    switch(cmd) {
      case "isOnline":
        if(targetId == null || data == null || data["showOnlineStatus"] == null)
          return;

        BlocManager.getBloc<ContactsBloc>()?.add(UpdateOnlineContactEvent(targetId, data["showOnlineStatus"] as bool));
    }
  }

  void _processRoomCommand(String? targetId, String? cmd, Map<String, dynamic>? data) async {
    switch(cmd) {
      case "reload":
        LogWidget.debug("room reload: $data, $targetId");

        if(data?["message"] != null) {
          MessageModel message = MessageModel.fromMap(data!["message"]);

          if (message.roomId!.startsWith("TR")) {
            RoomManager().receivedMessageByOnlinePush(message);
          }
        }

        if(targetId != null && targetId.startsWith("TR")) {
          if (RoomManager().currentChatRoom?.roomId == targetId) {
            BlocManager.getBloc<RoomsBloc>()?.add(UpdateRoomMembers(targetId));
          }
        }
        break;

      case "typing":
        if (RoomManager().currentChatRoom?.roomId == targetId && !(RoomManager().currentChatRoom?.isAiChat == true)) {
          RoomManager().currentMessageBloc?.add(TypingMessage(targetPlayerId: data?["senderId"], isTyping: data?["isTyping"] ?? false));
        }
        break;
    }
  }

  void _processProfileCommand(String? targetId, String? cmd, Map<String, dynamic>? data) async {
    LogWidget.debug("targetId: $targetId / cmd: $cmd / data: $data");
    switch(cmd) {
      case "emailVerified":
        MeModel().isEmailVerified.value = true;
        break;
    }
  }

  // Future<void> _addToSkillStream(List<FriendsSkillModel> list, Duration totalDuration) async {
  //   int interval = (totalDuration.inMicroseconds / list.length / 5).round();
  //   for(int i=0; i<list.length; ++i) {
  //     await Future.delayed(Duration(microseconds: i*interval), () => SkillManager().friendsSkillStreamController.add(list[i]));
  //     //TODO: 홈스크린 정리하면서 홈스크린 없어졋을때(재시작) 처리필요
  //   }
  // }


  Map<String, ProcessCommandCallback>? onlinePushWorkerMap;
  Future<void> receivedPushOnline(String? cmd, String? target, String? targetId, Map<String, dynamic>? data) async {
    LogWidget.debug("cmd: $cmd, target: $target, targetId: $targetId");
    if(onlinePushWorkerMap == null) {
      onlinePushWorkerMap = {
        "friend": _processFriendCommand,
        "room": _processRoomCommand,
        "profile": _processProfileCommand,
      };
    }
    onlinePushWorkerMap![target!]?.call(targetId, cmd, data);
  }

  static Future<dynamic> onPush(Map<String, dynamic> data) {
    LogWidget.debug('onPush: $data');
    return Future.value();
  }

}

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
