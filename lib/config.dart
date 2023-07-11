
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:square_web/util/http_resource_util.dart';

class Config {
  static const defaultLang = "ko";
  static const supportedLangs = {"ko", "en"};
  // static String get lang => supportedLangs.contains(L10n.localeName) ? L10n.localeName : defaultLang;
  static String get lang => defaultLang;

  static String cdnAddress = "https://cdn.square.test";
  static String shareLinkAddr = "https://link.square.test";
  static String get metamaskLink =>
    '${Uris.metamask.metamaskDeeplink}/${Uri.base.host}${Uri.base.hasPort ? ':${Uri.base.port}':''}/';
  static late final String serverAddr;
  static late final String httpServerAddr;
  static ValueNotifier<String?> ipfsServiceAddr = ValueNotifier<String?>(null);
  static bool _isInit = false;

  static String replaceWithLang(String target) => target.replaceFirst("{lang}", Config.lang);

  static late final String _termsOfServicePath;
  static String get termsOfServiceUrl => "$cdnAddress/$_termsOfServicePath";
  static late final String _faqPath;
  static String get faqUrl => "$cdnAddress/$_faqPath";

  static String? _zone;
  static String get zone => _zone!;

  // static late final String _randomSquareImageLength;
  // static String get randomProfileImgUrl => '${Config.cdnAddress}/square/defaultProfile/${random.nextInt(int.parse(_randomSquareImageLength))}.png';
  static Map<String, String> aiPlayerIdMap = {};

  static Future<void> loadConfiguration(String zone) async {
    if(_isInit)
      return;

    httpServerAddr = "";
    _zone = zone;
    SquarePlatform.useReqJson = false;
  }

  static Future<String> getBuildVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String getHttpServerAddr(ServiceId serviceId) {
    switch(serviceId) {
      case ServiceId.pepper_core:
        return httpServerAddr;
    }
  }

}

enum ServiceId {
  pepper_core
}
