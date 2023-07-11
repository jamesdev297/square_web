import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/bloc/message_bloc.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/message/chat_message.dart';

class TypingChatMessage extends StatefulWidget {
  final MessageModel messageModel;
  final TickerProvider? vsyncTickerProvider;
  final String? printedMessageTime;
  final bool? printContact;
  final Color? chatMessageBackgroundColor;
  final MessageBloc messageBloc;
  final HomeWidget rootWidget;

  TypingChatMessage({Key? key, required this.messageModel, this.vsyncTickerProvider, this.printedMessageTime, this.printContact, this.chatMessageBackgroundColor, required this.messageBloc, required this.rootWidget}) : super(key: key);

  @override
  _TypingChatMessageState createState() => _TypingChatMessageState();
}

class _TypingChatMessageState extends State<TypingChatMessage> {

  String typingCursor = '•••';
  Timer? _showTypingCursorTimer;
  bool showTypingCursor = false;
  int typingCursorDelay = 500;
  String? selectedText;
  bool isDisposed = false;

  Timer? squareTypingTimer;
  late String _currentText;
  int waitCount = 0;
  int maxWaitCount = 12;
  int typingTextDelay = 50;


  @override
  void initState() {
    super.initState();

    _currentText = widget.messageModel.messageBody ?? "";

    if(widget.messageModel.status == MessageStatus.aiSaying) {

      _showTypingCursorTimer = Timer.periodic(Duration(milliseconds: typingCursorDelay), (timer) {
        if(widget.messageModel.status == MessageStatus.aiSaying)
          showTypingCursor = !showTypingCursor;

        if(widget.messageModel.messageBody!.isEmpty == false) {
          showTypingCursor = false;
          timer.cancel();

          if (RoomManager().currentChatRoom == null && widget.messageModel.status == MessageStatus.aiSaying) {
            textTypingTimer();
          }

          return;
        }

        if(this.mounted && !isDisposed)
          setState(() {});
      });
    }
  }

  void addCurrentText() {
    for(int i = 3; i > 0; i--) {
      if(widget.messageModel.messageBody!.length > _currentText.length) {
        _currentText += widget.messageModel.messageBody![_currentText.length];
      } else {
        break;
      }
    }

    if(this.mounted && !isDisposed)
      setState(() {});
  }

  void textTypingTimer() {
    if(squareTypingTimer?.isActive == true)
      squareTypingTimer?.cancel();

    squareTypingTimer = Timer.periodic(Duration(milliseconds: typingTextDelay), (timer) {
      int expireTime = widget.messageModel.sendTime! + Duration(minutes: 3).inMilliseconds;
      int nowTime = DateTime.now().millisecondsSinceEpoch;

      if (widget.messageModel.status == MessageStatus.normal || nowTime > expireTime) {
        if(timer.isActive == true) {
          _currentText = widget.messageModel.messageBody ?? "";
          timer.cancel();
          if (this.mounted && !isDisposed)
            setState(() {});
        }
      } else if(_currentText != widget.messageModel.messageBody){
        addCurrentText();
      }
    });
  }

  @override
  void dispose() {
    _showTypingCursorTimer?.cancel();
    _showTypingCursorTimer = null;
    squareTypingTimer?.cancel();
    squareTypingTimer = null;
    isDisposed = true;
    ChatMessageManager().disposeGlobalKey(widget.messageModel.messageId);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if(RoomManager().currentChatRoom != null)
      _currentText = widget.messageModel.messageBody!;

    return ChatMessage.newMessage(widget.messageModel,
      vsyncTickerProvider: widget.vsyncTickerProvider,
      printedMessageTime: widget.printedMessageTime,
      printContact: widget.printContact,
      messageBloc: widget.messageBloc,
      rootWidget: widget.rootWidget,
      typingText: showTypingCursor && widget.messageModel.messageBody!.isEmpty ? typingCursor : _currentText
    );
  }
}
