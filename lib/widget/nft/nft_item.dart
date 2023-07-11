import 'dart:async';
import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/util/http_resource_util.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';


class NftItem extends StatefulWidget {
  final PlayerNftModel playerNftModel;
  final Function(dynamic)? successFunc;
  final double width;

  NftItem(this.playerNftModel, this.width, {this.successFunc});

  @override
  State<NftItem> createState() => _NftItemState();
}

class _NftItemState extends State<NftItem> {

  final double itemPadding = Zeplin.size(20);
  final Completer<bool> completer = Completer();
  String? imgUrl;

  @override
  void initState() {
    super.initState();

    if(ImageUtil.hasIpfsStartWidth(widget.playerNftModel.imgUrl) && Config.ipfsServiceAddr.value == null)
      Config.ipfsServiceAddr.addListener(ifpsListener);

    imgUrl = ImageUtil.getNftImgUrl(widget.playerNftModel.blockchainNetType, widget.playerNftModel.imgUrl, widget.playerNftModel.contractAddress, widget.playerNftModel.tokenId, widget.playerNftModel.nftRegTime ?? widget.playerNftModel.regTime);
  }


  void ifpsListener() {
    if(Config.ipfsServiceAddr.value != null) {
      imgUrl = ImageUtil.convertRawImgUrl(widget.playerNftModel.imgUrl);
      if(mounted)
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return InkWell(
        borderRadius: BorderRadius.all(Radius.circular(Zeplin.size(26.0))),
        onTap: () async {

          if (!completer.isCompleted && imgUrl == null) {
            return;
          }
          if (await completer.future) {

            FullScreenSpinner.show(context);
            LogWidget.debug("playerNftModel ${widget.playerNftModel.nftName} ${imgUrl}");
            Uint8List? bytes = await HttpResourceUtil.downloadBytes(imgUrl!);
            FullScreenSpinner.hide();

            if(bytes == null) {
              SquareDefaultDialog.showSquareDialog(
                title: L10n.popup_04_fail_load_image_title,
                content: Text(L10n.popup_05_fail_load_image_content, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)), textAlign: TextAlign.center),
                button1Text: L10n.common_02_confirm
              );
              return;
            }

            HomeNavigator.push(RoutePaths.common.crop, arguments: {"bytes": bytes, "nftModel": widget.playerNftModel, "cropType": CropType.pfp, "isNftListBeforePage": true},
              popAction: (value) {
                if (value == null || value == true)
                  return;


                widget.successFunc?.call(value);

                if((value as Map<String, dynamic>)['isNftListBeforePage'] == true) {
                  HomeNavigator.pop();
                }

              });
          }
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: itemPadding / 2),
              child: Stack(
                children: [
                  ClipRRect(
                    child: SizedBox(
                      width: constraints.minWidth - itemPadding,
                      height: constraints.minWidth - itemPadding,
                      child: _buildImage()),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  Positioned(
                    child: Container(
                        padding: EdgeInsets.all(Zeplin.size(5)),
                        child: Image.asset(widget.playerNftModel.blockchainNetType.chainIcon, width: widget.width / 10),
                        decoration: new BoxDecoration(color: CustomColor.paleGrey, shape: BoxShape.circle)),
                    left: Zeplin.size(10),
                    top: Zeplin.size(10),
                  ),
                ],
              ),
            ),
            SizedBox(height: Zeplin.size(14)),
            Row(
              children: [
                SizedBox(width: Zeplin.size(20)),
                Expanded(child: Text(widget.playerNftModel.nftName ?? widget.playerNftModel.tokenId, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis))),
              ],
            ),
            SizedBox(height: Zeplin.size(4)),
            Row(
              children: [
                SizedBox(width: Zeplin.size(20)),
                Expanded(child: Text(widget.playerNftModel.squareName ?? SquareModel.smallerWallet(widget.playerNftModel.contractAddress), style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis))),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNoImage() {
    return Container(
      color: CustomColor.grey3,
      child: Center(
        child: Text(L10n.my_07_01_no_image, style: TextStyle(color: CustomColor.blueyGrey,
            fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),),
      ),
    );
  }

  Widget _buildImage() {

    if(imgUrl == null)
      return _buildNoImage();

   return ExtendedImage.network(
      imgUrl!,
      fit: BoxFit.cover,
      timeLimit: Duration(seconds: 10),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.completed:
            if (!completer.isCompleted) {
              completer.complete(true);
            }
            break;
          case LoadState.failed:
            if (!completer.isCompleted) {
              if(ImageUtil.hasIpfsStartWidth(widget.playerNftModel.imgUrl))
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ifpsListener();
                });

              return _buildNoImage();
            }
            return _buildNoImage();
          case LoadState.loading:
            return Container(color: CustomColor.paleGrey);
        }
        return null;
      },
    );
  }
}
