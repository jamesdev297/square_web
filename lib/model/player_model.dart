import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';

class Player extends Equatable {
  String playerId;
  String? nickname;
  String? targetNickname;
  String? profileImgUrl;
  String? profileImgNftId;
  String? statusMessage;
  bool imgIsAsset = false;
  int? squareRestrictEndTime;
  int? modTime;

  String get name => targetNickname ?? nickname ?? playerId;

  Completer<bool>? loadComplete;

  Player({required this.playerId, this.nickname, this.profileImgUrl, this.profileImgNftId, this.imgIsAsset = false});
  Player.fromContact(ContactModel model)
      : this.playerId = model.playerId,
        this.nickname = model.nickname,
        this.targetNickname = model.targetNickname,
        this.profileImgUrl = model.profileImgAsset ?? model.profileImgUrl,
        this.profileImgNftId = model.profileImgNftId,
        this.imgIsAsset = model.profileImgAsset != null,
        this.loadComplete = model.loadComplete,
        this.modTime = model.modTime;

  Player.SquareSys()
    : this.playerId = squarePlayerId,
      this.nickname = squarePlayerId,
      this.profileImgUrl = Assets.img.image_square,
      this.imgIsAsset = true,
      this.loadComplete = Completer<bool>()..complete(true);

  Player.fromMap(Map<String, dynamic> map) :
        playerId = map["playerId"],
        nickname = map["nickname"],
        profileImgUrl = map["profileImgUrl"],
        statusMessage = map["statusMessage"],
        profileImgNftId = map["profileImgNftId"],
        squareRestrictEndTime = map["restrictEndTime"],
        this.loadComplete = Completer<bool>()..complete(true);

  @override
  String toString() {
    return 'Player{playerId: $playerId, nickname: $nickname, profileImgUrl: $profileImgUrl, profileImgNftId: $profileImgNftId, imgIsAsset: $imgIsAsset}';
  }

  ContactModel toContact() {
    ContactModel? contact = ContactModelPool().playerMap[playerId];
    if(contact == null){
      contact = ContactModel(playerId: playerId, nickname: nickname, profileImgUrl: profileImgUrl, profileImgNftId: profileImgNftId);
      this.loadComplete = contact.loadComplete;
    }
    return contact;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [playerId];
}