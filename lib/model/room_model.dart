import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/util/enum_util.dart';
import 'package:square_web/util/string_util.dart';

class RoomModel {
  String? roomId;
  String? roomType;
  bool? isAiChat;
  String? searchName;
  String? targetProfileImgUrl;
  bool? isNftTargetProfileImg;
  MessageModel? lastMsg;
  String? status;
  int? lastMsgTime;
  bool? isUnread;
  int? blockedTime;
  int? regTime;
  int? modTime;
  bool? receiveAlarm;
  
  bool get isBlocked => blockedTime != null;
  bool get isArchived => status == "archived";
  bool? isKnown;

  String? get smallerSearchName {
    if(searchName != null && searchName!.length == walletLength)
      return StringUtil.smallerString(searchName!);
    return searchName;
  }

  static String? contactPlayerId({required String roomId}) {
    List<String> splited = roomId.split(":");
    if(splited[0] != 'TR') return null;
    splited.removeAt(0);
    return splited.whereNot((element) => element == MeModel().playerId).first;
  }

  List<RoomMemberModel> members = [];
  RoomMemberModel? get me => members.firstWhereOrNull((element) => element.playerId == MeModel().playerId);
  int? get lastMsgTimeOrRegTime => (lastMsgTime == null || lastMsgTime == 0) ? regTime : lastMsgTime;
  ContactModel? get contact => contacts.length > 0 ? contacts[0] : null;
  List<ContactModel> get contacts => members.where((e) => e.playerId != MeModel().playerId).map((e) => e.contact).toList();
  List<ContactModel> get contactsIncludeMe => members.map((e) => e.contact).toList();

  Map<String, ContactModel> get contactMap => Map.fromIterable(members, key: (e) => (e as RoomMemberModel).playerId!, value: (e) => (e as RoomMemberModel).contact);

  bool get isTwin => roomType == "twin";
  bool get isInactive => members.where((element) => element.playerId == MeModel().playerId).first.status == Status.inactive;

  RoomModel({
        this.roomId,
        this.lastMsgTime,
        this.regTime,
        this.modTime,
        List<ContactModel>? contacts,
        this.roomType,
        this.receiveAlarm,
      }) {

    if (contacts != null)
      members = contacts.where((e) => e.playerId != MeModel().playerId).map((e) => RoomMemberModel.fromPlayerId(e.playerId)).toList();

    LogWidget.debug("RoomModel ${this.roomId}, ${this.roomType}");
    assert(lastMsgTime != null);
  }

  RoomModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.roomId = map["roomId"];
      this.roomType = map["roomType"];
      this.searchName = map["searchName"];
      this.targetProfileImgUrl = map["targetProfileImgUrl"];
      this.isNftTargetProfileImg = map["nftTargetProfileImg"];
      this.receiveAlarm = map["receiveAlarm"] == true;
      this.lastMsg = map["lastMsg"] != null ? MessageModel.fromMap(map["lastMsg"], isLastMsg: true) : null;
      this.lastMsgTime = map["lastMsgTime"] != 0 ? map["lastMsgTime"] : null;
      this.isUnread = map["unread"];
      this.blockedTime = map['blockedTime'];
      this.status = map['status'];
      this.regTime = map["regTime"];
      this.modTime = map["modTime"];
      this.isAiChat = map['aiChat'];

      if(this.isTwin) {
        List<dynamic>? roomMembers = map["members"];
        this.isKnown = map['known'];

        if(roomMembers == null) {
          List<String> memberPlayerIds = roomId!.split(":")..removeAt(0)..removeWhere((element) => element == MeModel().playerId);
          members.addAll(memberPlayerIds.map((playerId) => RoomMemberModel.fromPlayerId(playerId)).toList());
        } else {
          members.addAll(roomMembers.map((e) {
            ContactModelPool().playerMap[e['playerId']]?.updateTargetMember(searchName, profileImgUrl :targetProfileImgUrl);
            return RoomMemberModel.fromMap(e);
          }));
        }

      } else {
        List<dynamic>? roomMembers = map["members"];

        if (roomMembers != null)
          members.addAll(roomMembers.map((e) => RoomMemberModel.fromMap(e)));
      }
    }

  }

  RoomModel.temp({
    this.roomId,
    this.searchName,
    this.isAiChat,
    this.status = "temp",
    List<ContactModel>? contacts,
    this.roomType,
    this.isKnown
  }) {

    if (contacts != null)
      members = contacts.map((e) => RoomMemberModel.tempFromPlayerId(e.playerId, status: e.playerId != MeModel().playerId ? e.status : Status.inactive)).toList();

    LogWidget.debug("RoomModel temp ${this.roomId}, ${this.roomType}");
  }

  void updateLastMsg(MessageModel? messageModel, { isUnread = false }) {
    if(messageModel == null)
      return;

    lastMsg = messageModel;
    this.isUnread = isUnread;
    lastMsgTime = messageModel.sendTime;
  }

  String toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('roomId', roomId);
    addIfPresent('regTime', regTime);
    addIfPresent('contacts', contacts.map((e)=>e.toJson()).toList());

    return jsonEncode(json);
  }

  void updateChatPageByContact(ContactModel contactModel) {
    this.targetProfileImgUrl = contactModel.profileImgUrl;
    this.isNftTargetProfileImg = contactModel.isPfpProfile;
    this.isKnown = contactModel.friendTime != null;
    this.searchName = contactModel.name;
    this.blockedTime = contactModel.relationshipStatus == RelationshipStatus.blocked ? DateTime.now().millisecondsSinceEpoch : null;
  }

  void updateChatPageByRoom(RoomModel roomModel) {
    this.targetProfileImgUrl = roomModel.targetProfileImgUrl;
    this.isNftTargetProfileImg = roomModel.isNftTargetProfileImg;
    this.isKnown = roomModel.isKnown;
    this.searchName = roomModel.searchName;
    this.blockedTime = roomModel.blockedTime;
    this.status = roomModel.status;
  }
}

class RoomMemberModel {
  String? playerId;
  Status? status;
  int? lastReadTime;
  bool? isTyping;
  String? role;
  int? regTime;
  int? modTime;

  ContactModel get contact => ContactModelPool().getPlayerContact(playerId);

  RoomMemberModel(this.playerId, this.status, this.lastReadTime, this.isTyping, this.role, this.regTime, this.modTime);
  RoomMemberModel.fromMap(Map<String, dynamic> map) {
    this.playerId = map["playerId"];
    this.status = EnumUtil.valueOf(Status.values, map["status"]);
    this.lastReadTime = map["lastReadTime"];
    this.isTyping = map["typing"] == true;
    this.role = map["role"];
    this.regTime = map["regTime"];
    this.modTime = map["modTime"];
  }
  RoomMemberModel.fromPlayerId(this.playerId) :
      status = Status.active,
      lastReadTime = 0,
      isTyping = false,
      regTime = 0,
      modTime = 0;

  RoomMemberModel.tempFromPlayerId(this.playerId, { this.status = Status.inactive}) :
        lastReadTime = 0,
        isTyping = false,
        regTime = 0,
        modTime = 0;

  @override
  String toString() {
    return "(playerId=$playerId, nickname=${ContactModelPool().getPlayerNickName(playerId)}, status=$status, lastReadTime=$lastReadTime, isTyping=$isTyping, regTime=$regTime, modTime=$modTime)";
  }
}