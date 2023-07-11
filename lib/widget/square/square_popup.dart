import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/deep_link_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';

class SquarePopup extends StatefulWidget {
  final SquareModel squareModel;
  final HomeWidget rootWidget;
  final VoidCallback leaveFunc;
  const SquarePopup({Key? key, required this.squareModel, required this.rootWidget, required this.leaveFunc}) : super(key: key);

  @override
  _SquarePopupState createState() => _SquarePopupState();
}

class _SquarePopupState extends State<SquarePopup> {
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;
  late bool isSideNavi;
  late bool isJoined;


  @override
  void initState() {
    super.initState();

    screenWidthNotifier.addListener(() {
      SquarePopUpMenu.hide;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void copyLink() async {

    LogWidget.debug("square link : ${DeepLinkManager.getSquareLink(widget.squareModel.chainNetType, widget.squareModel.contractAddress, widget.squareModel.squareId)}");

    try {
      await CopyUtil.copyText(DeepLinkManager.getSquareLink(widget.squareModel.chainNetType, widget.squareModel.contractAddress, widget.squareModel.squareId), () {
        ToastOverlay.show(buildContext: context, text: L10n.square_01_10_url_copied, rootWidget: widget.rootWidget);
      });
    } catch(e) {
      LogWidget.debug("copy link error : $e");
    }
  }

  void showToolTip() {
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset startOffset, Size rootWidgetSize, Size popUpSize) {

      Offset offset = Offset(startOffset.dx - popUpSize.width + 20, startOffset.dy +20);

      return GetPopUpOffsetCallbackResponse(offset);
    });
  }

  @override
  Widget build(BuildContext context) {



    isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;
    isJoined = (widget.squareModel.squareType == SquareType.token || widget.squareModel.squareType == SquareType.etc || widget.squareModel.squareType == SquareType.user) && widget.squareModel.joined == true;


    squarePopUpItems = [
      SquarePopUpItem(
          assetPath: Assets.img.ico_46_sh_bk,
          name: L10n.square_01_39_copy_link,
          onTap: copyLink),
      if(widget.squareModel.chainNetType == ChainNetType.user && widget.squareModel.joined == true)
        SquarePopUpItem(
          assetPath: Assets.img.edit,
          name: L10n.ai_01_edit_ai_square,
          onTap: () async {

            ContactModel? aiPlayer = await SquareManager().getAiMemberSquare(widget.squareModel.squareId);
            if(aiPlayer == null)
              return;

            HomeNavigator.push(RoutePaths.square.edit, arguments: { "square": widget.squareModel, "aiPlayerId": aiPlayer.playerId});
          }
        ),
      if(isSideNavi)
        SquarePopUpItem(
            assetPath: Assets.img.ico_46_x_bk,
            name: L10n.square_01_40_close_square,
            onTap: () => HomeNavigator.popTwoDepth()),
      if(isJoined)
        SquarePopUpItem(
            assetPath: Assets.img.ico_36_leave,
            name: L10n.square_01_43_leave,
            onTap: widget.leaveFunc.call),
    ];

    if(!isSideNavi && (widget.squareModel.squareType == SquareType.nft || !isJoined))
      return IconButton(
        padding: EdgeInsets.zero,
        tooltip: L10n.square_01_09_url_copy,
        onPressed: copyLink,
        icon: Icon46(Assets.img.ico_46_sh_bk)
      );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: globalKey,
        onTap: () => showToolTip(),
        child: Container(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(maxWidth: Zeplin.size(360)),
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon46(Assets.img.ico_46_more)
        ),
      ),
    );
  }
}

