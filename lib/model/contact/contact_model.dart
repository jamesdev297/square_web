import 'dart:async';

import 'package:square_web/command/command_friend.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/unknown_contact.dart';
import 'package:square_web/model/contact/square_contact.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/player_model.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/util/enum_util.dart';
import 'package:square_web/util/string_util.dart';

class ContactModel {
  late String playerId;
  String? nickname;
  String? targetNickname;
  String? profileImgUrl;
  String? profileImgAsset;
  String? profileImgNftId;
  int? regTime;
  int? modTime;
  int? friendTime;
  int? squareRestrictEndTime;
  Status? status;
  String? statusMessage;
  Completer<bool> loadComplete = Completer<bool>();
  RelationshipStatus? relationshipStatus;
  ChainNetType? blockchainNetType;
  Player? _player;
  Player get player => _player ??= Player.fromContact(this);
  bool get online => ContactManager().globalPlayerMap[playerId]["online"] ?? false;

  bool get isMe => MeModel().isMe(playerId);
  bool get isCustomNickname => targetNickname != null;

  String get name => targetNickname ?? nickname ?? smallerWallet;

  bool get isNotSignedUp => status == Status.notSignedUp;

  bool get isPfpProfile => profileImgUrl != null && profileImgNftId != null;

  String? _twinRoomId;

  String? get twinRoomId {
    if(_twinRoomId == null) {
      _twinRoomId = makeTwinRoomId(this.playerId);
    }
    return _twinRoomId;
  }

  static String makeTwinRoomId(String playerId) {
    List<String?> twinPlayerIds = [MeModel().playerId, playerId]..sort();
    return "TR:${twinPlayerIds.join(":")}";
  }

  String get smallerWallet {
    return StringUtil.smallerString(playerId);
  }

  String get smallerName {
    if(name.length == walletLength)
      return smallerWallet;
    return name;
  }

  @override
  String toString() => 'ContactModel ${this.playerId}, ${this.nickname}, ${this.targetNickname}, ${this.friendTime} ${this.statusMessage} ${this.status}';

  ContactModel(
      {
      required this.playerId,
      this.nickname,
      this.profileImgUrl,
      this.profileImgNftId,
      this.modTime,
      this.profileImgAsset,
      this.friendTime,
      this.relationshipStatus,
      this.regTime,
      this.statusMessage,
      bool forSignIn = false}) {

    if (this.profileImgUrl == "")
      this.profileImgUrl = null;

    // LogWidget.debug("ContactModel ${this.playerId}, ${this.nickname}, ${this.statusMessage}");
    assert(this.playerId != null);
    if (forSignIn != true) {
      // assert(this.nickname != null);
    }
    if(!loadComplete.isCompleted)
      loadComplete.complete(true);
  }

  ContactModel.fromByLink(String playerId, dynamic content) {
    this.playerId = playerId;
    if (content != null) {
      this.nickname = content["nickname"];
      this.profileImgUrl = content["profileImgUrl"];
      this.profileImgNftId = content["profileImgNftId"];
      this.status = EnumUtil.valueOf(Status.values, content["status"]);
      this.statusMessage = content["statusMessage"];
    }
    LogWidget.debug("ContactModel.fromByLink ${this.playerId}, ${this.nickname}, ${this.statusMessage}");
    assert(this.playerId != null);
  }

  ContactModel.fromMap(Map<String, dynamic>? map, {bool forSignIn = false, withKanUiImage = false}) {
    if (map != null) {
      this.playerId = map["playerId"];
      this.nickname = map["nickname"];
      this.targetNickname = map['targetNickname'];
      this.profileImgUrl = map["profileImgUrl"];
      this.modTime = map["modTime"];
      this.regTime = map["regTime"];
      this.friendTime = map["friendTime"];
      this.profileImgNftId = map["profileImgNftId"];
      if(map.containsKey('status'))
        this.status = Status.values.byName(map['status']);

      if(map.containsKey('relationshipStatus') && map['relationshipStatus'] != null) {
        this.relationshipStatus = RelationshipStatus.values.byName(map['relationshipStatus']);
      }
      this.squareRestrictEndTime = map["restrictEndTime"];

      if(map['blockchainNetType'] != null && ChainNetType.values.containsKey(map['blockchainNetType']) == true)
        this.blockchainNetType = ChainNetType.values[map['blockchainNetType']];

      this.statusMessage = map["statusMessage"];
    }

    // LogWidget.debug("ContactModel.fromMap ${this.playerId}, ${this.nickname}, ${this.targetNickname}, ${this.friendTime} ${this.statusMessage}");
    assert(this.playerId != null);
    if (forSignIn != true) {
      // assert(this.nickname != null);
    }
    if(!loadComplete.isCompleted)
      loadComplete.complete(true);
  }
/*
  ContactModel.future(this.playerId) {
    this.nickname = "...";
    GetSimpleProfileCommand cmd = GetSimpleProfileCommand(playerId);
    DataService().request(cmd).then((value) {
      if(value) {
        this.nickname = cmd.simpleProfile!.nickname;
        this.profileImgUrl = cmd.simpleProfile!.profileImgUrl;
        this.profileImgNftId = cmd.simpleProfile!.profileImgNftId;
        this.squareRestrictEndTime = cmd.simpleProfile!.squareRestrictEndTime;
        this.statusMessage = cmd.simpleProfile!.statusMessage;
        _player?.nickname = this.nickname;
        _player?.profileImgUrl = this.profileImgUrl;
        _player?.profileImgNftId = this.profileImgNftId;
        _player?.modTime = this.modTime;
      } else {
        this.nickname = L10n.common_08_unknown_user;
        _player?.nickname = this.nickname;
      }
      if(!loadComplete.isCompleted)
        loadComplete.complete(true);
    });
  }*/

  String? quote(String parameter) {
    if(parameter != null)
      return null;
    return '"$parameter"';
  }

  Map<String, dynamic> toJson() => {
    "playerId" : playerId,
    "nickname" : nickname,
    "targetNickname" : targetNickname,
    "profileImgUrl" : profileImgUrl,
    "modTime" : modTime,
    "regTime" : regTime,
    "friendTime" : friendTime,
    "statusMessage" : statusMessage,
    "profileImgNftId" : profileImgNftId
  };

  void updateTargetMember(String? targetNickname, { String? profileImgUrl }) {
    this.targetNickname = targetNickname;
    this._player?.targetNickname = targetNickname;

    if(profileImgUrl != null) {
      this.profileImgUrl = profileImgUrl;
      this._player?.profileImgUrl = profileImgUrl;
      this._player?.modTime = modTime;
    }

  }

  void update(ContactModel item) {
    this.playerId = item.playerId;
    this.nickname = item.nickname ?? this.nickname;
    this.targetNickname = item.targetNickname ?? this.targetNickname;
    this.profileImgUrl = item.profileImgUrl ?? this.profileImgUrl;
    this.profileImgNftId = item.profileImgNftId ?? this.profileImgNftId;
    this.profileImgAsset = item.profileImgAsset ?? this.profileImgAsset;
    this.status = item.status ?? this.status;
    this.modTime = item.modTime ?? this.modTime;
    this.regTime = item.regTime ?? this.regTime;
    this.friendTime = item.friendTime ?? this.friendTime;
    this.relationshipStatus = item.relationshipStatus ?? this.relationshipStatus;
    this.statusMessage = item.statusMessage ?? this.statusMessage;
    this.profileImgNftId = item.profileImgNftId ?? this.profileImgNftId;

    this._player?.playerId = item.playerId;
    this._player?.nickname = item.targetNickname ?? item.nickname ?? item.playerId;
    this._player?.profileImgUrl = item.profileImgUrl;
    this._player?.profileImgNftId = item.profileImgNftId;
    this._player?.modTime = item.modTime ?? this.modTime;

  }

  void updateProfile(String? profileImgUrl, String? nftId, String? nickname, String? statusMessage) {

    this.nickname = nickname;
    this.profileImgUrl = profileImgUrl;
    this.profileImgNftId = nftId;
    this.statusMessage = statusMessage;

    this._player?.nickname = nickname;
    this._player?.profileImgUrl = profileImgUrl;
    this._player?.profileImgNftId = nftId;
    this.modTime = DateTime.now().millisecondsSinceEpoch;
  }

}

class ContactModelPool {
  static final ContactModelPool _instance = ContactModelPool._internal();
  factory ContactModelPool() => _instance;
  ContactModelPool._internal();

  final Map<String, ContactModel> playerMap = {};

  String getPlayerNickName(String? playerId) => playerMap[playerId]?.nickname ?? "(알 수 없음)";
  String? getPlayerNickNameWithMe(String? playerId) => playerMap[playerId]?.nickname ??
      (MeModel().isMe(playerId) ? MeModel().contact?.nickname : null);

  ContactModel getPlayerContact(String? playerId) {
    if(playerId == null) {
      return UnknownContact();
    } else if(playerId == squarePlayerId) {
      return SquareContact();
    } else if(playerMap.containsKey(playerId)) {
      return playerMap[playerId]!;
    } else if(MeModel().playerId == playerId) {
      return MeModel().contact!;
    }  else {
      if(ContactManager().globalPlayerMap.containsKey(playerId)) {
        return ContactModel.fromMap(ContactManager().globalPlayerMap[playerId]!);
      }
      return UnknownContact();
      // ContactModel contact = ContactModel.future(playerId);
      // add(contact);
      // return contact;
    }
  }

  bool writeLock = false;

  void clearData() {
    playerMap.clear();
    writeLock = false;
  }

  void add(ContactModel item, {bool? notify, bool isFriend = false}) {
    if(item.playerId == null)
      return;

    playerMap.putIfAbsent(item.playerId, () => item)..update(item);
  }

  void addAllPlayers(List<Player> item) {
    item.forEach((element) {
      ContactModel contact = playerMap.putIfAbsent(element.playerId, () => element.toContact());
      if(contact != null) {
        contact.nickname = element.nickname;
        contact.profileImgUrl = element.profileImgUrl;
      }
    });
  }


  void sortContacts(int index, List<ContactModel> contacts) {
    if(index == 1) {
      contacts.sort((a, b) {
        if(a.online == false && b.online == false) {
          var c = StringUtil.addOrderPrefix(a.name)!;
          var d = StringUtil.addOrderPrefix(b.name)!;
          return c.compareTo(d);
        }
        if(a.online == false)
          return 1;
        if(b.online == false)
          return -1;

        var c = StringUtil.addOrderPrefix(a.name)!;
        var d = StringUtil.addOrderPrefix(b.name)!;
        return c.compareTo(d);
      });

    } else {
      contacts.sort((a,b) {

        var c = StringUtil.addOrderPrefix(a.name)!;
        var d = StringUtil.addOrderPrefix(b.name)!;

        return c.compareTo(d);

      });
    }
  }

  Future<ContactModel?> searchPlayerByPlayerId(String playerId, String targetPlayerId) async {

    GetPlayerProfileCommand command = GetPlayerProfileCommand(playerId: playerId, targetPlayerId: targetPlayerId);
    if (await DataService().request(command)) {
      LogWidget.debug("GetFriendProfileCommand success");

      return command.contactModel;
    } else {
      LogWidget.debug("GetFriendProfileCommand failed");
    }

    return null;
  }
}