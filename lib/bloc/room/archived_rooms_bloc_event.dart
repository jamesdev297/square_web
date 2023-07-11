part of 'archived_rooms_bloc.dart';

@immutable
abstract class ArchivedRoomsBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadArchivedRoomsEvent extends ArchivedRoomsBlocEvent {
  final String playerId;
  final String? keyword;

  LoadArchivedRoomsEvent(this.playerId, { this.keyword });
}

class OpenArchiveRoomEvent extends ArchivedRoomsBlocEvent {
  final String roomId;

  OpenArchiveRoomEvent(this.roomId);
}

class UpdateLastMsgArchivedRoom extends ArchivedRoomsBlocEvent {
  final String roomId;
  final MessageModel? message;

  UpdateLastMsgArchivedRoom(this.roomId, { this.message });
}

class ReceivedArchivedRoomMessageOnlinePush extends ArchivedRoomsBlocEvent {
  final MessageModel message;
  final bool isInRoom;

  ReceivedArchivedRoomMessageOnlinePush(this.message, { required this.isInRoom });
}

class AddArchivedRoom extends ArchivedRoomsBlocEvent {
  final RoomModel roomModel;
  final bool moveFolder;

  AddArchivedRoom(this.roomModel, { this.moveFolder = true });
}

class ArchiveRoomEvent extends ArchivedRoomsBlocEvent {
  final RoomModel roomModel;
  final VoidCallback? successFunc;
  ArchiveRoomEvent(this.roomModel, { this.successFunc });
}

class SayMessageArchivedRoom extends ArchivedRoomsBlocEvent {
  final RoomModel room;

  SayMessageArchivedRoom(this.room);
}

class UnarchiveRoomEvent extends ArchivedRoomsBlocEvent {
  final String roomId;
  final VoidCallback? successFunc;
  UnarchiveRoomEvent(this.roomId, { this.successFunc });
}

class UpdateTargetArchivedRoomMember extends ArchivedRoomsBlocEvent {
  final String roomId;
  final String targetPlayerId;
  final String? nickname;
  final String? profileImgUrl;

  UpdateTargetArchivedRoomMember(this.roomId, this.targetPlayerId, this.nickname, { this.profileImgUrl });
}

class ReloadArchivedRoomsEvent extends ArchivedRoomsBlocEvent {}

class OpenArchivedRoomByLinkEvent extends ArchivedRoomsBlocEvent {
  final RoomModel room;

  OpenArchivedRoomByLinkEvent(this.room);
}

class InitLoadArchivedRoomsEvent extends ArchivedRoomsBlocEvent {
  final String playerId;
  final String? keyword;

  InitLoadArchivedRoomsEvent(this.playerId, { this.keyword });
}