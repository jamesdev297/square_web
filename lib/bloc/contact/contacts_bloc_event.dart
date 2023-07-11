part of 'contacts_bloc.dart';

@immutable
abstract class ContactsBlocEvent {}

class AddContactEvent extends ContactsBlocEvent {
  final String playerId;
  final String targetPlayerId;
  final Function(ContactModel contact)? successFunc;

  AddContactEvent(this.playerId, this.targetPlayerId, { this.successFunc });
}

class RemoveContactEvent extends ContactsBlocEvent {
  final String playerId;
  final String targetPlayerId;
  final Function? successFunc;

  RemoveContactEvent(this.playerId, this.targetPlayerId, { this.successFunc, });
}

class LoadContactsEvent extends ContactsBlocEvent {
  final String playerId;
  final String? keyword;

  LoadContactsEvent(this.playerId, { this.keyword });
}

class UpdateOnlineContactEvent extends ContactsBlocEvent {
  final String playerId;
  final bool online;

  UpdateOnlineContactEvent(this.playerId, this.online);
}

class UpdateContactEvent extends ContactsBlocEvent {
  final String playerId;
  final String? nickname;
  final String? profileImgUrl;

  UpdateContactEvent({ required this.playerId, this.nickname, this.profileImgUrl });
}

class ReloadContactsEvent extends ContactsBlocEvent {}

class InitLoadContactsEvent extends ContactsBlocEvent {
  final String playerId;
  final String? keyword;

  InitLoadContactsEvent(this.playerId, { this.keyword });
}