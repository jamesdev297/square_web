import 'package:flutter/material.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/chat_message_bloc.dart';
import 'package:square_web/bloc/message_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/widget/message/message_send_retry_or_cancel_button.dart';

import 'chat_message.dart';

class MyMessage extends ChatMessage {
  MyMessage(
      {required MessageModel messageModel,
        Map<MessageAnimType, AnimationController?>? animationController,
      String? printedMessageTime,
      required MessageBloc messageBloc, required HomeWidget rootWidget})
      : super(
            messageModel: messageModel,
            animationController: animationController,
            printedMessageTime: printedMessageTime,
            printContact: false,
            messageBloc: messageBloc,
            rootWidget: rootWidget) {
    fillColor = CustomColor.lemon;
  }

  @override
  Container baseWidget(BuildContext context) {
    return messageModel.status != MessageStatus.removedForMe
        ? Container(margin: EdgeInsets.symmetric(vertical: Zeplin.size(6), horizontal: Zeplin.size(24)), child: _buildInternalBaseWidget(context))
        : Container();
  }

  Widget _buildInternalBaseWidget(BuildContext context) {
    // 전송중 or 전송실패
    if (messageModel.sendCompleter != null || messageModel.status == MessageStatus.sendFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 전송중
          messageModel.sendCompleter != null
              ? FutureBuilder(
                  future: messageModel.sendCompleter!.future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildNormalMessage(context);
                      /*return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size30),
                          SizedBox(
                            width: Zeplin.size(10),
                          ),
                          Flexible(child: buildMessageWidget()),
                        ],
                      );*/
                    }

                    if (snapshot.hasData) {
                      if (snapshot.data == false) {
                        return _buildSendFailed(context);
                      }
                    }

                    return _buildNormalMessage(context);
                  },
                )
              : _buildSendFailed(context),
          messageModel.sendCompleter != null
              ? FutureBuilder(
                  future: messageModel.sendCompleter!.future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == false) {
                        return _buildSendFailedText();
                      }
                    }
                    return Container();
                  },
                )
              : _buildSendFailedText()
        ],
      );
    } else {
      // 정상
      return Padding(
        padding: EdgeInsets.only(left: Zeplin.size(84), right: Zeplin.size(16)),
        child: _buildNormalMessage(context),
      );
    }
  }

  Widget _buildNormalMessage(BuildContext context) {
    if (messageBloc is ChatMessageBloc) {
      final unreadMemberCount = getUnreadMemberCount();
      Widget subWidget = (!(messageBloc as ChatMessageBloc).model.isBlocked != false) ? _buildUnreadCount(unreadMemberCount) : Container();
      if(messageModel.messageType == MessageType.link) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildMessageWidget(subMessage: subWidget),
            ],
          );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          subWidget,
          SizedBox(
            width: Zeplin.size(10),
          ),
          Flexible(child: buildMessageWidget()),
        ],
      );
    } else {
      Widget subWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (printedMessageTime != null)
            Text(
              printedMessageTime!,
              style: systemMessageTimeStyle,
            ),
        ],
      );
      if(messageModel.messageType == MessageType.link) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildMessageWidget(subMessage: subWidget),
            ],
          );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          subWidget,
          SizedBox(
            width: Zeplin.size(10),
          ),
          Flexible(child: buildMessageWidget()),
        ],
      );
    }
  }

  Widget _buildSendFailed(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MessageSendRetryOrCancelButton(messageModel, messageBloc),
        SizedBox(width: Zeplin.size(10)),
        buildMessageWidget(),
      ],
    );
  }

  Widget _buildSendFailedText() {
    return Column(
      children: [
        SizedBox(
          height: Zeplin.size(4),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              L10n.common_17_not_sent,
              style: TextStyle(color: Colors.red, fontSize: Zeplin.size(19)),
            )
          ],
        )
      ],
    );
  }

  Widget _buildUnreadCount(int unreadMemberCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildUnreadCountInternal(unreadMemberCount),
        if (printedMessageTime != null)
          Text(
            printedMessageTime!,
            style: systemMessageTimeStyle,
          ),
      ],
    );
  }

  Widget _buildUnreadCountInternal(int unreadMemberCount) {
    if(messageBloc is ChatMessageBloc && !(messageBloc  as ChatMessageBloc).model.isBlocked != false) {
      if(unreadMemberCount == 0) {
        return Image.asset(Assets.img.ico_26_ch_gy, width: Zeplin.size(26),);
      }
    }
    return Container();
  }
}
