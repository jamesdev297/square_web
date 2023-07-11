import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:square_web/model/message/message_model.dart';

@immutable
abstract class MessageBlocState extends Equatable {
  const MessageBlocState();

  @override
  List<Object?> get props => [];
}


class MessageUninitialized extends MessageBlocState {}

class MessageError extends MessageBlocState {}

class AiLimitReachedInfo {
  String aiModel;
  int dailyLimit;
  AiLimitReachedInfo(this.aiModel, this.dailyLimit);
}
class MessageLoaded extends MessageBlocState {
  final SplayTreeSet<MessageModel>? messages;
  final SplayTreeSet<MessageModel>? sendingMessages;
  bool? hasTopReachedMax;
  bool? hasBottomReachedMax;
  AiLimitReachedInfo? aiLimitReached;
  final int? nextCursor;
  final int reloadId;

  final bool isOnError;

  MessageLoaded({
    this.messages,
    this.hasTopReachedMax,
    this.hasBottomReachedMax,
    this.sendingMessages,
    this.nextCursor,
    this.aiLimitReached,
    this.reloadId = 0,
    this.isOnError = false
  });

  static MessageLoaded empty({bool hasTopReachedMax = false, bool hasBottomReachedMax = false}) {
    return MessageLoaded(
        messages: MessageModel.initialSortedSet,
        sendingMessages: MessageModel.initialSortedSet,
        hasTopReachedMax: hasTopReachedMax,
        hasBottomReachedMax: hasBottomReachedMax
    );
  }

  MessageLoaded copyWith({
    final SplayTreeSet<MessageModel>? messages,
    final bool? hasTopReachedMax,
    final bool? hasBottomReachedMax,
    final bool reload = true,
    final SplayTreeSet<MessageModel>? sendingMessages,
    final bool isOnError = false,
    final AiLimitReachedInfo? aiLimitReached
  }) {
    var loaded = MessageLoaded(
      sendingMessages: sendingMessages ?? this.sendingMessages,
      messages: messages ?? this.messages,
      hasTopReachedMax: hasTopReachedMax ?? this.hasTopReachedMax,
      hasBottomReachedMax: hasBottomReachedMax ?? this.hasBottomReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
      isOnError: isOnError,
      aiLimitReached: aiLimitReached
    );
    return loaded;
  }

  @override
  List<Object?> get props => [messages, hasTopReachedMax, hasBottomReachedMax, reloadId, sendingMessages];

  @override
  String toString() =>
      'MessageLoaded { messages: ${messages!.length}, sendingMessages: ${sendingMessages!.length} hasTopReachedMax: $hasTopReachedMax, hasBottomReachedMax: $hasBottomReachedMax}';
}
