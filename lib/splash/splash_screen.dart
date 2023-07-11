import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/dao/storage/web/localstge_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/square_logo_top_left.dart';


class SplashScreen extends StatefulWidget {
  @override
  State createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Widget? centerWidget;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initService();
    });
    // js.context.callMethod('alertMessage', ['Flutter is calling upon JavaScript!']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initService() async {
    MeModel().languageCode = Localizations.localeOf(context).languageCode;

    late String zone = const String.fromEnvironment('ZONE');
    LogWidget.debug("Select Zone");

/*    if (kReleaseMode) {
      zone = const String.fromEnvironment('ZONE');
    } else {
      zone = "alpha";
    }*/

    LogWidget.debug("zone : $zone");

    tabIconManager.init();

    await Future.wait(<Future<void>>[
      StorageDao().init(),
      Config.loadConfiguration(zone),
    ]);

    proxyNavigation('/home');
    // await GetContextFromCDN().execute();
  }

  /*Future<void> linkProcess(String? chatPlayerAddress, String? chatSquareAddress, Completer completer) async {
    LogWidget.debug("startAuth linkProcess()");

    if(chatPlayerAddress != null) {
      GetContactByLinkCommand command = GetContactByLinkCommand(chatPlayerAddress);
      if(await DataService().request(command)) {
        LogWidget.debug("startAuth GetContactByLinkCommand() success");
        LogWidget.debug("startAuth GetContactByLinkCommand() success : ${command.content}");
        ContactModel contactModel = ContactModel.fromByLink(chatPlayerAddress, command.content);

        centerWidget = ChatProfileByLink(contactModel: contactModel, completer: completer, );
        setState(() {

        });
      } else {
        LogWidget.debug("startAuth GetContactByLinkCommand() failed");

        chatPlayerAddress = null;
        completer.complete(true);
      }
    } else if(chatSquareAddress != null) {
      GetSquareByLinkCommand command = GetSquareByLinkCommand(chatSquareAddress);
      if(await DataService().request(command)) {
        SquareModel square = SquareModel.fromByLink(chatSquareAddress, command.content);

        centerWidget = SquareProfileByLink(square: square, completer: completer);
        setState(() {

        });
      } else {
        chatSquareAddress = null;
        completer.complete(true);
      }
    } else {
      completer.complete(true);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          if(centerWidget != null)
            Center(child: centerWidget),

          if(centerWidget != null)
            Align(
              alignment: Alignment.topCenter,
              child: SquareLogoTopLeft(),
            )
        ],
      ),
      backgroundColor: CustomColor.lemon,
    );
  }
}

