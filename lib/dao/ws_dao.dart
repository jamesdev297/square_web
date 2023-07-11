import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/html.dart';

import 'package:square_web/config.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/push_manager.dart';
import 'package:square_web/model/squarepacket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:square_web/constants/constants.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';

abstract class WebsocketDao {
  static WebsocketDao? _instance = null;

  static void initInstance(WebsocketDao instance) {
    _instance = instance;
  }

  factory WebsocketDao() => _instance!;

  set wsUrl(String wsUrl);

  Future<int> init({Future<void> onSuccess()?, bool? initWithLogin});

  bool isOpen();

  void onPaused();

  void send(SquarePacket request);

  Future<SquarePacket?> callRequest(SquarePacket? reqPacket, int? wsTimeout);

  Future<bool> waitUntilConnect(int milliSeconds);

  void startHeartbeat();

  void waitInternetConnect();
}

class RemoteWebsocketDao implements WebsocketDao {
  static final RemoteWebsocketDao _instance = RemoteWebsocketDao._internal();

  String wsUrl = "wss://${Config.serverAddr}";

  // String wsUrl = "ws://127.0.0.1:20580/pepper_core";
  // String wsUrl = "ws://127.0.0.1:11411/session";

  final String uriHeartbeat = "pepper_core://v2/auth/heartbeat";
  final String uriPushOnline = "pepper_core://v1/push/online";
  final String uriTest = "pepper_core://v1/test";

  final Set<String> uriSetToIgnoreLog = <String>{Uris.square.getChanelMessages};

  WebSocket? _websocket;
  int _websocketTime = 0;
  WebSocketChannel? _channel;
  bool _paused = false;
  int _retryConnect = 0;
  Map<int, Completer<SquarePacket?>> requestCache = {};
  int _heartbeatSeq = 0;
  int _timeoutCount = 0;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  Completer<bool>? _connectCompleter;

  bool _initWithLogin = false;

  StreamSubscription<InternetConnectionStatus>? _subscription;

  factory RemoteWebsocketDao() => _instance;

  RemoteWebsocketDao._internal();

  int getDelayMs() {
    _retryConnect++;
    int delayMs = min(1000 * _retryConnect, 10000);
    return delayMs;
  }

  Map<String, dynamic> getDefaultHeader() => {"playerId": MeModel().playerId, "Authorization": MeModel().accessToken, "deviceId": DeviceUtil.deviceId};

  @override
  void startHeartbeat() {
    _retryConnect = 0;
    _heartbeatSeq = 0;

    LogWidget.debug("start heartbeat!");
    heartbeat();

    if (_heartbeatTimer != null && _heartbeatTimer!.isActive) {
      LogWidget.debug("cancel heartbeat!");
      _heartbeatTimer!.cancel();
    }

    _heartbeatTimer = Timer.periodic(Duration(seconds: 59), (timer) async {
      heartbeat();
      _connectCompleter?.complete(true);
      _connectCompleter = null;
    });
  }

  void heartbeat() {
    LogWidget.debug("Heartbeat : ready, isOpen : ${isOpen()} / isSignedIn : ${MeModel().isSignedIn}");
    if (!isOpen() || !MeModel().isSignedIn) {
      if (_heartbeatTimer != null) {
        _heartbeatTimer!.cancel();
      }
      return;
    }

    LogWidget.debug("Heartbeat : beating!");

    SquarePacket? packet;

    _heartbeatSeq++;
    packet = SquarePacket(
        uri: Uris.auth.heartbeat,
        header: JsonMap.empty(),
        body: JsonMap({
          "playerId": "${MeModel().playerId}",
          "seq": _heartbeatSeq,
          "showOnlineStatus": MeModel().showOnlineStatus
        }));

    send(packet);
  }

  Future<bool> availableAuth() async {
    if (MeModel().accessToken == null) return false;

    if (wsUrl != Config.serverAddr) return true;

    try {
      String url = wsUrl.replaceFirst("ws", "http");
      LogWidget.debug("url : $url");
      http.Response response = await http.get(Uri.parse(wsUrl.replaceFirst("ws", "http")));
      if (response.statusCode != 200) {
        return false;
      }
    } catch (e) {
      LogWidget.error("ws server is not available : $e");
      return false;
    }

    LogWidget.debug("ws server is available");
    LogWidget.debug("auth is available");
    return true;
  }

  Future<void> retryInit(Future<void> onSuccess()?) async {
    int delayMs = getDelayMs();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () async {
      LogWidget.debug("ws retry to init after delay: ($delayMs) ms, retry: $_retryConnect");
      if (await availableAuth()) {
        // if(AuthManager().isExpired(MeModel().accessToken)) {
        //   await AuthManager().refreshAccessToken();
        // }
        init(onSuccess: onSuccess);
      }
      // else {
      //   retryInit(onSuccess);
      // }
    });
  }

  @override
  Future<int> init({Future<void> onSuccess()?, bool? initWithLogin}) async {
    LogWidget.debug("init retryCount $_retryConnect, websocket: $_websocket, channel: $_channel");
    if (_websocket != null) {
      _websocket?.close();
      _channel = null;
    }

    if (initWithLogin != null) {
      _initWithLogin = initWithLogin;
    }

    if (await availableAuth() == false) {
      return 401;
    }

    try {
      _websocket = WebSocket(wsUrl)..binaryType = 'arraybuffer';
      await _websocket?.onOpen.first;
      LogWidget.debug("ws connected readyState: (${_websocket?.readyState}) now:${DateTime.now().millisecondsSinceEpoch}");
      _channel = HtmlWebSocketChannel(_websocket!); //web
      _reconnectTimer?.cancel();
      _websocketTime = DateTime.now().millisecondsSinceEpoch;

      _channel!.stream.listen((message) {
        if (!(message is String)) {
          message = SquarePacket.decodeZLib(message);
        }

        SquarePacket response = SquarePacket.fromJson(message);
        if (!uriSetToIgnoreLog.contains(response.uri)) {
          LogWidget.debug("ws recieve : $message");
        } else {
          // LogWidget.debug("ws ${response.uri} ${response.txNo} : receive");
        }

        if (response.getStatus() == CustomStatus.TOKEN_EXPIRED && MeModel().isSignedIn) {
          SquareDefaultDialog.showSquareDialog(
              uniqueDialogKey: UniqueDialogKey.expiredToken,
              barrierColor: Colors.black.withOpacity(0.5),
              barrierDismissible: false,
              title: L10n.common_07_expire_login,
              button1Text: L10n.common_02_confirm,
              button1Action: () {
                // AuthManager().logout();
              });

          onPaused();
        }

        if (response.uri == uriPushOnline) {
          var body = response.body;
          PushManager().receivedPushOnline(body["cmd"], body["target"], body["targetId"], body["data"]);
          return;
        }

        Completer<SquarePacket?>? completer = requestCache[response.txNo];
        if (completer != null) {
          requestCache.remove(response.txNo);
          completer.complete(response);
        } else {
          LogWidget.debug("no handler for : $message");
        }
      }, onDone: () async {
        LogWidget.info("ws channel done : ${getConnectTime()} ms, paused: $_paused");
        if (_paused) {
          _paused = false;
          return;
        }

        _channel?.sink.close();
        _channel = null;
        WebsocketDao().waitInternetConnect();
      }, onError: (error) {
        LogWidget.debug('ws error $error');
        _channel = null;
        // retryInit(() async => null);
        WebsocketDao().waitInternetConnect();
      });

      _connectCompleter = Completer<bool>.sync();

      _initWithLogin = false;
      _retryConnect = 0;
      LogWidget.debug("SignInCommand success");
      startHeartbeat();

      if (onSuccess != null) {
        await onSuccess();
      }
    } catch (e, stacktrace) {
      LogWidget.debug("ws connect failed : $e \n${stacktrace}");
      WebsocketDao().waitInternetConnect();
    }

    return 200;
  }

  int getConnectTime() {
    return DateTime.now().millisecondsSinceEpoch - _websocketTime;
  }

  @override
  Future<SquarePacket?> callRequest(SquarePacket? reqPacket, int? wsTimeout) async {
    if (await waitUntilConnect(4000) == false) {
      LogWidget.debug("init for callRequest ${reqPacket!.uri} : try");
      if (await init() == 200) {
        LogWidget.debug("init for callRequest ${reqPacket.uri} : success");
      } else {
        LogWidget.debug("init for callRequest ${reqPacket.uri} : failed");

        if (await waitUntilConnect(4000) == false) {
          if (_retryConnect > 3) {
            SquareDefaultDialog.showRestartDialog(L10n.common_06_network);
            _retryConnect = 0;
          }
          return null;
        }
      }
    }

    return callRequestInternal(reqPacket!, wsTimeout);
  }

  Future<SquarePacket?> callRequestInternal(SquarePacket reqPacket, int? wsTimeout) {
    var completer = Completer<SquarePacket?>.sync();
    requestCache.putIfAbsent(reqPacket.txNo, () => completer);

    send(reqPacket);

    return completer.future.timeout(Duration(milliseconds: wsTimeout ?? wsTimeoutMs), onTimeout: () async {
      requestCache.remove(reqPacket.txNo);
      _timeoutCount++;
      LogWidget.debug("timeout : $_timeoutCount : ${reqPacket.txNo}");
      if (_timeoutCount > 2) {
        LogWidget.debug("websocket reset : because of timeout $_timeoutCount");
        _timeoutCount = 0;
        _channel?.sink.close();
        _channel = null;
      }
      return null;
    });
  }

  @override
  bool isOpen() {
    if (_channel == null) return false;
    return true;
  }

  @override
  void onPaused() {
    _paused = true;
    _channel?.sink.close();
    _heartbeatTimer?.cancel();
    _channel = null;
    _heartbeatTimer = null;
    LogWidget.debug("ws.onPaused");
  }

  @override
  void send(SquarePacket request) {
    if (isOpen() == false) return;

    if (request.header == null) {
      request.header = JsonMap(getDefaultHeader());
    } else {
      request.header.addAll(getDefaultHeader());
    }

    if (SquarePlatform.useReqJson) {
      var jsonReq = request.toJson();
      try {
        _channel!.sink.add(jsonReq);
        if (uriSetToIgnoreLog.contains(request.uri) == false) {
          LogWidget.debug("ws send : $jsonReq");
        } else {
          //LogWidget.debug("ws ${request.uri} ${request.txNo} : send");
        }
      } catch (e) {
        LogWidget.error("ws error : $e ");
      }
    } else {
      var byteData = request.toZLib();
      try {
        _channel!.sink.add(byteData);
        if (uriSetToIgnoreLog.contains(request.uri) == false) {
          LogWidget.debug("ws send : ${request.toJson()}");
        } else {
          //LogWidget.debug("ws ${request.uri} ${request.txNo} : send");
        }
      } catch (e) {
        LogWidget.error("ws error : $e ");
      }
    }
  }

  @override
  Future<bool> waitUntilConnect(int milliSeconds) async {
    if (isOpen()) return true;

    // init 이 호출되지 않았다면 기다릴 이유가 없는 경우
    if (_connectCompleter == null) return false;

    return _connectCompleter!.future.timeout(Duration(milliseconds: milliSeconds), onTimeout: () {
      return isOpen();
    });
  }

  @override
  void waitInternetConnect() async {
   /* await _subscription?.cancel();
    _subscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) async {
      if (status == InternetConnectionStatus.connected) {
        retryInit(() async => null);
        await _subscription?.cancel();
        _subscription = null;
      }
    });*/
  }
}
