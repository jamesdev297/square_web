class AlarmSettings {
  bool? allAlarm;
  bool? chatAlarm;
  bool? friendRequestAlarm;
  bool? tradeRequestAlarm;
  bool? likeAlarm;
  bool? etcAlarm;

  AlarmSettings({
      this.allAlarm, this.chatAlarm, this.friendRequestAlarm, this.tradeRequestAlarm, this.likeAlarm, this.etcAlarm});

  AlarmSettings.fromMap(Map<String, dynamic> map) {
    this.allAlarm = map["allAlarm"];
    this.chatAlarm = map["chatAlarm"];
    this.friendRequestAlarm = map["friendRequestAlarm"];
    this.tradeRequestAlarm = map["tradeRequestAlarm"];
    this.likeAlarm = map["likeAlarm"];
    this.etcAlarm = map["etcAlarm"];
  }

  @override
  String toString() {
    return "AlarmSettings allAlarm: $allAlarm, chatAlarm: $chatAlarm, friendRequestAlarm: $friendRequestAlarm, "
        "tradeRequestAlarm: $tradeRequestAlarm, likeAlarm: $likeAlarm, etcAlarm: $etcAlarm";
  }
}