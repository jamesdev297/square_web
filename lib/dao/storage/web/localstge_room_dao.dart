part of 'package:square_web/dao/storage/web/localstge_dao.dart';

extension RoomDao on StorageDao {
  Future<List<RoomModel>> getRooms(int offset, int limit) async {
    return [];
  }

  Future<RoomModel> getRoom(String? roomId) async {
    return RoomModel.fromMap({
      'roomId': roomId
    });
  }

  Future<int> deleteRoom(String? roomId) async {
    return 0;
  }

  Future<int> deleteRoomMembers(String? roomId) async {
    return 0;
  }

  Future<int> deleteNotInRoomMembers(String roomId, List<String> playerIds) async {
    return 0;
  }

  Future<List<RoomModel>> getUpdatedRooms(int? lastRoomTime, int limit) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String? roomId) async {
    return [];
  }

  Future<int> updateRoom(RoomModel model, {bool removeNotInMembers = false, bool updateMembers = true}) async {
    return 0;
  }

  Future<int> updateRoomReceiveAlarm(String? roomId, bool receiveAlarm) async {
    return 0;
  }

  Future<int> updateCustomTitle(String? roomId, String? customTitle) async {
    return 0;
  }

  Future<int> updateRoomMember(String roomId, RoomMemberModel member) async {
    return 0;
  }

  Future<int> updateRoomMembers(String? roomId, List<RoomMemberModel> members,
      {bool removeNotInMembers = false}) async {
    return 0;
  }

  Future<int> updateMessage(MessageModel model) async {
    return 0;
  }

  Future<int> updateMessages(List<MessageModel?> models) async {
    return 0;
  }

  Future<bool> updateSkillMessage(MessageModel model) async {
    return false;
  }

  Future<int> resetSkillMessage() async {
    return 0;
  }

  Future<int> deleteFirstMessage(String roomId) async {
    return 0;
  }

  Future<int> deleteMessage(String roomId, int sendTime, String playerId) async {
    return 0;
  }

  Future<int> sendFailedMessage(MessageModel messageModel) async {
    return 0;
  }

  Future<int> removeMessage(MessageModel messageModel) async {
    return 0;
  }

  Future<int> removeMessageForMe(MessageModel messageModel) async {
    return 0;
  }

  Future<int> deleteMessageByRoomId(String? roomId) async {
    return 0;
  }

  Future<int> getUnreadMessageCount(String? roomId, int lastReadTime) async {
    return 0;
  }

  Future<int?> getMessageTotalCount(String roomId) async {
    return 0;
  }

  Future<List<MessageModel>> getMediaMessages(String? roomId, int? offset, int limit) async {
    return [];
  }

  Future<List<MessageModel>> getMessages(RoomModel room, int offset, int limit) async {
    return [];
  }

  Future<List<MessageModel>> getMessagesWithLastMsgTime(RoomModel room, int? lastMsgTime, int limit) async {
    return [];
  }

  Future<MessageModel?> getLastMessage(String? roomId) async {
    return null;
  }

  Future<int> getLastMessageTime(String? roomId) async {
    return 0;
  }

  Future<int> getLastRoomRefreshTime(String? playerId) async {
    return 0;
  }

  Future<int> setLastRoomRefreshTime(String? playerId, int lastRoomRefreshTime) async {
    return 1;
  }
}
