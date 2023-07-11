import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:square_web/model/message/message_model.dart';

abstract class MessageBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchMessage extends MessageBlocEvent {
  bool backward;
  bool? reload;

  FetchMessage(this.backward, {this.reload = false});
}

class PauseMessage extends MessageBlocEvent {
  bool pause;
  PauseMessage(this.pause);
}

class ReceivedMessage extends MessageBlocEvent {
  final List<MessageModel>? messages;

  ReceivedMessage({this.messages});
}

class AiMessageReceivedMessage extends MessageBlocEvent {
  final MessageModel message;

  AiMessageReceivedMessage(this.message);
}

class SendTextMessage extends MessageBlocEvent {
  final String text;

  SendTextMessage(this.text);
}

class RetrySendMessage extends MessageBlocEvent {
  final MessageModel? messageModel;
  final VoidCallback func;
  RetrySendMessage(this.messageModel, this.func);
}

class SendFailedMessage extends MessageBlocEvent {
  final MessageModel messageModel;
  SendFailedMessage(this.messageModel);
}

class SendEmoticonMessage extends MessageBlocEvent {
  final String withText;
  final String emoticonId;

  SendEmoticonMessage(this.emoticonId, this.withText);
}

class SendImageMessage extends MessageBlocEvent {
  final Uint8List? bytes;
  final String? mimeType;
  final List<XFile>? images;

  SendImageMessage({this.images, this.bytes, this.mimeType = "image/png" });
}

class ShareMessage extends MessageBlocEvent {
  final MessageModel messageModel;

  ShareMessage(this.messageModel);
}

class RemoveMessage extends MessageBlocEvent {
  final MessageModel messageModel;

  RemoveMessage({required this.messageModel});
}

class RemoveForMeMessage extends MessageBlocEvent {
  final MessageModel messageModel;

  RemoveForMeMessage({required this.messageModel});
}

class InitializeMessage extends MessageBlocEvent {
  final List<MessageModel>? initialMessages;
  InitializeMessage({this.initialMessages});
}

class ReloadMessage extends MessageBlocEvent {}

class TypingMessage extends MessageBlocEvent {
  final String? targetPlayerId;
  final bool isTyping;

  TypingMessage({ this.targetPlayerId, this.isTyping = false });
}