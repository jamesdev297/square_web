import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/widget/locale_date.dart';
import 'package:square_web/widget/pebble_widget.dart';

import 'chat_message.dart';

class SystemMessage extends ChatMessage {
  final MessageModel messageModel;
  final AnimationController? popUpAnimController;
  final AnimationController Function()? newAnimationController;
  late AnimationController fadeOutController;
  final bool? isUnderPrintedMessageTime;
  final MessageBloc messageBloc;

  SystemMessage({required this.messageModel, required this.messageBloc, this.newAnimationController, this.popUpAnimController, this.isUnderPrintedMessageTime = false})
      : super(messageModel: messageModel, messageBloc: messageBloc);

  @override
  Widget build(BuildContext context) {
    if (popUpAnimController == null) {
      return _baseWidget(context);
    } else {
      return SizeTransition(
          sizeFactor: CurvedAnimation(parent: popUpAnimController!, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: _baseWidget(context));
    }
  }

  Widget _baseWidget(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: Zeplin.size(19)),
      child: buildSystemMessageWithParse(messageModel, context),
    );
  }

  Widget buildSystemMessage(MessageModel messageModel, BuildContext context) {


    switch (messageModel.contentId) {
      case ConstMsgContentId.seen:
        return _buildTextSystemMessage(messageModel.messageBody!);
      case ConstMsgContentId.notKnown:
        return _buildTextSystemMessage(messageModel.messageBody!);
      case ConstMsgContentId.date:
        return _buildTextSystemMessage("${LocaleDate().getDate(int.parse(messageModel.messageBody!))}");
      case ConstMsgContentId.notSignedUp:
        return _buildTextSystemMessage(messageModel.messageBody!);
      // case ConstMsgContentId.resetAiHistory:
      //   return _buildResetAiHistorySystemMessage(messageModel.messageBody!);
      // case ConstMsgContentId.changeAi:
      //   return _buildChangeAiSystemMessage(messageModel.playerId!, messageModel.messageBody!);
      default:
        throw Exception("Oops, an error occurred");
    }
  }

  Widget buildSystemMessageWithParse(MessageModel messageModel, context) {
    try {
      return buildSystemMessage(messageModel, context);
    } catch (e) {
      LogWidget.warning("json parsing error at MessageType.system $e");
      return ClipPebbleRect(
          drawBorder: false,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(L10n.common_59_service_error, style: deletedChatTextStyle),
          ]));
    }
  }


  Widget _buildTextSystemMessage(String text) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: Zeplin.size(10, isPcSize: true),
              right: Zeplin.size(11, isPcSize: true),
              top: Zeplin.size(5, isPcSize: true),
              bottom: Zeplin.size(4, isPcSize: true)),
          decoration: BoxDecoration(
              color: CustomColor.grey3,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: systemMessageGreyDefaultStyle,
          ),
        ),
        // Spacer(),
      ],
    );
  }
}
