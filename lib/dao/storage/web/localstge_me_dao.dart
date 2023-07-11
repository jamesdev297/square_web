part of 'package:square_web/dao/storage/web/localstge_dao.dart';
extension MeKey on _PrefsKey {
  static const playerId = "my_player_id";
  static const nickname = "my_nickname";
  static const profileImgUrl = "my_profile_img";
  static const showOnline = "my_show_online_status";
  static const firstLoginTime = "my_first_login_time";
  static const lastLoginTime = "my_last_login_time";
  static const region = "my_region";
  static const statusMsg = "my_status_msg";
  static const country = "my_country_code";
  static const receiveAlarmClosedTime = "my_receive_alarm_closed_time";
  static const lastLocationRefreshTime ="my_last_location_refresh_time";
  static const lastUserRefreshTime = "my_last_user_refresh_time";
}

extension MeDao on StorageDao {
  String? StrToNullable(String? value) => value?.isEmpty ?? true ? null : value;

  Future<ContactModel?> getMe() async {
    return ContactModel.fromMap({
      'playerId' : StrToNullable(_prefs.getString(MeKey.playerId)),
      'nickname': StrToNullable(_prefs.getString(MeKey.nickname)),
      'profileImgUrl': StrToNullable(_prefs.getString(MeKey.profileImgUrl)),
      'region': StrToNullable(_prefs.getString(MeKey.region)),
      'statusMessage': StrToNullable(_prefs.getString(MeKey.statusMsg)),
      'countryCode': StrToNullable(_prefs.getString(MeKey.country))
    });
  }

  Future<int> updateMe(ContactModel model, bool showOnlineStatus) async {
    //playerId, squareId, nickname, profileImgUrl, showOnlineStatus, firstLoginTime
    _prefs.setString(MeKey.playerId, model.playerId);
    _prefs.setString(MeKey.nickname, model.nickname ?? "");
    _prefs.setString(MeKey.profileImgUrl, model.profileImgUrl ?? "");
    _prefs.setBool(MeKey.showOnline, showOnlineStatus);
    _prefs.setInt(MeKey.firstLoginTime, DateTime.now().millisecondsSinceEpoch);
    return 1;
  }

  Future<int> getFirstLoginTime(String? playerId) async {
    return _prefs.getInt(MeKey.firstLoginTime) ?? 0;
  }

  Future<int> setNickname(String? playerId, String? nickname) async {
    if(nickname == null) {
      _prefs.remove(MeKey.nickname);
    } else {
      _prefs.setString(MeKey.nickname, nickname);
    }
    return 1;
  }

  Future<int> setStatusMessage(String playerId, String? statusMessage) async {
    if(statusMessage != null)
      _prefs.setString(MeKey.statusMsg, statusMessage);
    else
      _prefs.remove(MeKey.statusMsg);
    return 1;
  }

  Future<int> setShowOnlineStatus(String? playerId, bool showOnlineStatus) async {
    _prefs.setBool(MeKey.showOnline, showOnlineStatus);
    return 1;
  }

  Future<int> setCountryCode(String playerId, String countryCode) async {
    _prefs.setString(MeKey.country, countryCode);
    return 1;
  }

  Future<String?> getUrlProfile(String playerId) async {
    return StrToNullable(_prefs.getString(MeKey.profileImgUrl));
  }

  Future<int> setUrlProfile(String? playerId, String? profileImgUrl) async {
    if(profileImgUrl != null)
      _prefs.setString(MeKey.profileImgUrl, profileImgUrl);
    return 1;
  }

  Future<int?> getLastLoginTime(String? playerId) async {
    return _prefs.getInt(MeKey.lastLoginTime);
  }

  Future<int> setLastLoginTime(String? playerId) async {
    _prefs.setInt(MeKey.lastLoginTime, DateTime.now().millisecondsSinceEpoch);
    return 1;
  }

  Future<int> getLastUserRefreshTime(String? playerId) async {
    return _prefs.getInt(MeKey.lastUserRefreshTime) ?? 0;
  }

  Future<int?> setLastUserRefreshTime(String? playerId, int lastUserRefreshTime) async {
    _prefs.setInt(MeKey.lastUserRefreshTime, lastUserRefreshTime);
    return 1;
  }
}
