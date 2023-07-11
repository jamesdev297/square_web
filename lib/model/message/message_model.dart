import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/player_model.dart';
import 'package:square_web/util/enum_util.dart';
import 'package:square_web/widget/locale_date.dart';

enum MessageType {
  text,
  image,
  video,
  system,
  emoticon,
  link,
  markdown,
  skill,
  typing
}

class ConstMsgContentId {

  static const String notKnown = "notKnown";
  static const String notSignedUp = "notSignedUp";
  static const String seen = "seen";

  //from server
  static const String memberInvited = "member/invited";
  static const String memberJoined = "member/joined";
  static const String memberLeft = "member/left";
  static const String date = "date";
  static const String resetAiHistory = "ai/history/reset";
  static const String changeAi = "ai/member/change";
}

enum MessageStatus { normal, removed, removedForMe, sendFailed, restricted, aiSaying, aiLimitReached }

enum MessageSender { me, friend }

enum MediaDownloadStatus { init, downloading, done, error }

class MessageModel {
  static SplayTreeSet<MessageModel> get initialSortedSet => SplayTreeSet(((a,b) {
    int sendTimeDiff = b.sendTime! - a.sendTime!;
    if(sendTimeDiff != 0)
      return sendTimeDiff;
    return (b.sender?.playerId.hashCode ?? 1) - (a.sender?.playerId.hashCode ?? 0);
  }));

  Player? sender;
  String? playerId;
  String? roomId;
  int? sendTime;
  bool? isAiChat;
  String? _localTimeStr;

  String? get localTimeStr {

    if(messageType == MessageType.typing)
      return null;

    return _localTimeStr ??=
    this.sendTime != null ? "${LocaleDate().expressionMsgTime(this.sendTime, onlyTime: true)}" : null;
  }

  String get messageId => "$roomId:${sender!.playerId}:$sendTime";
  String? _messageManagerKey;
  String? get messageManagerKey {
    return "${sender!.playerId}:$sendTime";
  }

  final Map<String, dynamic> msgCache = {};

  MessageSender get messageSender => sender!.playerId == MeModel().playerId ? MessageSender.me : MessageSender.friend;

  MessageType messageType;
  String? thumbnailUrl;
  String? fullContentUrl;
  String? contentId;
  String? messageBody;
  StreamController<MediaDownloadStatus> mediaDownloadController = BehaviorSubject();

  MessageDelegateBloc messageUpdateBloc = MessageDelegateBloc();
  MessageStatus? status = MessageStatus.normal;
  Completer<bool>? sendCompleter;

  bool hasAnimation = false;

  MessageModel(
      {this.sender,
      this.roomId,
      int? regTime,
      this.thumbnailUrl,
      this.fullContentUrl,
      this.contentId,
      this.isAiChat,
      this.messageBody,
      required this.messageType,
      this.status,
      bool withoutCompleter = false
      }) {
    if (regTime != null) this.sendTime = regTime;
    this.sendTime ??= DateTime.now().millisecondsSinceEpoch;

    this.localTimeStr;
    this.playerId = sender!.playerId;

    if(!withoutCompleter)
      this.sendCompleter = Completer<bool>();

    assert(this.sender != null);
    assert(this.sendTime != null);
  }

  MessageModel.copyWithSendTime(MessageModel messageModel, this.sendTime)
      : this.messageType = messageModel.messageType,
        this.roomId = messageModel.roomId,
        this.playerId = messageModel.playerId,
        this.messageBody = messageModel.messageBody,
        this.status = messageModel.status,
        this.fullContentUrl = messageModel.fullContentUrl,
        this.hasAnimation = messageModel.hasAnimation,
        this.sender = messageModel.sender,
        this.contentId = messageModel.contentId,
        this.thumbnailUrl = messageModel.thumbnailUrl;

  MessageModel.fromMap(Map<String, dynamic> map, { isLastMsg = false })
      : this.roomId = map["roomId"],
        this.sendTime = map["sendTime"],
        this.playerId = map["playerId"],
        this.messageType = MessageType.values.byName(map["messageType"]),
        this.thumbnailUrl = map["thumbnailUrl"],
        this.fullContentUrl = map["fullContentUrl"],
        this.contentId = map["contentId"],
        this.messageBody = map["messageBody"],
        this.status = EnumUtil.valueOf(MessageStatus.values, map["status"] ?? "normal") {

    if(status == MessageStatus.aiSaying)
      this.messageBody = this.messageBody?.replaceFirst('...', '');

    if(isLastMsg == false) {
      this.sender = ContactModelPool().getPlayerContact(map["playerId"]).player;
      assert(this.sender != null);
    }

    assert(this.sendTime != null);
  }

  MessageModel.dateSystemMessage(String? roomId, {int? sendTime, String? dateString})
      : this.sender = Player.SquareSys(),
        this.roomId = roomId,
        this.messageType = MessageType.system,
        this.contentId = ConstMsgContentId.date {
    assert(sendTime != null || dateString != null);

    if (dateString == null && sendTime != null)
      dateString = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(sendTime));

    int value = DateTime.parse(dateString!).millisecondsSinceEpoch;
    this.sendTime = value;
    this.messageBody = value.toString();
  }

  String? getSubtitle() {
    // LogWidget.info(this.messageBody);
    switch (this.messageType) {
      case MessageType.text:
      case MessageType.link:
      case MessageType.markdown:
        return this.messageBody?.characters.replaceAll(Characters(''), Characters('\u{200B}')).toString();

      case MessageType.emoticon:
        return L10n.common_10_sent_emoji;

      case MessageType.image:
        return L10n.common_11_sent_image;

      case MessageType.video:
        return L10n.common_12_sent_video;

      case MessageType.system:
        // if(this.contentId == ConstMsgContentId.resetAiHistory)
        //   return L10n.system_message_01_reset_ai_history(ContactModelPool().getPlayerContact(playerId).name);

        return "";
      default:
        return "";
    }
  }

  static List<MessageModel> getListFromMapList(List<dynamic> messageMapList) {
    List<MessageModel> result = [];
    messageMapList.forEach((element) {
      try {
        result.add(MessageModel.fromMap(element));
      } catch (e, stacktrace) {
        LogWidget.error("MessageModel.getListFromMapList Err $e\n$stacktrace");
      }
    });
    return result;
  }

  static String getAiTypingCursorKey(String playerId, String roomId) {

    if(roomId.startsWith('ai-') == true) {
      roomId = roomId.replaceFirst('ai-', '');
      return roomId.split('_')[0];
    } else if(roomId.startsWith('TR') == true) {
      List<String> splitIds = roomId.split(':');

      return splitIds[1] == playerId ? splitIds[2] : splitIds[1];
    }

    return '';
  }

  bool isInvalid() {
    if (messageBody == null) return true;
    if (messageBody!.isEmpty) return true;

    return false;
  }

  dynamic toMap() {
    return {
      "playerId" : sender?.playerId,
      "status" : status?.name,
      "messageType" : messageType.name,
      "messageBody" : messageBody,
      "sendTime" : sendTime,
      "contentId" : contentId
    };
  }

  @override
  String toString() {
    return "{roomId: ${this.roomId} / playerId: ${this.sender?.playerId} / sendTime: ${this.sendTime} / messageType: ${this.messageType} / body: ${this.messageBody}" +
        (this.thumbnailUrl != null ? " / thumbnailUrl: ${this.thumbnailUrl}" : "") +
        (this.fullContentUrl != null ? " / fullContentUrl: ${this.fullContentUrl}" : "") +
        (this.contentId != null ? " / contentId: ${this.contentId}" : "") +
        " / status: ${this.status}}";
  }
}

class SquareChatMsgModel extends MessageModel {
  static SplayTreeSet<SquareChatMsgModel> get initialSortedSet => SplayTreeSet(((a,b) {
    int sendTimeDiff = b.sendTime! - a.sendTime!;
    if(sendTimeDiff != 0)
      return sendTimeDiff;
    return (b.sender?.playerId.hashCode ?? 1) - (a.sender?.playerId.hashCode ?? 0);
  }));

  String? squareId;
  String? channelId;
  int? receivedTime;

  SquareChatMsgModel(
      { required this.squareId,
        required this.channelId,
        Player? sender,
        int? regTime,
        String? thumbnailUrl,
        String? fullContentUrl,
        String? contentId,
        String? messageBody,
        required MessageType messageType,
        MessageStatus? status})
      : super(
      sender: sender,
      regTime: regTime,
      thumbnailUrl: thumbnailUrl,
      fullContentUrl: fullContentUrl,
      contentId: contentId,
      messageBody: messageBody,
      messageType: messageType,
      status: status) {
    if (regTime != null) this.sendTime = regTime;
    super.sendTime ??= DateTime.now().millisecondsSinceEpoch;

    this.roomId = "${squareId}_${channelId}";
    this.localTimeStr;

    assert(this.sender != null);
    assert(this.sendTime != null);
  }

  SquareChatMsgModel.copyWithSendTime(SquareChatMsgModel messageModel, int? sendTime)
      : super(messageType : messageModel.messageType,
      messageBody : messageModel.messageBody,
      status : messageModel.status,
      fullContentUrl : messageModel.fullContentUrl,
      sender : messageModel.sender,
      contentId : messageModel.contentId,
      thumbnailUrl : messageModel.thumbnailUrl) {
    this.squareId = messageModel.squareId;
    this.channelId = messageModel.channelId;
    this.hasAnimation = messageModel.hasAnimation;
    super.sendTime = sendTime;
    this.roomId = "${squareId}_${channelId}";
  }

  SquareChatMsgModel.fromMap(Map<String, dynamic> map)
      : super(messageType : MessageType.values.byName(map["messageType"]),
      regTime: map["sendTime"],
      thumbnailUrl : map["thumbnailUrl"],
      fullContentUrl : map["fullContentUrl"],
      contentId : map["contentId"],
      messageBody : map["messageBody"],
      status : EnumUtil.valueOf(MessageStatus.values, map["status"] ?? "normal"),
      sender : ContactModelPool().getPlayerContact(map["playerId"]).player) {
    assert(this.sender != null);
    this.squareId = map["squareId"];
    this.channelId = map["channelId"];
    this.receivedTime = map['receivedTime'];
    this.roomId = "${squareId}_${channelId}";
    assert(this.sendTime != null);
  }

  SquareChatMsgModel.dateSystemMessage(this.squareId, this.channelId, {int? sendTime, String? dateString})
      : super(
      sender : Player.SquareSys(),
      messageType : MessageType.system,
      contentId : ConstMsgContentId.date) {
    assert(sendTime != null || dateString != null);

    if (dateString == null && sendTime != null)
      dateString = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(sendTime));

    int value = DateTime.parse(dateString!).millisecondsSinceEpoch;
    this.roomId = "${squareId}_${channelId}";
    super.sendTime = value;
    this.messageBody = value.toString();
  }

  static Set<SquareChatMsgModel> getDateSystemMsgSet(Iterable<SquareChatMsgModel> messages) {
    return messages.map((e) =>
        SquareChatMsgModel.dateSystemMessage(e.squareId, e.channelId, sendTime: e.sendTime)).toSet();
  }

  static List<SquareChatMsgModel> getListFromMapList(List<dynamic> messageMapList) {
    List<SquareChatMsgModel> result = [];
    messageMapList.forEach((element) {
      try {
        result.add(SquareChatMsgModel.fromMap(element));
      } catch (e, stacktrace) {
        LogWidget.error("SquareChatMsgModel.getListFromMapList Err $e\n$stacktrace");
      }
    });
    return result;
  }

  static Map<String, SquareChatMsgModel> getAiMapListFromList(List<dynamic> messageMapList) {
    Map<String, SquareChatMsgModel> result = {};
    messageMapList.forEach((element) {
      try {
        SquareChatMsgModel model = SquareChatMsgModel.fromMap(element);
        result.putIfAbsent(model.messageId, () => model);
      } catch (e, stacktrace) {
        LogWidget.error("SquareChatMsgModel.getListFromMapList Err $e\n$stacktrace");
      }
    });
    return result;
  }

}

class OpenChatMsgModel extends MessageModel {
  static SplayTreeSet<OpenChatMsgModel> get initialSortedSet => SplayTreeSet(((a,b) {
    int sendTimeDiff = b.sendTime! - a.sendTime!;
    if(sendTimeDiff != 0)
      return sendTimeDiff;
    return (b.sender?.playerId.hashCode ?? 1) - (a.sender?.playerId.hashCode ?? 0);
  }));

  String? lang;
  int? channel;

  OpenChatMsgModel(
      {this.lang,
      this.channel,
      Player? sender,
      int? regTime,
      String? thumbnailUrl,
      String? fullContentUrl,
      String? contentId,
      String? messageBody,
      required MessageType messageType,
      MessageStatus? status})
      : super(
            sender: sender,
            regTime: regTime,
            thumbnailUrl: thumbnailUrl,
            fullContentUrl: fullContentUrl,
            contentId: contentId,
            messageBody: messageBody,
            messageType: messageType,
            status: status) {
    if (regTime != null) this.sendTime = regTime;
    super.sendTime ??= DateTime.now().millisecondsSinceEpoch;

    this.roomId = "${lang}_${channel}";
    this.localTimeStr;

    assert(this.sender != null);
    assert(this.sendTime != null);
  }

  OpenChatMsgModel.copyWithSendTime(OpenChatMsgModel messageModel, int? sendTime)
      : super(messageType : messageModel.messageType,
        messageBody : messageModel.messageBody,
        status : messageModel.status,
        fullContentUrl : messageModel.fullContentUrl,
        sender : messageModel.sender,
        contentId : messageModel.contentId,
        thumbnailUrl : messageModel.thumbnailUrl) {
    this.lang = messageModel.lang;
    this.channel = messageModel.channel;
    this.hasAnimation = messageModel.hasAnimation;
    super.sendTime = sendTime;
    this.roomId = "${lang}_${channel}";
  }

  OpenChatMsgModel.fromMap(Map<String, dynamic> map)
      : super(messageType : MessageType.values.byName(map["messageType"]),
        regTime: map["sendTime"],
        thumbnailUrl : map["thumbnailUrl"],
        fullContentUrl : map["fullContentUrl"],
        contentId : map["contentId"],
        messageBody : map["messageBody"],
        status : EnumUtil.valueOf(MessageStatus.values, map["status"] ?? "normal"),
        sender : ContactModelPool().playerMap[map["playerId"]]!.player) {
    assert(this.sender != null);
    this.lang = map["lang"];
    this.channel = map["channel"];
    this.roomId = "${lang}_${channel}";
    assert(this.sendTime != null);
  }

  OpenChatMsgModel.dateSystemMessage(this.lang, this.channel, {int? sendTime, String? dateString})
      : super(
        sender : Player.SquareSys(),
        messageType : MessageType.system,
        contentId : ConstMsgContentId.date) {
    assert(sendTime != null || dateString != null);

    if (dateString == null && sendTime != null)
      dateString = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(sendTime));

    int value = DateTime.parse(dateString!).millisecondsSinceEpoch;
    this.roomId = "${lang}_${channel}";
    super.sendTime = value;
    this.messageBody = value.toString();
  }

  static Set<OpenChatMsgModel> getDateSystemMsgSet(Iterable<OpenChatMsgModel> messages) {
    return messages.map((e) =>
        OpenChatMsgModel.dateSystemMessage(e.lang, e.channel, sendTime: e.sendTime)).toSet();
  }
}
