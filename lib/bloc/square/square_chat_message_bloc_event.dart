import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:square_web/model/message/message_model.dart';

abstract class SquareChatMessageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchMessage extends SquareChatMessageEvent {
  bool isForward;

  FetchMessage(this.isForward);
}

class ReceivedMessage extends SquareChatMessageEvent {
  final List<SquareChatMsgModel>? messages;

  ReceivedMessage({this.messages});
}

class SendTextMessage extends SquareChatMessageEvent {
  final String text;

  SendTextMessage(this.text);
}

class RetrySendMessage extends SquareChatMessageEvent {
  final SquareChatMsgModel? messageModel;
  RetrySendMessage(this.messageModel);
}

class SendFailedMessage extends SquareChatMessageEvent {
  final SquareChatMsgModel messageModel;
  SendFailedMessage(this.messageModel);
}

class SendEmoticonMessage extends SquareChatMessageEvent {
  final String withText;
  final String emoticonId;

  SendEmoticonMessage(this.emoticonId, this.withText);
}

class SendImageMessage extends SquareChatMessageEvent {
  final Uint8List bytes;
  final String? mimeType;

  SendImageMessage(this.bytes, { this.mimeType = "image/png" });
}

class ShareMessage extends SquareChatMessageEvent {
  final SquareChatMsgModel messageModel;

  ShareMessage(this.messageModel);
}

class RemoveMessage extends SquareChatMessageEvent {
  final SquareChatMsgModel messageModel;

  RemoveMessage({required this.messageModel});
}

class RemoveForMeMessage extends SquareChatMessageEvent {
  final SquareChatMsgModel messageModel;

  RemoveForMeMessage({required this.messageModel});
}

class InitializeMessage extends SquareChatMessageEvent {
  final List<SquareChatMsgModel>? initialMessages;
  InitializeMessage({this.initialMessages});
}

class ReloadMessage extends SquareChatMessageEvent {}