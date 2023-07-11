import 'dart:async';
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:square_web/auth/signIn/sign_in_screen.dart';
import 'package:square_web/bloc/main_screen_bloc.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/ui_theme.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/screen/deferred_widget.dart';
import 'package:square_web/screen/home_screen3.dart' deferred as homeScreen3;
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/splash/splash_screen.dart';
import 'package:square_web/util/device_util.dart';

import 'localization.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences prefs;
// late FirebaseMessaging fMsg;

String? version;

void main() async {
  if (kReleaseMode) {
    // 출시 할때에는 minLogLevel = 3 (error) 로 변환하여 출시
    LogWidget.minLogLevel = 0;
  }

  window.document.onContextMenu.listen((evt) => evt.preventDefault());

  LogWidget.debug("queries : ${Uri.base.queryParameters}");
  String? queryAction = Uri.base.queryParameters["a"];
  if(queryAction == "otsi") {
    // AuthManager().ostiCode = Uri.base.queryParameters["c"];
  }
  await DeepLinkManager().init(uri: Uri.base);

  prefs = await SharedPreferences.getInstance();
  WidgetsFlutterBinding.ensureInitialized();

  late String versionJson;
  version = await Config.getBuildVersion();
  await DeviceUtil.initPlatformState();

  List<String> versionSplited = [];
  if(version != null) {
    versionSplited = version!.split(".");
  }
  if(versionSplited.length == 3) {
    try {
      var buildVersion = const String.fromEnvironment('BUILD_VERSION');
      version = "${versionSplited[0]}.${versionSplited[1]}.${buildVersion}";
    } catch (e) {
      LogWidget.warning("version decode error");
    }
  }

  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/

  // fMsg = FirebaseMessaging.instance;
  // MeModel.initFirebaseToken().then((value) => LogWidget.debug("fcm token : $value"));

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  BlocManager();
  setPathUrlStrategy();

  DeferredWidget.preload(() => homeScreen3.loadLibrary());
  runApp(SquareApp());
}

void proxyNavigation(String name) async {
  LogWidget.debug("proxyNavigation : $name");

  BlocManager.getBloc<MainScreenBloc>()?.add(UpdateMainScreen(name));
}

class SquareApp extends StatelessWidget {
  SquareApp();

 /* static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  Future<void> _sendAnalyticsEvent() async {
    await FirebaseAnalytics.instance.setUserProperty(name: 'webVersion', value: version);
    await FirebaseAnalytics.instance.setUserProperty(name: 'zone', value: Config.zone);
    await FirebaseAnalytics.instance.logAppOpen();
  }*/

  static Map<String, Object> filterOutNulls(Map<String, Object?> parameters) {
    final Map<String, Object> filtered = <String, Object>{};
    parameters.forEach((String key, Object? value) {
      if (value != null) {
        filtered[key] = value;
      }
    });
    return filtered;
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      String zone = const String.fromEnvironment('ZONE');
      // LogWidget.init(withOverlayButton: true, navigatorKey: navigatorKey, zone: zone, debugModeOnly: false);
      // _sendAnalyticsEvent();
    });

    return MaterialApp(
      title: appTitle,
      localizationsDelegates: [
        AppLocalizations.delegate,
        CupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      locale: DeviceUtil.locale,
      builder: (context, child) {
        L10nContainer.setContext(context);
        final mediaQuery = MediaQuery.of(context);
        Zeplin.init(mediaQuery.devicePixelRatio, mediaQuery.size.width,
            mediaQuery.size.height);
        return MediaQuery(
          child: child!,
          data: mediaQuery.copyWith(textScaleFactor: 1.0),
        );
      },
      supportedLocales: [Locale('en', ''), Locale('ko', '')],
      theme: kDefaultTheme,
      initialRoute: '/',
      home: BlocBuilder<MainScreenBloc, MainScreenBlocState>(
          bloc: BlocManager.getBloc()!,
          builder: (context, state) {
            if (state is MainScreenUpdated) {
              switch(state.name) {
                case '/signin':
                  return SignInScreen();
                case '/email_verify':
                  // if(state.param == null) {
                    return Container();
                  // }
                  // return EmailVerifyAlertScreen(idpCode: state.param['idpCode'], success: state.param['success'], isPopup: false);
                case '/home':
                  return DeferredWidget(homeScreen3.loadLibrary, () => homeScreen3.HomeScreen3());
              }
            }
            return SplashScreen();
          }),
      navigatorKey: navigatorKey,
    );
  }
}
