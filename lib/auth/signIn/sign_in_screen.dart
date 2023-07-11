// 06_01_시작화면_01, 02, 03 - 210825_회원가입_튜토리얼
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:square_web/bloc/main_screen_bloc.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();

  void showTooltip(JustTheController controller) {
    controller.showTooltip();
  }

  void hideTooltip(JustTheController controller) {
    controller.hideTooltip();
  }

  Widget? dialogContentWidget;
  TextStyle subtitleStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(14, isPcSize: true), color: Colors.black);
  TextStyle contentStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.blueyGrey);
  TextStyle hyperlinkContentStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.grey4);

  bool hoverFirstQuestionText = false;
  bool hoverSecondQuestionText = false;

  double? lastScreenHeight;
  bool showListView = false;
  GlobalKey contentWidgetKey = GlobalKey();
  double? contentWidgetHeight;

  bool isKakaoTalkBrowser = DeviceUtil.browserName == MobileBrowser.kakaotalk;

  @override
  void initState() {
    super.initState();

    dialogContentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.login_01_01_title_1, style: subtitleStyle),
        SizedBox(height: Zeplin.size(11)),
        Text(L10n.login_01_01_content_1, style: contentStyle),
        SizedBox(height: Zeplin.size(42)),
        Text(L10n.login_01_01_title_2, style: subtitleStyle),
        SizedBox(height: Zeplin.size(11)),
        Text(L10n.login_01_01_content_2, style: contentStyle),
        SizedBox(height: Zeplin.size(42)),
        Text(L10n.login_01_01_title_3, style: subtitleStyle),
        SizedBox(height: Zeplin.size(11)),
        Text(L10n.login_01_01_content_3, style: contentStyle),
        Padding(
          padding: EdgeInsets.only(left: Zeplin.size(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.login_01_01_content_3_1, style: contentStyle),
              Text(L10n.login_01_01_content_3_2, style: contentStyle),
              Text(L10n.login_01_01_content_3_3, style: contentStyle),
            ],
          ),
        ),
        SizedBox(height: Zeplin.size(42)),
        Text(L10n.login_01_01_title_4, style: subtitleStyle),
        SizedBox(height: Zeplin.size(11)),
        Text(L10n.login_01_01_content_4, style: contentStyle),
        SizedBox(height: Zeplin.size(42)),
        Text(L10n.login_01_01_title_5, style: subtitleStyle),
        SizedBox(height: Zeplin.size(11)),
        Text(L10n.login_01_01_content_5, style: contentStyle),
        SizedBox(height: Zeplin.size(26)),
        RichText(
          text: TextSpan(
            children: StringUtil.parseColorText(L10n.login_01_01_content_6, CustomColor.azureBlue, boldToAccent: false, fontSize: Zeplin.size(26), isUnderline: true,
            onTap1: () {
              showTermsOfServiceAlert();
            }),
            style: contentStyle
          ),
        ),
        SizedBox(height: Zeplin.size(42)),
      ]
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogWidget.debug("add sign in screen callbacks");
      DeepLinkManager().addSignInScreenCallbacks({
        verifyEmailKey : (param) async {
        }
      });
    });
  }

  void showInfoDialog(WalletType walletType) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      context: navigatorKey.currentState!.overlay!.context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 0.0,
        insetPadding: EdgeInsets.all(Zeplin.size(34)),
        child: Container(
          width: Zeplin.size(500, isPcSize: true),
          height: Zeplin.size(500, isPcSize: true),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: Zeplin.size(22), right: Zeplin.size(22), top: Zeplin.size(22), bottom: Zeplin.size(10)),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: Zeplin.size(18)),
                          Text(L10n.login_01_01_title, style: TextStyle(fontWeight: FontWeight.w500, fontSize:Zeplin.size(34), color: Colors.black)),
                          SizedBox(height: Zeplin.size(28)),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: SquareDefaultDialog.closeDialog(),
                          child: Image.asset(Assets.img.ico_46_x_bk, width: Zeplin.size(46),)),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(15, isPcSize: true)),
                      child: dialogContentWidget!,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: Zeplin.size(15, isPcSize: true), vertical: Zeplin.size(9, isPcSize: true)),
                width: double.maxFinite,
                height: Zeplin.size(94),
                child: PebbleRectButton(
                  onPressed: () {
                    _processAuth(context, walletType);
                    SquareDefaultDialog.closeDialog().call();
                  },
                  child: Text(L10n.login_01_01_button, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
                  backgroundColor: CustomColor.azureBlue,
                  borderColor: CustomColor.azureBlue,
                )
              ),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      )
    );
  }

  Widget buildContent() {
    return Column(
      key: contentWidgetKey,
      children: [
        Center(child: Wrap(
            children: [
              Text(L10n.login_02_01_title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(34), color: Colors.black)),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      // AuthManager().goBrandPage();
                    },
                    child: Image.asset(Assets.img.square_logo, width: 43,)),
              )
            ])),
        SizedBox(height: Zeplin.size(10)),
        Center(child: Text(L10n.login_02_02_content, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: Zeplin.size(26), color: Colors.black))),
        SizedBox(height: Zeplin.size(60)),
        if(!isKakaoTalkBrowser)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
          child: Container(
              height: Zeplin.size(57, isPcSize: true),
              constraints: BoxConstraints(maxWidth: Zeplin.size(326, isPcSize: true)),
              child: ConnectButton(
                onTap: () => showInfoDialog(WalletType.googleSSO),
                image: Image.asset(walletIcon[WalletType.googleSSO]!.imgPath, width: walletIcon[WalletType.googleSSO]!.width, height: walletIcon[WalletType.googleSSO]!.height),
                text: L10n.login_02_08_google_login,
              )
          ),
        ),
        if(!isKakaoTalkBrowser)
          SizedBox(height: Zeplin.size(30)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
          child: Container(
              height: Zeplin.size(57, isPcSize: true),
              constraints: BoxConstraints(maxWidth: Zeplin.size(326, isPcSize: true)),
              child: ConnectButton(
                onTap: () => showInfoDialog(WalletType.appleSSO),
                image: Image.asset(walletIcon[WalletType.appleSSO]!.imgPath, width: walletIcon[WalletType.appleSSO]!.width, height: walletIcon[WalletType.appleSSO]!.height),
                text: L10n.login_02_08_apple_login,
              )
          ),
        ),
        SizedBox(height: Zeplin.size(30)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
          child: Container(
            height: Zeplin.size(57, isPcSize: true),
            constraints: BoxConstraints(maxWidth: Zeplin.size(326, isPcSize: true)),
            child: ConnectButton(
              onTap: () => showInfoDialog(WalletType.metamask),
              image: Image.asset(walletIcon[WalletType.metamask]!.imgPath, width: walletIcon[WalletType.metamask]!.width, height: walletIcon[WalletType.metamask]!.height),
              text: L10n.login_02_03_metamask,
            )
          ),
        ),
        SizedBox(height: Zeplin.size(30)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
          child: Container(
              height: Zeplin.size(57, isPcSize: true),
              constraints: BoxConstraints(maxWidth: Zeplin.size(326, isPcSize: true)),
              child: ConnectButton(
                onTap: () => showInfoDialog(WalletType.klip),
                image: Image.asset(walletIcon[WalletType.klip]!.imgPath, width: walletIcon[WalletType.klip]!.width, height: walletIcon[WalletType.klip]!.height),
                text: L10n.login_02_04_klip_login,
              )
          ),
        ),
        SizedBox(height: Zeplin.size(30)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
          child: Container(
            height: Zeplin.size(57, isPcSize: true),
            constraints: BoxConstraints(maxWidth: Zeplin.size(326, isPcSize: true)),
            child: ConnectButton(
              onTap: () => showInfoDialog(WalletType.kaikas),
              image: Image.asset(walletIcon[WalletType.kaikas]!.imgPath, width: walletIcon[WalletType.kaikas]!.width, height: walletIcon[WalletType.kaikas]!.height),
              text: L10n.login_02_08_kaikas_login,
            )
          ),
        ),
        SizedBox(height: Zeplin.size(60)),
        InkWell(
          hoverColor: Colors.white.withOpacity(0.0),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onHover: (isShow) {
            if(isShow == true)
              showTooltip(tooltipController1);
            else
              hideTooltip(tooltipController1);
          },
          onTap: () => showTooltip(tooltipController1),
          child: MouseRegion(
            onEnter: (evt) {
              setState(() {
                hoverFirstQuestionText = true;
              });
            },
            onExit: (evt) {
              setState(() {
                hoverFirstQuestionText = false;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(Zeplin.size(5)),
              child: JustTheTooltip(
                preferredDirection: AxisDirection.up,
                tailBaseWidth: Zeplin.size(30),
                tailLength: Zeplin.size(15),
                controller: tooltipController1,
                shadow: BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, -1),
                ),
                child: Text(L10n.login_02_05_text, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w300, color: hoverFirstQuestionText ? CustomColor.grey4.withOpacity(0.5) : CustomColor.grey4, decoration: TextDecoration.underline)),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                content: Padding(
                  padding: EdgeInsets.all(Zeplin.size(22, isPcSize: true)),
                  child: Container(
                    width: Zeplin.size(282, isPcSize: true),
                    child: Text(L10n.login_03_01_tooltip,
                        style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w400, letterSpacing: 0.6, height: 1.2), textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: Zeplin.size(10)),
        InkWell(
          hoverColor: Colors.white.withOpacity(0.0),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onHover: (isShow) {
            if(isShow == true)
              showTooltip(tooltipController2);
            else
              hideTooltip(tooltipController2);
          },
          onTap: () => showTooltip(tooltipController2),
          child: MouseRegion(
            onEnter: (evt) {
              setState(() {
                hoverSecondQuestionText = true;
              });
            },
            onExit: (evt) {
              setState(() {
                hoverSecondQuestionText = false;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(Zeplin.size(5)),
              child: JustTheTooltip(
                shadow: BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, -1),
                ),
                preferredDirection: AxisDirection.up,
                tailBaseWidth: Zeplin.size(30),
                tailLength: Zeplin.size(15),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                controller: tooltipController2,
                child: Text(L10n.login_02_06_text, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w300, color: hoverSecondQuestionText ? CustomColor.grey4.withOpacity(0.5) : CustomColor.grey4, decoration: TextDecoration.underline)),
                content: Padding(
                  padding: EdgeInsets.all(Zeplin.size(22, isPcSize: true)),
                  child: Container(
                      width: Zeplin.size(282, isPcSize: true),
                      child: Text(L10n.login_04_01_tooltip, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w400, letterSpacing: 0.6, height: 1.2), textAlign: TextAlign.center)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBackButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CustomColor.paleGrey,
      body: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if(contentWidgetHeight == null) {
                final box = contentWidgetKey.currentContext?.findRenderObject() as RenderBox?;
                if(box != null) {
                  contentWidgetHeight = box.size.height;
                }
              }

              final newScreenHeight = DeviceUtil.screenHeight;
              if(contentWidgetHeight != null) {
                if(lastScreenHeight != newScreenHeight) {
                  // 40 - backbutton widget height
                  if(newScreenHeight < contentWidgetHeight! + 40) {
                    if(showListView == false) {
                      showListView = true;
                      setState(() {
                      });
                    }
                  } else {
                    if(showListView == true) {
                      showListView = false;
                      setState(() {
                      });
                    }
                  }
                }
                lastScreenHeight = newScreenHeight;
              }
            });

            return SizedBox(
                height: DeviceUtil.screenHeight,
                child: showListView ? ListView(
                  shrinkWrap: true,
                  children: [
                    // buildBackButton(),
                    buildContent(),
                    SizedBox(
                      height: 70,
                    ),
                  ],
                ) : Column(
                  children: [
                    // buildBackButton(),
                    Expanded(
                      child: Column(
                        children: [
                          Spacer(),
                          buildContent(),
                          Spacer()
                        ],
                      ),
                    ),
                  ],
                )
            );
          }
      ),
    );
  }

  void socialLoginFailed(WalletType? idpCode) {
    if(idpCode == WalletType.googleSSO || idpCode == WalletType.appleSSO) {
      BlocManager.getBloc<MainScreenBloc>()?.add(UpdateMainScreen('/email_verify', param: {'idpCode': idpCode, 'success' : false}));
    }
  }

  void _processAuth(BuildContext context, WalletType? idpCode) async {
    FullScreenSpinner.show(context);
    await Future.delayed(Duration(milliseconds: 200));
    proxyNavigation('/home');
    FullScreenSpinner.hide();
  }

  void showTermsOfServiceAlert() {

    final IFrameElement _iframeElement = IFrameElement();

    _iframeElement.height = '500';
    _iframeElement.width = '500';

    _iframeElement.src = Config.termsOfServiceUrl;
    _iframeElement.style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'terms_of_service',
          (int viewId) => _iframeElement,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(28), vertical: Zeplin.size(40)),
        child: Container(
          padding: EdgeInsets.only(
            left: Zeplin.size(15, isPcSize: true),
            bottom: Zeplin.size(16, isPcSize: true)),
          width: Zeplin.size(960),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 10,
              )
            ]
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: Zeplin.size(50, isPcSize: true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(L10n.my_01_20_help, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                  Expanded(
                    child: HtmlElementView(
                      viewType: 'terms_of_service',
                    ),
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
              Positioned(
                top: Zeplin.size(22),
                right: Zeplin.size(22),
                child: MenuPack.closeButton(onTap: () {
                  Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
                }),
              )
            ],
          ),
        ),
      )
    );
  }
}
