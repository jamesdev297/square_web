import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/dao/storage/web/localstge_dao.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/auth/auth_data.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/page/more/block_setting_page.dart';
import 'package:square_web/service/room_manager.dart';

typedef Future<dynamic> FutureCallback();

enum WalletType {
  metamask,
  klip,
  kaikas,
  googleSSO,
  appleSSO;
}

Map<WalletType, WalletIconModel> walletIcon = {
  WalletType.metamask : WalletIconModel(Assets.img.ico_metamask, width: Zeplin.size(57), height: Zeplin.size(52)),
  WalletType.googleSSO : WalletIconModel(Assets.img.ico_google,width: Zeplin.size(48), height: Zeplin.size(48)),
  WalletType.appleSSO : WalletIconModel(Assets.img.ico_apple, width: Zeplin.size(27, isPcSize: true), height: Zeplin.size(27, isPcSize: true)),
  WalletType.klip : WalletIconModel(Assets.img.ico_klip, width: Zeplin.size(30, isPcSize: true), height: Zeplin.size(30, isPcSize: true)),
  WalletType.kaikas : WalletIconModel(Assets.img.ico_kaikas, width: Zeplin.size(50), height: Zeplin.size(50))
};

class WalletIconModel {
  String imgPath;
  double width;
  double height;

  WalletIconModel(this.imgPath, {required this.width, required this.height});
}

class MeModel {
  static MeModel? _instance;

  factory MeModel() => _instance ??= MeModel._internal();

  MeModel._internal();

  ContactModel contact = ContactModel.fromMap({
    "playerId":"testid000",
    "status":"active",
    "nickname": "민수",
    "searchName":"민수",
    "profileImgUrl":"https://preview.kyobobook.co.kr/preview/005/epb/954/4801160509954/images/icon_brain_wash.png",
    "statusMessage":"",
    "hasAiSquare":true,
    "regTime":1682327649046,
    "modTime":1682411112674,
    "online":true,
    "aiPlayer":false,
    "customNickname":false});
  ValueNotifier<ChainNetType> selectedChainNetType = ValueNotifier(Chain.defaultChain);

  late int firstLoginTime;

  AuthData? _authData;
  Set<BlockOption> blockOption = {};

  bool isMe(String? playerId) => playerId == null ? false : playerId == this.playerId;

  WalletType? _walletType;
  WalletType? get walletType => _walletType;
  String playerId = "testid000";
  String? get accessToken => _authData?.accessToken;

  set authData(AuthData authData) {
    AuthData? oldAuthData = this._authData;
    this._authData = authData;
    if (WebsocketDao().isOpen() && oldAuthData?.accessToken != this._authData!.accessToken)
      WebsocketDao().startHeartbeat();
  }

  void resetAuth() {
    this._authData = null;
  }

  bool showTransition = true;

  bool isSignedUp = false;
  bool isSignedIn = false;
  ValueNotifier<bool> isEmailVerified = ValueNotifier(true);

  int? lastEmoticonIndex;

  bool showOnlineStatus = true;
  String? languageCode;

  int lastResumedTime = int64MaxValue;
  int get squareRestrictEndTime => contact?.squareRestrictEndTime ?? 0;
  set squareRestrictEndTime(int? restrictEndTime) => contact?.squareRestrictEndTime = restrictEndTime;
  bool get isRestrictedOnSquare => squareRestrictEndTime > DateTime.now().millisecondsSinceEpoch;


  static String? _firebaseToken;
  String? get firebaseToken => _firebaseToken;

  Future<void> loadDataFromDB() async {
    // contact = await StorageDao().getMe();
    LogWidget.debug("db.playerId is ${contact!.playerId}");
    if (contact!.nickname == null) {
      LogWidget.debug("nickname is empty");
    }
  }

  Future<void> clearData() async {

    await prefs.clear();
    await StorageDao().clearStorage();
    ContactModelPool().clearData();
    RoomManager().clearData();

    MeModel().isSignedIn = false;
    MeModel().isSignedUp = false;

    _instance = null;
  }

  /*static Future<String?> initFirebaseToken() async {
    if (_firebaseToken == null && await fMsg.isSupported()) {
      _firebaseToken = await fMsg.getToken();
    }
    return _firebaseToken;
  }*/
}
