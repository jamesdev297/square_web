import 'dart:async';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/widget/chat/image_message.dart';
import 'package:square_web/widget/chat/text_message.dart';
import 'package:square_web/widget/chat/typing_indicator.dart';
import 'package:square_web/widget/emoticon/emoticon_widget.dart';
import 'package:square_web/widget/message/animated_chat_message.dart';

abstract class MessageDelegate {
  Widget buildTextMessage(MessageModel messageModel, Color messageColor, HomeWidget? rootWidget, {AnimationController? colorAnim, String? typingText}) {

    if (messageModel.status == MessageStatus.normal || messageModel.status == MessageStatus.sendFailed || messageModel.status == MessageStatus.aiSaying) {
      if(colorAnim != null && colorAnim.isAnimating) {
        return AnimatedChatMessage(
            key: ValueKey("${messageModel.messageId}:AnimChat"),
            messageModel: messageModel,
            colorAnim: colorAnim,
            messageColor: messageColor,
        );
      }
      return TextMessage(key:ValueKey("${messageModel.messageId}"), messageModel: messageModel, messageColor: messageColor, rootWidget: rootWidget, typingText: typingText);
    } else {
      return Container();
    }
  }

  Widget _buildEmoticonMessage(MessageModel messageModel, Color messageColor, HomeWidget? rootWidget) {

    return Column(
      children: [
        buildEmoticonWidget(messageModel),
        messageModel.messageBody?.isNotEmpty ?? false
            ? buildTextMessage(messageModel, messageColor, rootWidget)
            : Row(mainAxisSize: MainAxisSize.min, children: [Container()])
      ],
    );
  }

  Widget buildEmoticonWidget(MessageModel messageModel) {
    String? emoticonId = messageModel.contentId;
    if(emoticonId == null)
      return Icon(Icons.error);
    return EmoticonWidget(messageModel);
  }

  Widget buildEmoticonMessage(MessageModel messageModel, Color messageColor, HomeWidget? rootWidget) {

    if (messageModel.status == MessageStatus.removedForMe) {
      return Container();
    }

    Widget result = _buildEmoticonMessage(messageModel, messageColor, rootWidget);
    return result != null ? result : Icon(Icons.error);
  }

  Future<ImageInfo> _getImageInfo(thumbnailUrl) async {
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    Image image = Image.network(thumbnailUrl);

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      completer.complete(info);
    }));

    return completer.future;
  }

  Widget buildImageMessage(MessageModel messageModel, Color messageColor, HomeWidget? rootWidget) {

    if (messageModel.status == MessageStatus.removedForMe) {
      return Container();
    }

    return ImageMessage(messageModel: messageModel, messageColor: messageColor, rootWidget: rootWidget);
  }

  // Future<bool> initVideo(VideoPlayerController controller) async {
  //
  //   try {
  //     await controller.initialize();
  //
  //     return true;
  //   } catch(e) {
  //     LogWidget.debug("Error : $e");
  //
  //     return false;
  //   }
  // }

  // Widget _buildVideo(MessageModel messageModel) {
  //
  //   VideoPlayerController? _controller = VideoPlayerController.network(messageModel.fullContentUrl!);
  //
  //   return FutureBuilder<bool>(
  //     future: initVideo(_controller),
  //     builder: (context, snapshot) {
  //       if(snapshot.hasData == true && snapshot.data == true)
  //         return GestureDetector(
  //           onTap: () {
  //             LogWidget.debug("buildNetworkVideoMessage viewVideo");
  //             HomeNavigator.push(RoutePaths.common.fullVideoView, arguments: messageModel);
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: ClipPebbleRect(
  //               width: Zeplin.size(_controller.value.size.width),
  //               height: Zeplin.size(_controller.value.size.height),
  //               child: Stack(
  //                 children: [
  //                   VideoPlayer(_controller),
  //                   Container(color: Colors.black.withOpacity(0.3)),
  //                   Align(
  //                       alignment: Alignment.center,
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Image.asset(Assets.img.ico_100_play_on, width: Zeplin.size(95), height: Zeplin.size(95)),
  //                           SizedBox(height: spaceS),
  //                         ],
  //                       )
  //                   )
  //                 ],
  //               ),
  //             )
  //           ),
  //         );
  //       if(snapshot.hasData == true && snapshot.data == false)
  //         return _buildUnKnownSizeExpiredMedia(false);
  //
  //       return SquareCircularProgressIndicator();
  //     }
  //   );
  // }

  // Widget _buildImageThumbnail(MessageModel messageModel) {
  //
  //   return GestureDetector(
  //     onTap: () => HomeNavigator.push(RoutePaths.common.fullImageView, arguments: {"imageUrl": messageModel.fullContentUrl!, "msgSendTime": messageModel.sendTime!, "name": messageModel.sender!.toContact().smallerName}),
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 8),
  //       child: ExtendedImage.network(messageModel.fullContentUrl!,
  //         fit: BoxFit.cover,
  //         loadStateChanged: (state) {
  //           if(state.extendedImageLoadState == LoadState.completed) {
  //             int? originWidth = state.extendedImageInfo?.image.width;
  //             int? originHeight = state.extendedImageInfo?.image.height;
  //             if(originWidth == null || originHeight == null) {
  //               return _buildUnKnownSizeExpiredMedia(true);
  //             }
  //
  //             double width = originWidth * 1.0;
  //             double height = originHeight * 1.0;
  //             double ratio = 1.0;
  //
  //             if(width != null && height != null) {
  //               if(width < imageMessageMinWidth) {
  //                 ratio = imageMessageMinWidth / width;
  //                 width = imageMessageMinWidth;
  //                 height = min(imageMessageMaxHeight, max(imageMessageMinHeight, ratio * height));
  //               } else if(width >= imageMessageMinWidth && width < imageMessageMaxWidth) {
  //                 if(height < imageMessageMinHeight) {
  //                   ratio = imageMessageMinWidth / height;
  //                   width = min(imageMessageMaxWidth, ratio * width);
  //                   height = imageMessageMinHeight;
  //                 } else if(height > imageMessageMaxHeight) {
  //                   ratio = imageMessageMaxHeight / height;
  //                   width = max(imageMessageMinWidth, ratio * width);
  //                   height = imageMessageMaxHeight;
  //                 }
  //               } else {
  //                 ratio = imageMessageMaxWidth / width;
  //                 width = imageMessageMaxWidth;
  //                 height = min(imageMessageMaxHeight, max(imageMessageMinHeight, ratio * height));
  //               }
  //
  //               return ClipPebbleRect(
  //                 width: Zeplin.size(width * 1.0),
  //                 height: Zeplin.size(height * 1.0),
  //                 child: ExtendedRawImage(
  //                   image: state.extendedImageInfo!.image,
  //                   fit: BoxFit.cover,
  //                 )
  //               );
  //             }
  //             return _buildUnKnownSizeExpiredMedia(true);
  //           }
  //           return null;
  //         },
  //       )
  //     ),
  //   );
  // }

  Widget _buildUnKnownSizeExpiredMedia(bool isImage) {
    return Container(
        color: CustomColor.paleGreyTwo,
        child: Center(
            child: Image.asset(isImage ? Assets.img.ico_100_expired_pic : Assets.img.ico_100_expired_mov, width: Zeplin.size(95), height: Zeplin.size(95))
        )
    );
  }

  Widget buildTypingMessage(Color messageColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(26), vertical: Zeplin.size(19)),
      constraints: BoxConstraints(minHeight: Zeplin.size(60)),
      decoration: BoxDecoration(
        color: messageColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TypingIndicator(),
    );
  }

  Widget buildReportedMessage(MessageModel messageModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(26), vertical: Zeplin.size(19)),
      constraints: BoxConstraints(minHeight: Zeplin.size(60)),
      decoration: BoxDecoration(
        color: CustomColor.grey1,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(L10n.square_01_30_reported_message, style: TextStyle(color: CustomColor.taupeGray, fontStyle: FontStyle.italic)),
    );
  }
}
