import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';

class SquareImage extends StatefulWidget {
  final SquareModel square;
  final double width;
  final double height;
  final bool showChainIcon;
  final Function()? remove;
  final double borderRadius;
  final bool hasBackground;

  SquareImage(this.square, {required this.width, required this.height, this.showChainIcon = false, this.remove, this.borderRadius = 13, this.hasBackground = true});


  @override
  State<SquareImage> createState() => _SquareImageState();
}

class _SquareImageState extends State<SquareImage> {

  String? imgUrl;

  @override
  void initState() {
    super.initState();

    /*if(ImageUtil.hasIpfsStartWidth(widget.square.squareImgUrl) && Config.ipfsServiceAddr.value == null)
      Config.ipfsServiceAddr.addListener(ifpsListener);

    if(widget.square.squareType == SquareType.nft)
      imgUrl = ImageUtil.getNftImgUrl(widget.square.chainNetType, widget.square.squareImgUrl, widget.square.contractAddress, widget.square.squareId, widget.square.modTime);
    else
      */
    imgUrl = StringUtil.getProfileImgUrlWithModTime(widget.square.squareImgUrl ?? "", widget.square.modTime);
  }

  void ifpsListener() {
    if(Config.ipfsServiceAddr.value != null) {
      imgUrl = ImageUtil.convertRawImgUrl(widget.square.squareImgUrl);
      if(mounted)
        setState(() {});
    }
  }

  Widget _buildNoImage(String? squareName) {
    return Container(
      color: widget.square.bgColor,
      child: Center(
        child: Text("${squareName != null ? squareName.substring(0, min(3, squareName.length)) : widget.square.contractAddress.substring(0, 3)}",
            style: TextStyle(fontSize: widget.width / 3, color: widget.square.textColor, fontWeight: FontWeight.w500))));
  }

  @override
  Widget build(BuildContext context) {
    String? squareName = widget.square.squareName;
    return ClipRRect(
      child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(squareName),
              if (widget.showChainIcon)
                Positioned(
                  child: _buildSymbol(),
                  left: Zeplin.size(14),
                  top: Zeplin.size(14)
                ),
              if (widget.remove != null)
                Positioned(
                  child: GestureDetector(
                    onTap: widget.remove,
                    child: Image.asset(Assets.img.ico_40_x_gy, width: widget.width / 12,),
                  ),
                  right: Zeplin.size(14),
                  top: Zeplin.size(14),
                ),
            ],
          )),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
    );
  }

  Widget _buildImage(String? squareName) {
    if(widget.square.squareImgUrl == null)
      return _buildNoImage(squareName);

    bool isAiChatSquare = SquareModel.isAiChatSquare(widget.square.squareId);

    if(widget.square.squareType == SquareType.token && !(SquareModel.hasAiMemberChatSquare(widget.square.squareId)))
      return Container(
        color: widget.hasBackground == true ? CustomColor.paleGrey : Colors.transparent,
        width: widget.width,
        height: widget.height,
        child: Center(child: Image.network(widget.square.squareImgUrl!,
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return _buildNoImage(squareName);
            },
          width: Zeplin.size(96, isPcSize: true), height: Zeplin.size(96, isPcSize: true)))
      );

    String? _imgUrl = StringUtil.getProfileImgUrlWithModTime((isAiChatSquare ? widget.square.squareImgUrl : imgUrl) ?? "", widget.square.modTime);

    if(_imgUrl == null)
      return Container(color: CustomColor.paleGrey);

    return ExtendedImage.network(_imgUrl, fit: BoxFit.cover,
      timeLimit: Duration(seconds: 10),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.completed:
            break;
          case LoadState.loading:
            return Container(color: CustomColor.paleGrey);
          case LoadState.failed:
            if(ImageUtil.hasIpfsStartWidth(widget.square.squareImgUrl))
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ifpsListener();
              });

            return _buildNoImage(squareName);

        }
        return null;
      });
  }

  Widget _buildSymbol() {
    if(widget.square.squareType == SquareType.token && widget.square.symbol == null) return Container();

    if(widget.square.chainNetType == ChainNetType.user)
      return Container();

    return Container(
      padding: EdgeInsets.all(Zeplin.size(5)),
      child: Image.asset(widget.square.chainNetType.chainIcon, width: max(16.5, widget.width / 14)),
      decoration: new BoxDecoration(color: CustomColor.paleGrey, shape: BoxShape.circle)
    );
  }
}

class SquareItem extends StatelessWidget {
  final SquareModel square;
  final Function()? onTap;
  final Function()? remove;

  SquareItem(this.square, {this.onTap, this.remove}) : super(key: ValueKey("square_item_${square.squareId}"));

  static const double squareItemPadding = 6.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(bottom: squareItemPadding),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(Zeplin.size(26.0))),
          onTap: onTap,
          child: Container(
            width: constraints.maxWidth,
            padding: EdgeInsets.only(top: SquareItem.squareItemPadding),
            child: Column(
              children: [
                SquareImage(square,
                    width: constraints.minWidth - squareItemPadding * 2,
                    height: constraints.minWidth - squareItemPadding * 2,
                    showChainIcon: true,
                    remove: remove),
                SizedBox(
                  height: Zeplin.size(14),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: squareItemPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(square.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: CustomColor.darkGrey,
                                fontSize: Zeplin.size(28),
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: Zeplin.size(3, isPcSize: true),),
                        Row(children: [
                          Icon26(Assets.img.ico_26_fre_gr),
                          Text(
                            " ${square.memberCount ?? 0}".numComma,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: CustomColor.taupeGray,
                                fontSize: Zeplin.size(24),
                                fontWeight: FontWeight.w500),
                          )
                        ])
                      ],
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
