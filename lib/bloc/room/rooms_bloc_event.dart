import 'package:equatable/equatable.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';

abstract class RoomsBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RemoveTempRoomsEvent extends RoomsBlocEvent {}

class LoadRoomsEvent extends RoomsBlocEvent {
  final String playerId;
  final String? keyword;

  LoadRoomsEvent(this.playerId, { this.keyword });
}

class OpenRoomEvent extends RoomsBlocEvent {
  final String roomId;
  
  OpenRoomEvent(this.roomId);
}

class UpdateLastMsgRoom extends RoomsBlocEvent {
  final String roomId;
  final MessageModel? message;

  UpdateLastMsgRoom(this.roomId, { this.message });
}

class ReceivedRoomMessageOnlinePush extends RoomsBlocEvent {
  final MessageModel message;
  final bool isInRoom;

  ReceivedRoomMessageOnlinePush(this.message, { required this.isInRoom });
}

class UpdateRoomMembers extends RoomsBlocEvent {
  final String roomId;
  
  UpdateRoomMembers(this.roomId);
}

class AddRoom extends RoomsBlocEvent {
  final RoomModel room;
  final bool moveFolder;

  AddRoom(this.room, { this.moveFolder = true });
}

class SayMessageRoom extends RoomsBlocEvent {
  final RoomModel room;

  SayMessageRoom(this.room);
}

class UpdateTargetRoomMember extends RoomsBlocEvent {
  final String roomId;
  final String targetPlayerId;
  final String? nickname;
  final String? profileImgUrl;

  UpdateTargetRoomMember(this.roomId, this.targetPlayerId, this.nickname, { this.profileImgUrl });
}

class ReloadRoomsEvent extends RoomsBlocEvent {}

class OpenRoomByLinkEvent extends RoomsBlocEvent {
  final RoomModel? room;
  final String? roomId;

  OpenRoomByLinkEvent({this.room, this.roomId});
}

class InitLoadRoomsEvent extends RoomsBlocEvent {
  final String playerId;
  final String? keyword;

  InitLoadRoomsEvent(this.playerId, { this.keyword });
}