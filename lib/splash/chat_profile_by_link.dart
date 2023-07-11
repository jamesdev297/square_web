import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/share_link_chat.dart';
import 'package:square_web/widget/profile/custom_ellipsis_text.dart';
import 'package:square_web/widget/profile/profile_image.dart';
import 'package:square_web/widget/toast/center_toast_overlay.dart';

class ChatProfileByLink extends StatelessWidget {
  const ChatProfileByLink({
    Key? key,
    required this.contactModel,
    required this.completer
  }) : super(key: key);

  final ContactModel contactModel;
  final Completer completer;

  Widget _buildWalletAddress(BuildContext context, bool isTitle) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          CopyUtil.copyText(contactModel.playerId, () {
            CenterToastOverlay.show(buildContext: context);
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${contactModel.smallerWallet}", style:
                TextStyle(color: isTitle ? Colors.black : CustomColor.grey4,
                    fontWeight: FontWeight.w500,
                    fontSize: Zeplin.size(isTitle ? 34 : 28))),
            SizedBox(width: Zeplin.size(14)),
            Icon36(Assets.img.ico_36_copy_gy),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if(contactModel.statusMessage?.isEmpty ?? true) return Container();
    return CustomEllipsisText(
      text: "\"${contactModel.statusMessage}\"",
      maxLines: 2,
      style: TextStyle(
          fontFamily: Zeplin.robotoRegular,
          color: CustomColor.grey4,
          fontSize: Zeplin.size(30),
          fontWeight: FontWeight.w400),
      ellipsis: "...\"",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Zeplin.size(600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            padding: EdgeInsets.only(top: 12, left: 11, right: 11, bottom: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(13.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                  )
                ]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    ShareLinkChat(walletAddress: contactModel.playerId),
                  ],
                ),
                ProfileImage(contactModel: contactModel,
                    isEdit: false,
                    size: contactModel.isPfpProfile != null ? 316 : 280, isShowBlueDot: false),
                SizedBox(height: Zeplin.size(30)),
                ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: Zeplin.size(528)
                    ),
                    child: contactModel.nickname != null ? Column(
                      children: [
                        Text("${contactModel.name}", maxLines: 1,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: Zeplin.size(34),
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                        SizedBox(height: Zeplin.size(10),),
                        _buildWalletAddress(context, false)
                      ],
                    ) : Column(
                      children: [
                        _buildWalletAddress(context, true),
                      ],
                    )) ,
                SizedBox(height: Zeplin.size(40)),
                SizedBox(
                    height: Zeplin.size(40),
                    child: _buildStatusMessage()),
                SizedBox(height: Zeplin.size(100)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                          child: PebbleRectButton(
                            onPressed: () {
                              completer.complete(true);
                            },
                            child: Text(L10n.login_01_01_connect, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
                            backgroundColor: CustomColor.azureBlue,
                            borderColor: CustomColor.azureBlue,
                          ), height: Zeplin.size(94)),
                    ),
                  ],
                )
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

