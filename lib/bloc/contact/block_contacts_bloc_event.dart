part of 'block_contacts_bloc.dart';

abstract class BlockContactsBlocEvent {}

class BlockContactEvent extends BlockContactsBlocEvent {
  final String playerId;
  final ContactModel contactModel;
  final Function? successFunc;

  BlockContactEvent(this.playerId, this.contactModel, { this.successFunc });
}

class UnblockContactEvent extends BlockContactsBlocEvent {
  final String playerId;
  final String targetPlayerId;
  final Function? successFunc;

  UnblockContactEvent(this.playerId, this.targetPlayerId, { this.successFunc });
}

class UpdateBlockedContactEvent extends BlockContactsBlocEvent {
  final String playerId;
  final String? nickname;
  final String? profileImgUrl;

  UpdateBlockedContactEvent({ required this.playerId, this.nickname, this.profileImgUrl });
}

class LoadBlockedContactsEvent extends BlockContactsBlocEvent {
  final String playerId;
  final String? keyword;

  LoadBlockedContactsEvent(this.playerId, { this.keyword });
}

class InitBlockedContactsEvent extends BlockContactsBlocEvent {}