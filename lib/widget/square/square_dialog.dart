import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/square/square_item.dart';
import 'package:square_web/widget/toast/center_toast_overlay.dart';

class SquareDialog extends StatelessWidget {
  final SquareModel square;
  final bool joined;
  final bool popBeforeWidget;
  static final LayerLink layerLink = LayerLink();

  SquareDialog({super.key, required this.square, required this.joined, this.popBeforeWidget = false});

  static void show({required SquareModel square, required bool joined, bool popBeforeWidget = false}) {
    SquareDefaultDialog.showSquareDialog(
      padding: EdgeInsets.only(top: Zeplin.size(11, isPcSize: true), right: Zeplin.size(11, isPcSize: true), left: Zeplin.size(11, isPcSize: true), bottom: Zeplin.size(15, isPcSize: true)),
      content: SquareDialog(square: square, joined: joined, popBeforeWidget: popBeforeWidget),
      toastMessage: Align(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: Offset(Zeplin.size(-82, isPcSize: true), Zeplin.size(-23, isPcSize: true)),
          child: CompositedTransformTarget(link: layerLink)),
      )
    );
  }

  void copyLink(String text, BuildContext context, isSquare) {
    CopyUtil.copyText(text, () {
      CenterToastOverlay.show(buildContext: context, text: isSquare ? L10n.square_01_10_url_copied : L10n.common_18_copied, layerLink: layerLink);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => copyLink(DeepLinkManager.getSquareLink(square.chainNetType, square.contractAddress, square.squareId), context, true),
                child: Icon46(Assets.img.ico_46_sh_bk),
              ),
            ),
            SizedBox(width: Zeplin.size(30)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: SquareDefaultDialog.closeDialog(),
                child: Icon46(Assets.img.ico_46_x_bk),
              ),
            ),
          ],
        ),
        SquareImage(square, width: Zeplin.size(317), height: Zeplin.size(317), showChainIcon: true),
        SizedBox(height: Zeplin.size(10, isPcSize: true)),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Zeplin.size(246, isPcSize: true)
          ),
          child: Text("${square.name}", maxLines: 2, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)),
        SizedBox(height: Zeplin.size(2)),

        if(square.squareType == SquareType.nft)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => copyLink(square.contractAddress, context, false),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(SquareModel.smallerWallet(square.contractAddress), style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                  SizedBox(width: Zeplin.size(10)),
                  Icon36(Assets.img.ico_36_copy_gy)
                ],
              ),
            ),
          ),

        SizedBox(height: Zeplin.size(10, isPcSize: true)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Zeplin.size(18),
              height: Zeplin.size(18),
              decoration: BoxDecoration(color: CustomColor.dartMint, shape: BoxShape.circle),
            ),
            SizedBox(width: Zeplin.size(10)),
            Text("${square.onlineNum ?? 0}", style: TextStyle(color: CustomColor.dartMint, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
            Text(L10n.square_01_07_online, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
          ],
        ),
        SizedBox(height: Zeplin.size(4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon24(Assets.img.ico_26_fre_gr),
            SizedBox(width: Zeplin.size(10)),
            Text("${square.memberCount ?? 0}${L10n.square_01_08_participating}", style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
          ],
        ),
        SizedBox(height: Zeplin.size(50)),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            child: PebbleRectButton(
              borderColor: joined ? CustomColor.azureBlue : CustomColor.paleGrey,
              backgroundColor: joined ? CustomColor.azureBlue : CustomColor.paleGrey,
              onPressed: () => joined ? enterSquare(square, popBeforeWidget: popBeforeWidget, isPopup: true) : null,
              child: Center(child: Text(joined ? L10n.profile_04_01_enter : L10n.profile_06_01_nft_square, style: TextStyle(color: joined ? Colors.white : CustomColor.blueyGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500))),
            ),
            height: Zeplin.size(96),
          ),
        ),
      ],
    );
  }

  static void enterSquare(SquareModel square, {bool popBeforeWidget = false, bool isPopup = false }) {
    HomeNavigator.clearTwoDepthPopUp();

    if(isPopup) SquareDefaultDialog.closeDialog().call();
    if(popBeforeWidget) HomeNavigator.pop();

    HomeNavigator.push(RoutePaths.square.squareChat, arguments: square, moveTab: TabCode.square);
  }
}
