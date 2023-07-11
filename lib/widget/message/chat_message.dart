import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:square_web/bloc/message_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/delegate/message_delegate.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/message/my_message.dart';
import 'package:square_web/widget/message/system_message.dart';
import 'package:square_web/widget/profile/profile_image.dart';
import 'package:square_web/widget/shape_borders.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';


enum MessageAnimType {
  popUp,
  color,
  vibrate
}

class ChatMessage extends StatelessWidget with MessageDelegate {
  final MessageModel messageModel;
  final Map<MessageAnimType, AnimationController?>? animationController;
  final String? printedMessageTime;
  final bool? printContact;
  final Color? chatMessageBackgroundColor;
  final MessageBloc messageBloc;
  final HomeWidget? rootWidget;
  final String? typingText;

  Color fillColor = CustomColor.paleGrey;

  ChatMessage({required this.messageModel, this.animationController, this.printedMessageTime, this.printContact = false, this.chatMessageBackgroundColor, required this.messageBloc, this.rootWidget, this.typingText}) : super(key: ValueKey(messageModel.messageId));

  factory ChatMessage.newMessage(MessageModel messageModel, {TickerProvider? vsyncTickerProvider, String? printedMessageTime, bool? printContact, Color? chatMessageBackgroundColor, required MessageBloc messageBloc, required HomeWidget rootWidget, String? typingText}) {
    Map<MessageAnimType, AnimationController?> animationController = {};
    if (messageModel.hasAnimation) {
      animationController = ChatMessageManager().initMessageAnim(messageModel);
    } else {
      animationController = ChatMessageManager().getMessageAnim(messageModel);
    }

    if (messageModel.messageType == MessageType.system) {
      return SystemMessage(
          messageModel: messageModel,
          newAnimationController: () => AnimationController(
                duration: Duration(milliseconds: 600),
                vsync: vsyncTickerProvider!,
              ),
          popUpAnimController: animationController[MessageAnimType.popUp],
          messageBloc: messageBloc);
    } else {
      if (messageModel.sender!.playerId == MeModel().playerId) {
        return MyMessage(messageModel: messageModel, animationController: animationController, printedMessageTime: printedMessageTime, messageBloc: messageBloc, rootWidget: rootWidget);
      } else {
        return ChatMessage(messageModel: messageModel, animationController: animationController, printedMessageTime: printedMessageTime, printContact: printContact, chatMessageBackgroundColor: chatMessageBackgroundColor, messageBloc: messageBloc, rootWidget: rootWidget, typingText: typingText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return baseWidget(context);
    } else {
      if(animationController!.length == 3) {
        if(!animationController![MessageAnimType.vibrate]!.isCompleted
            || !animationController![MessageAnimType.color]!.isCompleted) {
          return SizeTransition(
              sizeFactor: CurvedAnimation(
                  parent: animationController![MessageAnimType.popUp]!,
                  curve: Curves.easeOut),
              axisAlignment: 0.0,
              child: AnimatedBuilder(
                animation: animationController![MessageAnimType.vibrate]!,
                builder: (context, child) {
                  if(animationController![MessageAnimType.vibrate]!.isCompleted) {
                    return child!;
                  }
                  return Transform.translate(
                    offset: Offset(-5 + random.nextDouble() * 10, 0),
                    child: child,);
                },
                child: baseWidget(context),
              ));
        }
      }

      if(animationController!.containsKey(MessageAnimType.popUp)){
        return SizeTransition(
            sizeFactor: CurvedAnimation(parent: animationController![MessageAnimType.popUp]!, curve: Curves.easeOut),
            axisAlignment: 0.0,
            child: baseWidget(context));
      }
      return baseWidget(context);
    }
  }

  int getUnreadMemberCount() {
    List<RoomMemberModel>? members = RoomManager().currentChatRoom?.members;
    if((members?.length ?? 0) == 0)
      return 0;

    return members!.where((m) => m.playerId != MeModel().playerId
        && m.lastReadTime! < messageModel.sendTime!).length;
  }

  Widget profileImage() {
    return Container(
      width: Zeplin.size(57),
      margin: EdgeInsets.only(right: Zeplin.size(12)),
      alignment: Alignment.center,
      child: printContact! ? ProfileImage(contactModel: messageModel.sender!.toContact(), size: 60, isShowBlueDot: false) : null
    );
  }

  Container baseWidget(BuildContext context) {

    return messageModel.status != MessageStatus.removedForMe ?
      Container(
        margin: EdgeInsets.only(bottom: printedMessageTime != null ? Zeplin.size(29) : Zeplin.size(6), left: Zeplin.size(24)),
        padding: EdgeInsets.only(left: Zeplin.size(16), right: Zeplin.size(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => HomeNavigator.push(RoutePaths.profile.player, arguments: messageModel.playerId),
                child: profileImage(),
              ),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(printContact!)
                          FutureBuilder(
                            future: messageModel.sender!.loadComplete!.future,
                            builder: (context, snapshot) {
                              return Container(
                                  margin: EdgeInsets.only(bottom: Zeplin.size(6)),
                                  child: Text(
                                    messageModel.sender!.toContact().smallerName,
                                    style: systemMessageGreyDefaultStyle,
                                  ));
                            },
                          ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(child: buildMessageWidget()),
                            SizedBox(
                              width: Zeplin.size(10),
                            ),
                            messageModel.messageType != MessageType.link ?
                              _buildSubMessage() : Container()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) : Container();
  }

  Widget _buildSubMessage() {
    if(messageModel.messageType == MessageType.typing)
      return Container();
    // final unreadMemberCount = getUnreadMemberCount();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if(messageBloc is ChatMessageBloc && !(messageBloc  as ChatMessageBloc).model.isBlocked != false && unreadMemberCount > 0)
          //   Text("$unreadMemberCount",
          //       style: systemMessageTimeStyle.copyWith(color: CustomColor.azureBlue)),
          if(printedMessageTime != null)
            Text(
              printedMessageTime!,
              style: systemMessageTimeStyle,
            ),
        ],
      );
  }

  Widget buildLinkInternal(String thumbnailUrl, String fullContentUrl) {
    dynamic map;
    try {
      map = json.decode(fullContentUrl);
    } catch(e) {
      return Container();
    }
    String title = map["title"] ?? "";
    String description = map["description"] ?? "";
    String url = map["link"] ?? "";
    return GestureDetector(
      onTap: () async {
        if(!url.contains("https://") && !url.contains("http://")) {
          url = "https://$url";
        }
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
      child: Container(
        width: Zeplin.size(min(260, max(80, DeviceUtil.screenWidth - 200)), isPcSize: true),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: CustomColor.grey3
        ),
        // padding: EdgeInsets.all(13),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(13.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ExtendedImage.network(
                        thumbnailUrl, width: constraints.maxWidth, height: Zeplin.size(109, isPcSize: true), fit: BoxFit.cover,
                        loadStateChanged: (ExtendedImageState state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.failed:
                              return Container(
                                color: CustomColor.paleGrey,
                              );
                            default:
                              break;
                          }
                          return null;
                        },);
                    },
                  )
              ),
              SizedBox(height: Zeplin.size(8, isPcSize: true),),
              Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Zeplin.size(14, isPcSize: true), fontWeight: FontWeight.w500, color: Colors.black),),
              SizedBox(height: Zeplin.size(4, isPcSize: true),),
              Text(description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true), fontWeight: FontWeight.w500, color: CustomColor.grey4),),
              /*SizedBox(height: Zeplin.size(4, isPcSize: true),),
              Text(url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true), fontWeight: FontWeight.w500, color: CustomColor.grey4),),*/
            ],
          ),
        ),
      ),
    );
  }

  static bool isValidLinkThumbnailUrl(MessageModel messageModel) {
    if(messageModel.thumbnailUrl != linkMessageFailed && messageModel.thumbnailUrl != linkMessageNull) {
      return true;
    }
    return false;
  }

  bool isValidLink(String? thumbnailUrl, String? fullContentUrl) {
    if(thumbnailUrl == null || fullContentUrl == null)
      return false;
    if(thumbnailUrl == linkMessageFailed || thumbnailUrl == linkMessageNull)
      return false;
    if(fullContentUrl == linkMessageFailed || fullContentUrl == linkMessageNull)
      return false;
    return true;
  }

  Widget _buildMessageWithSubMessage(Color messageColor, Widget subMessage, {Widget? child}) {
    bool isMyMessage = messageModel.messageSender == MessageSender.me;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMyMessage ? Padding(
          padding: EdgeInsets.only(right: Zeplin.size(10)),
          child: subMessage,
        ) : Container(),
        child ?? buildTextMessage(messageModel, messageColor, rootWidget, colorAnim : animationController?[MessageAnimType.color]),
        !isMyMessage ? Padding(
          padding: EdgeInsets.only(left: Zeplin.size(10)),
          child: subMessage,
        ) : Container()
      ],
    );
  }

  Widget _buildLinkWrapMessage(Color messageColor, Widget subMessage, Widget? child) {
    if(child == null) {
      return _buildMessageWithSubMessage(messageColor, subMessage);
    }
    bool isMyMessage = messageModel.messageSender == MessageSender.me;
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: isMyMessage ? WrapCrossAlignment.end : WrapCrossAlignment.start,
      children: [
        buildTextMessage(messageModel, messageColor, rootWidget),
        SizedBox(height: Zeplin.size(8, isPcSize: true),),
        _buildMessageWithSubMessage(messageColor, subMessage, child: child)
      ],
    );
  }

  Widget _buildLinkMessage(Color messageColor, Widget subMessage) {
    if(messageModel.thumbnailUrl != null && messageModel.fullContentUrl != null) {
      if(isValidLink(messageModel.thumbnailUrl, messageModel.fullContentUrl)) {
        return _buildLinkWrapMessage(messageColor, subMessage, buildLinkInternal(messageModel.thumbnailUrl!, messageModel.fullContentUrl!));
      }
    } else {
      StreamController<Map<String, String?>>? streamController = ChatMessageManager().getLinkMessageMap(messageModel);
      if(streamController != null) {
        return StreamBuilder<Map<String, String?>>(
            stream: streamController.stream,
            builder: (context, snapshot) {
              Widget? child;
              if(snapshot.hasData) {
                Map<String, String?>? data = snapshot.data;
                if(data != null) {
                  String? thumbnailUrl = data["thumbnailUrl"];
                  String? fullContentUrl = data["fullContentUrl"];
                  if(isValidLink(thumbnailUrl, fullContentUrl)) {
                    child = buildLinkInternal(thumbnailUrl!, fullContentUrl!);
                  }
                }
              }
              return _buildLinkWrapMessage(messageColor, subMessage, child);
            });
      }
    }
    return _buildMessageWithSubMessage(messageColor, subMessage);
  }

  Widget  buildMessageWidget({Widget? subMessage}) {
    if(messageModel.status == MessageStatus.restricted)
      return buildReportedMessage(messageModel);
    
    if(subMessage == null) {
      subMessage = _buildSubMessage();
    }

    Color messageColor = messageModel.messageSender == MessageSender.me ? CustomColor.lemon : chatMessageBackgroundColor ?? CustomColor.paleGrey;

    switch (messageModel.messageType){
      case MessageType.text:
      case MessageType.markdown:
        return buildTextMessage(messageModel, messageColor, rootWidget, colorAnim : animationController?[MessageAnimType.color], typingText: typingText);
      case MessageType.link:
          return _buildLinkMessage(messageColor, subMessage);
      case MessageType.image:
        // if (messageModel.thumbnailUrl != null/* && messageModel.messageBody == "#loading#"*/)
        return buildImageMessage(messageModel, messageColor, rootWidget);
        return SquareCircularProgressIndicator();

      // case MessageType.video:
      //   if (messageModel.fullContentUrl != null && messageModel.messageBody == "#loading#")
      //     return buildVideoMessage(messageModel, messageColor);
      //   return SquareCircularProgressIndicator();

      case MessageType.emoticon:
        return buildEmoticonMessage(messageModel, messageColor, rootWidget);

      case MessageType.typing:
        return buildTypingMessage(messageColor);

      default:
        return Container(
          decoration: ShapeDecoration(shape: Pebble4DividedBorder(color: messageColor, strokeWidth: 0.2), color: messageColor),
          height: Zeplin.size(76),
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(19)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon40(Assets.img.ico_40_edi),
              SizedBox(width: spaceS),
              Flexible(child:Text("old ver message.\n${messageModel.messageBody?.substring(0, messageModel.messageBody!.length > 20 ? 20 : messageModel.messageBody!.length)}...", style: deletedChatTextStyle))
            ],
          ),
        );
    }
  }
}
