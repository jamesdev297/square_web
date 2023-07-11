// 04_01_마이_01 - 210810_마이_02

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/contacts/my_profile_item.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/profile/wallet_copy_row.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';
import 'package:square_web/widget/toggle_button.dart';

class MorePage extends StatefulWidget with HomeWidget {
  final Function? showPage;

  HomeWidget rootWidget;

  MorePage({this.showPage, required this.rootWidget});

  MyWalletPropertyBloc myWalletPropertyBloc = MyWalletPropertyBloc();

  @override
  String pageName() => "MorePage";

  @override
  double? get maxHeight => PageSize.myPageHeight;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  _MorePageState createState() => _MorePageState();

  @override
  MenuPack get getMenuPack => MenuPack();
}

class _MorePageState extends State<MorePage> {
  TextStyle nicknameTextStyle = TextStyle(color: Colors.black, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500);
  final TextStyle nameTextStyle =
      TextStyle(color: Colors.black, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500);
  final TextStyle statusMessageTextStyle =
      TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500);
  final TextStyle subTitleTextStyle =
      TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28));
  final TextStyle subContentTextStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            /* Padding(
              padding: EdgeInsets.only(left: Zeplin.size(34), right: Zeplin.size(34), top: Zeplin.size(28), bottom: Zeplin.size(20)),
              child: Row(
                children: [
                  Text(L10n.my_01_01_more, style: TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(34))),
                  Spacer(),
                  ShareLinkChat(walletAddress: MeModel().playerId!, rootWidget: widget,),
                  SizedBox(width: Zeplin.size(30)),
                  QRSignInButton(),
                ],
              ),
            ),*/
            SizedBox(
              height: Zeplin.size(98),
            ),
            MyProfileItem(isMorePage: true),
            Padding(
              padding: EdgeInsets.only(top: Zeplin.size(20), bottom: Zeplin.size(34), left: Zeplin.size(30), right: Zeplin.size(30)),
              child: WalletCopyRow(contactModel: MeModel().contact!, rootWidget: widget.rootWidget),
            ),
            Container(
              height: Zeplin.size(20),
              color: CustomColor.paleGrey,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Zeplin.size(34), right: Zeplin.size(34), top: Zeplin.size(60), bottom: Zeplin.size(25)),
              child: Row(
                children: [
                  Text(L10n.my_01_03_settings,
                      style: TextStyle(
                          color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                widget.showPage?.call(1);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.my_01_05_allow_message, style: subTitleTextStyle),
              trailing: Icon36(Assets.img.ico_36_arrow_gy),
            ),
            SizedBox(height: Zeplin.size(10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              child: Row(
                children: [
                  Text(L10n.my_01_06_show_online, style: subTitleTextStyle),
                  Spacer(),
                  ToggleButton(
                    onPressed: () async {
                      MeModel().showOnlineStatus = !(MeModel().showOnlineStatus);
                      setState(() {});
                    },
                    toggleSelect: MeModel().showOnlineStatus ?? false,
                  )
                ],
              ),
            ),
            SizedBox(height: Zeplin.size(40)),
            Container(height: Zeplin.size(20), color: CustomColor.paleGrey),
            Padding(
              padding: EdgeInsets.only(
                  left: Zeplin.size(34), right: Zeplin.size(34), top: Zeplin.size(60), bottom: Zeplin.size(25)),
              child: Row(
                children: [
                  Text(L10n.my_01_18_support_customer,
                      style: TextStyle(
                          color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                ],
              ),
            ),
            ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.my_01_19_brand, style: subTitleTextStyle),
              trailing: Icon36(Assets.img.ico_36_arrow_gy),
            ),
            ListTile(
              onTap: () => HomeNavigator.push(RoutePaths.profile.termsOfService),
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.my_01_20_help, style: subTitleTextStyle),
              trailing: Icon36(Assets.img.ico_36_arrow_gy),
            ),
           /* ListTile(
              onTap: () => HomeNavigator.push(RoutePaths.profile.faq),
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.my_01_21_faq, style: subTitleTextStyle),
              trailing: Icon36(Assets.img.ico_36_arrow_gy),
            ),*/
            ListTile(
              onTap: () {
                widget.showPage?.call(2);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.feedback_01_send_feedback, style: subTitleTextStyle),
              trailing: Icon36(Assets.img.ico_36_arrow_gy),
            ),
            ListTile(
              onTap: null,
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(L10n.my_01_24_follow_us, style: subTitleTextStyle),
              trailing: Wrap(
                direction: Axis.horizontal,
                children: [
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => html.window.open(SnsLink.twitter, "_blank"),
                          child: Icon36(Assets.img.ico_twitter))),
                  SizedBox(width: 14),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => html.window.open(SnsLink.telegram, "_blank"),
                          child: Icon36(Assets.img.ico_telegram))),
                  SizedBox(width: 14),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => html.window.open(SnsLink.line, "_blank"),
                        child: Icon36(Assets.img.ico_line)
                        )),
                  SizedBox(width: 14),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => html.window.open(SnsLink.kakao, "_blank"),
                        child: Icon36(Assets.img.ico_kakao)
                        )),
                  SizedBox(width: 14),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => html.window.open(SnsLink.discord, "_blank"),
                          child: Icon36(Assets.img.ico_discord))),
                ],
              ),
            ),
            if ((Uri.base.host.contains('alpha') || Uri.base.host.contains('localhost')) && showSetLang == true)
              ListTile(
                onTap: null,
                contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                leading: Text(L10n.common_65_set_language, style: subTitleTextStyle),
                trailing: ToggleButton(
                  onPressed: () async {
                    String? language = prefs.getString(PrefsKey.language);
                    if (language == SupportedLang.ko.name) {
                      prefs.setString(PrefsKey.language, SupportedLang.en.name);
                    } else {
                      prefs.setString(PrefsKey.language, SupportedLang.ko.name);
                    }

                    html.window.location.reload();
                  },
                  toggleSelect: prefs.getString(PrefsKey.language) == SupportedLang.ko.name,
                ),
              ),
            walletIcon[MeModel().walletType] != null
                ? ListTile(
                    onTap: null,
                    contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                    leading: Text(
                      L10n.more_page_wallet_type,
                      style: TextStyle(color: Colors.black, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
                    ),
                    trailing: Image.asset(walletIcon[MeModel().walletType]!.imgPath,
                        width: walletIcon[MeModel().walletType]!.width * 0.8,
                        height: walletIcon[MeModel().walletType]!.height * 0.8),
                  )
                : Container(),
            ListTile(
              onTap: null,
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Text(
                L10n.my_01_23_version,
                style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
              ),
              trailing: Text(version ?? "-",
                  style:
                      TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500)),
            ),
            ListTile(
              onTap: () {
                CopyUtil.copyText(supportSquareEmail, () {
                  ToastOverlay.show(buildContext: context, rootWidget: widget.rootWidget);
                });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
              leading: Container(
                  padding: EdgeInsets.only(bottom: 1),
                  decoration:
                      BoxDecoration(border: Border(bottom: BorderSide(color: CustomColor.taupeGray, width: 0.7))),
                  child: Text(supportSquareEmail,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.taupeGray))),
            ),
            SizedBox(height: Zeplin.size(40)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(30)),
              child: Container(
                height: Zeplin.size(94),
                child: PebbleRectButton(
                    onPressed: () {
                      SquareDefaultDialog.showSquareDialog(
                        showShadow: true,
                        // barrierColor: Colors.black.withOpacity(0.4),
                        barrierDismissible: false,
                        title: L10n.common_21_logout_title,
                        description: L10n.common_20_logout_content,
                        button1Text: L10n.common_03_cancel,
                        button2Text: L10n.common_02_confirm,
                        button2Action: () {
                          // AuthManager().logout();
                          SquareDefaultDialog.closeDialog().call();
                        },
                      );
                    },
                    backgroundColor: CustomColor.paleGrey,
                    borderColor: CustomColor.paleGrey,
                    child: Center(
                        child: Text(L10n.common_19_logout,
                            style: TextStyle(
                                fontSize: Zeplin.size(28),
                                fontWeight: FontWeight.w500,
                                color: CustomColor.deleteRed)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
