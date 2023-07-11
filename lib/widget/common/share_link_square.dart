import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/toast/center_toast_overlay.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';

class ShareLinkSquare extends StatelessWidget {
  final String squareId;
  final String contractAddress;
  final ChainNetType chainNetType;
  final HomeWidget? rootWidget;
  final bool isSize36;
  const ShareLinkSquare({Key? key, required this.squareId, required this.contractAddress, required this.chainNetType, this.rootWidget, this.isSize36 = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          CopyUtil.copyText(DeepLinkManager.getSquareLink(chainNetType, contractAddress, squareId), () {
            if(rootWidget != null) {
              ToastOverlay.show(buildContext: context, text: L10n.common_61_chat_link_copy, rootWidget: rootWidget!);
            } else {
              CenterToastOverlay.show(buildContext: context, text: L10n.common_61_chat_link_copy,);
            }
          });
        },
        child: isSize36 == true ? Icon36(Assets.img.ico_46_sh_bk) : Icon46(Assets.img.ico_46_sh_bk),
      ),
    );
  }
}
