import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
enum DeviceType {
  iphone(true),
  android(true),
  ipad(true),
  etc(false);
  const DeviceType(this.isMobile);
  final bool isMobile;
}
class DeviceUtil {
  static MediaQueryData? _mediaQueryData;
  static MediaQueryData get mediaQueryData {
    return MediaQuery.of(navigatorKey.currentContext!);
    /*if(_mediaQueryData != null)
      return _mediaQueryData!;

    var queryData = MediaQuery.of(navigatorKey.currentContext!);
    if(queryData.size.height > 0) {
      _mediaQueryData = queryData;
      LogWidget.debug("media query set! : width : ${queryData.size.width} / height : ${queryData.size.height}");
    }
    return queryData;*/
  }

  static double get screenWidth => mediaQueryData.size.width;
  static double get screenHeight => mediaQueryData.size.height;
  static double get devicePixelRatio => mediaQueryData.devicePixelRatio;
  static double get realScreenWidth =>
      mediaQueryData.size.width * mediaQueryData.devicePixelRatio;
  static double get realScreenHeight =>
      mediaQueryData.size.height * mediaQueryData.devicePixelRatio;
  static double get bottomPaddingHeight => mediaQueryData.padding.bottom;
  static double get topPaddingHeight => mediaQueryData.padding.top;

  static double get profileShowRatio => (65 + bottomPaddingHeight) / screenHeight;

  static String? _deviceId = "webDeviceId";
  static String? get deviceId => _deviceId = "webDeviceId";

  static String? _deviceModel;
  static String? get deviceModel => _deviceModel;

  static Map<String, dynamic>? get deviceData => _deviceData;
  static Map<String, dynamic>? _deviceData;

  static DeviceType? deviceType;
  static bool get isMobileWeb => deviceType?.isMobile ?? false;

  static double minSideNaviWidth = 768;

  static Locale get locale => _locale ?? Locale('ko', '');
  static Locale? _locale;

  static WebBrowserInfo get browserInfo {
    if(_browserInfo == null) {
      throw Exception("not initialized yet.");
    }
    return _browserInfo!;
  }
  static WebBrowserInfo? _browserInfo;

  static Future<void> initPlatformState() async {
    // localPath = await _getlocalPath();
    try {
      _browserInfo = await deviceInfo.webBrowserInfo;
      browserName = browserInfo.browserName.name;
      String? userAgent = browserInfo.userAgent;

      setLanguage(browserInfo.language);

      if(userAgent != null) {
        String userAgentLowerCase = userAgent.toLowerCase();

        if(userAgentLowerCase.contains("metamask")) {
          browserName = MobileBrowser.metaMask;
        } else if(userAgentLowerCase.contains("kaikas")) {
          browserName = MobileBrowser.kaikas;
        } else if(userAgentLowerCase.contains('kakaotalk')) {
          browserName = MobileBrowser.kakaotalk;
        }

        for(DeviceType type in DeviceType.values) {
          if(userAgentLowerCase.contains(type.name)) {
            deviceType = type;
            break;
          }
        }
        if(deviceType == null)
          deviceType = DeviceType.etc;

        /*var testWords = ["iphone", "ipad", "android", "mobile"];
        for (var word in testWords) {
          if (userAgentLowerCase.contains(word)) {
            isMobileWeb = true;
            break;
          }
        }*/
      }
      // await loadCustomKGSystem();

      LogWidget.debug("detected deviceId : $_deviceId");
    } on PlatformException {
      _deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  static void setLanguage(String? language) {

    if(showSetLang == false) {
      _locale = Locale(SupportedLang.ko.name, '');
      prefs.setString(PrefsKey.language, SupportedLang.ko.name);

      return;
    }

    String host = Uri.base.host;
    if((host.contains('alpha') || host.contains('localhost')) && prefs.containsKey(PrefsKey.language)) {
     _locale = Locale(prefs.getString(PrefsKey.language)!, '');
     return;
    }

    if(language?.contains(SupportedLang.ko.name) == true) {
      _locale = Locale(SupportedLang.ko.name, '');
      prefs.setString(PrefsKey.language, SupportedLang.ko.name);
    } else {
      _locale = Locale(SupportedLang.en.name, '');
      prefs.setString(PrefsKey.language, SupportedLang.en.name);
    }
  }

  static DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  static String? browserName;
}