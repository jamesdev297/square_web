part of 'blocked_rooms_bloc.dart';

abstract class BlockedRoomsBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadBlockedRoomsEvent extends BlockedRoomsBlocEvent {
  final String playerId;
  final String? keyword;

  LoadBlockedRoomsEvent(this.playerId, { this.keyword });
}

class OpenBlockedRoomEvent extends BlockedRoomsBlocEvent {
  final String roomId;

  OpenBlockedRoomEvent(this.roomId);
}

class UpdateLastMsgBlockedRoom extends BlockedRoomsBlocEvent {
  final String roomId;
  final MessageModel? message;

  UpdateLastMsgBlockedRoom(this.roomId, { this.message });
}

class ReceivedBlockedRoomMessageOnlinePush extends BlockedRoomsBlocEvent {
  final MessageModel message;
  final bool isInRoom;

  ReceivedBlockedRoomMessageOnlinePush(this.message, { required this.isInRoom });
}

class AddBlockedRoom extends BlockedRoomsBlocEvent {
  final RoomModel roomModel;
  final bool moveFolder;

  AddBlockedRoom(this.roomModel, { this.moveFolder = true });
}

class UnblockRoom extends BlockedRoomsBlocEvent {
  final String roomId;
  final VoidCallback? successFunc;

  UnblockRoom(this.roomId, { this.successFunc });
}

class UpdateTargetBlockedRoomMember extends BlockedRoomsBlocEvent {
  final String roomId;
  final String targetPlayerId;
  final String? nickname;
  final String? profileImgUrl;

  UpdateTargetBlockedRoomMember(this.roomId, this.targetPlayerId, this.nickname, { this.profileImgUrl });
}

class ReloadBlockedRoomsEvent extends BlockedRoomsBlocEvent {}

class InitLoadBlockedRoomsEvent extends BlockedRoomsBlocEvent {
  final String playerId;
  final String? keyword;

  InitLoadBlockedRoomsEvent(this.playerId, { this.keyword });
}