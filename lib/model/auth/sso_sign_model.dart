import 'dart:core';

class SSOSign {
  String userId;
  String email;
  String idToken;
  String playerIdType;
  DateTime? resendAvailableTime;

  SSOSign(this.userId, this.email, this.idToken, this.playerIdType);
  Map<String, dynamic> toMap(bool withIsSSO) => {
    'userId': userId,
    'email': email,
    'idToken': idToken,
    'playerIdType': playerIdType,
    if(withIsSSO)
    'sso': true
  };
}
