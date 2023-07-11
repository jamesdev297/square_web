import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';


Map<String, Uint8List> imageMsgCache = {};

class ImageMessage extends StatefulWidget {
  final MessageModel messageModel;
  final Color messageColor;
  final HomeWidget? rootWidget;

  const ImageMessage({Key? key, required this.messageModel, required this.messageColor, required this.rootWidget}) : super(key: key);

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage> {

  bool isShown = false;
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;
  late bool hasReport;
  double popUpItemHeight = Zeplin.size(90);
  double popUpItemWidth = Zeplin.size(255);
  late Uint8List bytes;

  @override
  void initState() {
    super.initState();
    var temp = imageMsgCache[widget.messageModel.messageId];
    temp ??= imageMsgCache.putIfAbsent(widget.messageModel.messageId, () => base64Decode(widget.messageModel.messageBody!));
    bytes = temp;

    screenWidthNotifier.addListener(() {
      if (isShown) {
        isShown = false;
        SquarePopUpMenu.hide;
        if(mounted)
          setState(() {});
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    hasReport = widget.messageModel is SquareChatMsgModel && !MeModel().isMe(widget.messageModel.playerId);
    if (hasReport)
      squarePopUpItems = [
        SquarePopUpItem(
            assetPath: Assets.img.ico_36_report_bk,
            name: L10n.square_01_25_report,
            onTap: () => onSelected(0)),
      ];

    return Listener(
      key: globalKey,
      onPointerDown: (event) {
        if(hasReport == false)
          return;

        _onPointerDown(context, event);
        },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onLongPressStart: (longPress) {
            if(hasReport == false)
              return;

            showToolTip(longPress.globalPosition);
          },
          onTap: () {
            HomeNavigator.push(RoutePaths.common.fullImageView, arguments: {"imageUrl": widget.messageModel.messageBody!, "msgSendTime": widget.messageModel.sendTime!, "name": widget.messageModel.sender!.toContact().smallerName});
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ExtendedImage.memory(bytes,
              fit: BoxFit.cover,
              loadStateChanged: (state) {
                if(state.extendedImageLoadState == LoadState.completed) {
                  int? originWidth = state.extendedImageInfo?.image.width;
                  int? originHeight = state.extendedImageInfo?.image.height;
                  if(originWidth == null || originHeight == null) {
                    return _buildUnKnownSizeExpiredMedia(true);
                  }

                  double width = originWidth * 1.0;
                  double height = originHeight * 1.0;
                  double ratio = 1.0;

                  if(width != null && height != null) {
                    if(width < imageMessageMinWidth) {
                      ratio = imageMessageMinWidth / width;
                      width = imageMessageMinWidth;
                      height = min(imageMessageMaxHeight, max(imageMessageMinHeight, ratio * height));
                    } else if(width >= imageMessageMinWidth && width < imageMessageMaxWidth) {
                      if(height < imageMessageMinHeight) {
                        ratio = imageMessageMinWidth / height;
                        width = min(imageMessageMaxWidth, ratio * width);
                        height = imageMessageMinHeight;
                      } else if(height > imageMessageMaxHeight) {
                        ratio = imageMessageMaxHeight / height;
                        width = max(imageMessageMinWidth, ratio * width);
                        height = imageMessageMaxHeight;
                      }
                    } else {
                      ratio = imageMessageMaxWidth / width;
                      width = imageMessageMaxWidth;
                      height = min(imageMessageMaxHeight, max(imageMessageMinHeight, ratio * height));
                    }

                    return Container(
                        width: Zeplin.size(width * 1.0),
                        height: Zeplin.size(height * 1.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.0),
                            color: CustomColor.paleGreyTwo,
                            border: Border.all(color: CustomColor.paleLilac, width: 1)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13.0),
                          child: ExtendedRawImage(
                            image: state.extendedImageInfo!.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.topLeft,
                          ),
                        )
                    );
                  }
                  return _buildUnKnownSizeExpiredMedia(true);
                } else if(state.extendedImageLoadState == LoadState.failed) {
                  return _buildUnKnownSizeExpiredMedia(true);
                }
                return null;
              },
            )
          ),
        ),
      ),
    );
  }

  void _onPointerDown(BuildContext context, PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
      showToolTip(event.position);
    }
  }

  void onShowFunc(bool isShow) {
    FocusManager.instance.primaryFocus?.unfocus();
    isShown = isShow;
    if(mounted)
      setState(() {});
  }

  void onSelected(int value) async {
    switch(value) {
      case 0:
        SquareChatMsgModel squareChatMsgModel = widget.messageModel as SquareChatMsgModel;
        if(await SquareManager().checkReportedSquareMessage(squareChatMsgModel) == CustomStatus.ALREADY_REPORTED_MESSAGE) {
          SquareDefaultDialog.showSquareDialog(
            title: L10n.square_01_28_reported_dialog_title,
            description: L10n.square_01_29_reported_dialog_context,
            button1Text: L10n.common_02_confirm,
          );
          return;
        }

        SquareDefaultDialog.showSquareDialog(
            title: L10n.square_01_26_report_dialog_title,
            description: L10n.square_01_27_report_dialog_context,
            button1Text: L10n.common_03_cancel,
            button1Action: SquareDefaultDialog.closeDialog(),
            button2Text: L10n.common_02_confirm,
            button2Action: () async {
              int status = await SquareManager().reportSquareMessage(squareChatMsgModel);
              SquareDefaultDialog.closeDialog().call();

              switch (status) {
                case HttpStatus.badRequest:
                  LogWidget.info("can't report your message");
                  return;
                case CustomStatus.ALREADY_REPORTED_MESSAGE:
                  SquareDefaultDialog.showSquareDialog(
                    title: L10n.square_01_28_reported_dialog_title,
                    description: L10n.square_01_29_reported_dialog_context,
                    button1Text: L10n.common_02_confirm,
                  );
                  break;
                case CustomStatus.EXCEED_ONE_DAY_REPORT_LIMIT:
                  SquareDefaultDialog.showSquareDialog(
                      title: L10n.square_01_33_report_limit_dialog_title,
                      description: L10n.square_01_34_report_limit_dialog_context,
                      button1Text: L10n.common_02_confirm);
                  break;
                case HttpStatus.ok:
                  ToastOverlay.show(buildContext: context, text: L10n.square_01_38_reported, rootWidget: widget.rootWidget!);
                  break;
              }
            });
        break;
    }
  }

  void showToolTip(Offset pointerOffset) {
    onShowFunc(true);
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset offset, Size size, Size popUpSize) {

      // double padding = 4;
      //
      // final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      // final RenderBox renderBox = context.findRenderObject() as RenderBox;
      // late double dy;
      // late double dx;
      // final msgBoxWidth = renderBox.size.width;
      // final msgBoxHeight = renderBox.size.height;
      // final Offset offset = renderBox.localToGlobal(Offset.zero);
      // final isMyMsg = widget.messageModel.messageSender == MessageSender.me;
      // bool isSlideInUp = false;
      //
      // if (offset.dy < (DeviceUtil.screenHeight / 2)) {
      //   dy = offset.dy + msgBoxHeight + padding;
      // } else {
      //   dy = offset.dy - popUpItemHeight * squarePopUpItems.length - padding;
      //   isSlideInUp = true;
      // }
      //
      // if(isMyMsg) {
      //   if (size.width > TextMessage.popUpItemWidth)
      //     dx = offset.dx;
      //   else
      //     dx = offset.dx - TextMessage.popUpItemWidth + size.width;
      // } else {
      //   dx = offset.dx;
      // }


      return GetPopUpOffsetCallbackResponse(pointerOffset, isSlideUp: false);
    }, onCancel: () => onShowFunc(false));

  }

  Widget _buildUnKnownSizeExpiredMedia(bool isImage) {
    return Container(
        width: Zeplin.size(400),
        height: Zeplin.size(400),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: CustomColor.paleGreyTwo,
            border: Border.all(color: CustomColor.paleLilac, width: 1)
        ),
        child: Center(
            child: Image.asset(isImage ? Assets.img.ico_100_expired_pic : Assets.img.ico_100_expired_mov, width: Zeplin.size(95), height: Zeplin.size(95))
        )
    );
  }
}
