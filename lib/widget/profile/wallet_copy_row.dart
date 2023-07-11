import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';

class WalletCopyRow extends StatelessWidget {
  final ContactModel contactModel;
  final HomeWidget rootWidget;
  final bool withEmailNoticeBtn;

  const WalletCopyRow({Key? key, required this.contactModel, required this.rootWidget, this.withEmailNoticeBtn = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(L10n.my_01_04_wallet,
            style: TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
        SizedBox(width: 3,),
        ValueListenableBuilder(
          valueListenable: MeModel().isEmailVerified,
          builder: (context, bool value, child) {
            if(!value)
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Icon(Icons.info_outline, color: CustomColor.azureBlue, size: Zeplin.size(38),),
                ),
              );
            else
              return Container();
          }
        ),
        Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              CopyUtil.copyText(contactModel.playerId, () {
                ToastOverlay.show(buildContext: context, rootWidget: rootWidget);
              });
            },
            child: Row(
              children: [
                Text(contactModel.smallerWallet,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                SizedBox(width: Zeplin.size(14)),
                Icon36(Assets.img.ico_36_copy_gy),
              ],
            ),
          ),
        )
      ],
    );
  }
}
