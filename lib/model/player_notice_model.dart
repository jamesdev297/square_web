
class PlayerNotice {
  String playerId;
  String? senderPlayerId;
  String? senderProfileImgUrl;
  String? senderNickname;
  int sendTime;
  String status;
  NoticeType noticeType;
  String context;
  int modTime;

  PlayerNotice.fromMap(Map<String, dynamic> map)
      : this.playerId = map["playerId"],
        this.senderPlayerId = map["senderPlayerId"] ?? map["targetPlayerId"],
        this.senderProfileImgUrl = map["senderProfileImgUrl"] ?? map["targetProfileImgUrl"],
        this.senderNickname = map["senderNickname"] ?? map["targetNickname"],
        this.sendTime = map["sendTime"],
        this.status = map["status"],
        this.noticeType = NoticeType.values.byName(map["noticeType"]),
        this.context = map["context"],
        this.modTime = map["modTime"];

  @override
  int get hashCode => sendTime;

  @override
  bool operator ==(Object other) {
    if(!(other is PlayerNotice))
      return false;
    return sendTime == other.sendTime;
  }

  @override
  String toString() {
    return 'PlayerNotice{playerId: $playerId, targetPlayerId: $senderPlayerId, senderProfileImgUrl: $senderProfileImgUrl, targetNickname: $senderNickname, sendTime: $sendTime, status: $status, noticeType: $noticeType, context: $context, modTime: $modTime}';
  }
}

enum NoticeType {
  kanLiked, kanBought, kanSold, kanGet, kanRetrieve,
  currencyGetOrRetrieve,
  maintenance, event, notice,
  reported, restrict1, restrict2,
  kanTradeRequest, tradeReqKanForSale, likedKanForSale,
  kingOfSquare,
}
