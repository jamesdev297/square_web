import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

typedef ArgumentCallback<T> = void Function(T argument);

class ArgumentCallbacks<T> {
  final List<ArgumentCallback<T>> _callbacks = <ArgumentCallback<T>>[];

  /// Callback method. Invokes the corresponding method on each callback
  /// in this collection.
  ///
  /// The list of callbacks being invoked is computed at the start of the
  /// method and is unaffected by any changes subsequently made to this
  /// collection.
  void call(T argument) {
    final int length = _callbacks.length;
    if (length == 1) {
      _callbacks[0].call(argument);
    } else if (0 < length) {
      for (final ArgumentCallback<T> callback
      in List<ArgumentCallback<T>>.from(_callbacks)) {
        callback(argument);
      }
    }
  }

  /// Adds a callback to this collection.
  void add(ArgumentCallback<T> callback) {
    assert(callback != null);
    _callbacks.add(callback);
  }

  /// Removes a callback from this collection.
  ///
  /// Does nothing, if the callback was not present.
  void remove(ArgumentCallback<T> callback) {
    _callbacks.remove(callback);
  }

  /// Whether this collection is empty.
  bool get isEmpty => _callbacks.isEmpty;

  /// Whether this collection is non-empty.
  bool get isNotEmpty => _callbacks.isNotEmpty;
}

enum CallbackPos {
  splashScreen, signInScreen, homeScreen,
}

class DeepLinkManager {
  static DeepLinkManager _instance = DeepLinkManager._internal();
  factory DeepLinkManager() => _instance;
  DeepLinkManager._internal();

  static String? nowParam;
  static String? nowCommand;

  static String? brandParam;

  static String getSquareLink(ChainNetType chain, String contractAddress, String squareId) {
    String zone = '';
    if(Config.zone != 'live')
      zone = '?zone=${Config.zone}';

    String path = contractAddress;

    if(chain == ChainNetType.user)
      path = squareId;//squareId.split("-")[1];

    return '${Config.shareLinkAddr}/$linkSquareKey/${chain.name}/$path$zone';
  }

  static String getChatLink(String walletAddress) {
    String zone = '';
    if(Config.zone != 'live')
      zone = '?zone=${Config.zone}';

    return '${Config.shareLinkAddr}/$linkChatKey/$walletAddress$zone';
  }

  Future<void> init({Uri? uri}) async {
    LogWidget.debug("DeepLinkManager: initial start!!");
    if(!kIsWeb) {
      // _initDynamicLink();
      _initUniLinks();
    } else if(uri != null) {
      if(uri.queryParameters.containsKey(linkChatKey)) {
        nowCommand = linkChatKey;
        nowParam = uri.queryParameters[linkChatKey];
      }else if(uri.queryParameters.containsKey(linkSquareKey)) {
        nowCommand = linkSquareKey;
        nowParam = uri.queryParameters[linkSquareKey];
      } else if(uri.queryParameters.containsKey(verifyEmailKey)) {
        nowCommand = verifyEmailKey;
        nowParam = uri.queryParameters[verifyEmailKey];
        brandParam = brandKey;
      }

      if(uri.queryParameters.containsKey(brandKey)) {
        brandParam = brandKey;
      }
/*
      if(uri.queryParameters.containsKey(brandKey)) {
      }*/
    }
    // await PushManager().init(_callNowLinkAction);
  }

  Future<void> _initDynamicLink() async {
    /*FirebaseDynamicLinks.instance.onLink.listen((link) async { // 최신버전용
      if(link == null)
        return;

      LogWidget.info("from dynamic link! : ${link.link.toString()}");
      nowLink = link.link;
      _callNowLinkAction();
      return;
    }, onError: (e) async {
      return;
    });

    var data = await FirebaseDynamicLinks.instance.getInitialLink();
    if(data != null) {
      LogWidget.info("from initial dynamic link! : ${data.link.toString()}");
      nowLink = data.link;
      _callNowLinkAction();
    }*/
  }

  StreamSubscription? _uniLinkSubscriber;
  Future<void> _initUniLinks() async {
    /*var initialLink = await getInitialLink();
    if(initialLink != null) {
      LogWidget.info("from initial uni link! : $initialLink");
      nowLink = Uri.parse(initialLink);
      _callNowLinkAction();
    }

    _uniLinkSubscriber = linkStream.listen((link) {
      LogWidget.info("from uni link! : $link");
      nowLink = Uri.parse(link!);
      _callNowLinkAction();
    });*/
  }

  final Map<CallbackPos, Map<String, ArgumentCallback<String>>> deepLinkCallbacks = Map.fromIterable(CallbackPos.values, key: (e) => e, value: (e) => {});


  void addSplashCallbacks(Map<String, ArgumentCallback<String>> callbacks) {
    deepLinkCallbacks[CallbackPos.splashScreen]!.addAll(callbacks);
    if(nowCommand != null && nowParam != null) {
      call(CallbackPos.splashScreen, nowCommand!, nowParam!);
    }
  }

  void addSignInScreenCallbacks(Map<String, ArgumentCallback<String>> callbacks) {
    LogWidget.debug("addSignInScreenCallbacks: $nowCommand $nowParam");
    deepLinkCallbacks[CallbackPos.signInScreen]!.addAll(callbacks);
    if(nowCommand != null && nowParam != null) {
      call(CallbackPos.signInScreen, nowCommand!, nowParam!);
    }
  }

  void addHomeScreenCallbacks(Map<String, ArgumentCallback<String>> callbacks) {
    deepLinkCallbacks[CallbackPos.homeScreen]!.addAll(callbacks);
    if(nowCommand != null && nowParam != null) {
      call(CallbackPos.homeScreen, nowCommand!, nowParam!, clearCommands: true);
    }
  }

  void removeCallback(CallbackPos callbackPos, String uri) {
    deepLinkCallbacks[callbackPos]?.remove(uri);
  }

  void call(CallbackPos callbackPos, String uri, String parameter, {bool clearCommands = false}) {
    deepLinkCallbacks[callbackPos]?[uri]?.call(parameter);
    if(clearCommands) {
      nowCommand = null;
      nowParam = null;
    }
  }

  /*Future<void> _callNowLinkAction() async {
    LogWidget.info("from deep link!!!\n" +
        // "  scheme : ${ nowLink!.scheme }\n" +
        "  path : ${ nowLinkCommand }\n" +
        "  param : ${ nowLinkQueryParam.toString()}\n" +
        "  hasCallback:${deepLinkCallbacks.containsKey(nowLinkCommand)}\n" +
        "  CallBackPos:${ deepLinkCallbacks[nowLinkCommand]?.toString() }");

    if(nowLinkCommand != null && deepLinkCallbacks[nowLinkCommand] != null && nowLinkQueryParam != null) {
      deepLinkCallbacks[nowLinkCommand]!.call(nowLinkQueryParam!);
      nowLinkCommand = null;
    }
  }*/
}
