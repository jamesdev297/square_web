
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/square/square_item.dart';
import 'package:square_web/widget/toast/center_toast_overlay.dart';


class SquareProfileByLink extends StatelessWidget {
  const SquareProfileByLink({
    Key? key,
    required this.square,
    required this.completer
  }) : super(key: key);

  final SquareModel square;
  final Completer completer;

  Widget _buildWalletAddress(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          CopyUtil.copyText(square.contractAddress, () {
            CenterToastOverlay.show(buildContext: context);
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${SquareModel.smallerWallet(square.contractAddress)}", style:
            TextStyle(color: CustomColor.grey4,
                fontWeight: FontWeight.w500,
                fontSize: Zeplin.size(28))),
            SizedBox(width: Zeplin.size(14)),
            Icon36(Assets.img.ico_36_copy_gy),
          ],
        ),
      ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          CopyUtil.copyText(DeepLinkManager.getSquareLink(
                              square.chainNetType, square.contractAddress, square.squareId), () {
                            CenterToastOverlay.show(buildContext: context, text: L10n.square_01_39_copy_link,);
                          });
                        },
                        child: Icon46(Assets.img.ico_46_sh_bk),
                      ),
                    )
                  ],
                ),
                SquareImage(square, width: Zeplin.size(316), height: Zeplin.size(316), showChainIcon: true),
                SizedBox(height: Zeplin.size(15, isPcSize: true)),
                ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: Zeplin.size(556)
                    ),
                    child: Text("${square.name}", maxLines: 2, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)),
                SizedBox(height: Zeplin.size(6),),
                if(square.squareType == SquareType.nft)
                  _buildWalletAddress(context),
                SizedBox(height: Zeplin.size(12, isPcSize: true)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
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
                  ),
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