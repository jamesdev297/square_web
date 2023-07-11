import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:square_web/model/message/message_model.dart';

@immutable
abstract class SquareChatMessageState extends Equatable {
  const SquareChatMessageState();

  @override
  List<Object?> get props => [];
}


class SquareMessageUninitialized extends SquareChatMessageState {}

class SquareMessageError extends SquareChatMessageState {}

class SquareMessageLoaded extends SquareChatMessageState {
  final SplayTreeSet<SquareChatMsgModel>? messages;
  final SplayTreeSet<SquareChatMsgModel>? sendingMessages;
  final bool? hasTopReachedMax;
  final bool? hasBottomReachedMax;
  final int reloadId;

  SquareMessageLoaded({
    this.messages,
    this.hasTopReachedMax,
    this.hasBottomReachedMax,
    this.sendingMessages,
    this.reloadId = 0
  });

  static SquareMessageLoaded empty({bool hasTopReachedMax = false, bool hasBottomReachedMax = false}) {
    return SquareMessageLoaded(
      messages: SquareChatMsgModel.initialSortedSet,
      sendingMessages: SquareChatMsgModel.initialSortedSet,
      hasTopReachedMax: hasTopReachedMax,
      hasBottomReachedMax: hasBottomReachedMax
    );
  }

  SquareMessageLoaded copyWith({
    final SplayTreeSet<SquareChatMsgModel>? messages,
    final bool? hasTopReachedMax,
    final bool? hasBottomReachedMax,
    final bool reload = true,
    final SplayTreeSet<SquareChatMsgModel>? sendingMessages,
  }) {
    var loaded = SquareMessageLoaded(
      sendingMessages: sendingMessages ?? this.sendingMessages,
      messages: messages ?? this.messages,
      hasTopReachedMax: hasTopReachedMax ?? this.hasTopReachedMax,
      hasBottomReachedMax: hasBottomReachedMax ?? this.hasBottomReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [messages, hasTopReachedMax, hasBottomReachedMax, reloadId, sendingMessages];

  @override
  String toString() =>
      'MessageLoaded { messages: ${messages!.length}, sendingMessages: ${sendingMessages!.length} hasTopReachedMax: $hasTopReachedMax, hasBottomReachedMax: $hasBottomReachedMax}';
}
