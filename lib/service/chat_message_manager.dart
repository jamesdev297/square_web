

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/collection.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/command/command_room.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/widget/message/chat_message.dart';



class ChatSkillModel {
  SkillType skillType;
  Offset startOffset;
  bool isMyChatMessage;
  String messageId;

  ChatSkillModel({required this.messageId, required this.skillType, required this.startOffset, required this.isMyChatMessage});
}

/*class ChatMessageGlobalKeyCache {
  final
}*/

class ChatMessageAnimationCache {
  final LruMap<String, AnimationController?> cache;
  final AnimationController? Function(String, TickerProvider, Duration) _getter = (messageId, ticker, duration) {
    AnimationController controller = AnimationController(vsync: ticker, duration: duration);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    controller.forward();
    return controller;
  };

  ChatMessageAnimationCache({
    int capacity = 20,
  }) : cache = LruMap(maximumSize: capacity);

  AnimationController? call(String messageId, TickerProvider tickerProvider, Duration duration) => cache[messageId] ??= _getter(messageId, tickerProvider, duration);
  AnimationController? get(String messageId) => cache[messageId];
  void change(String oldMessageId, String newMessageId) {
    AnimationController? old = cache[oldMessageId];
    if(old != null) {
      cache[newMessageId] = old;
      expire(oldMessageId);
    }
  }

  void expire(String messageId) => cache.remove(messageId);
  void expireAll() => cache.clear();

  int get length => cache.length;
}

class ChatMessageManager {
  static ChatMessageManager? _instance;
  ChatMessageManager._internal();
  factory ChatMessageManager() => _instance ??= ChatMessageManager._internal();
  final ChatMessageAnimationCache popUpAnimCache = ChatMessageAnimationCache();
  final ChatMessageAnimationCache vibrateAnimCache = ChatMessageAnimationCache();
  final ChatMessageAnimationCache colorAnimCache = ChatMessageAnimationCache();

  final StreamController<ChatSkillModel> chatSkillStreamController = StreamController.broadcast();
  final Set<String> chatSkillSet = {};

  final Map<String, Timer> linkMessageTimerMap = {};
  final Map<String, int> linkMessageTimerCntMap = {};
  final Map<String, StreamController<Map<String, String?>>> linkMessageMap = {};
  final Map<String, MessageModel> newLinkMessageMap = {};

  final Map<String, GlobalKey> globalKeyMap = {};
  // final Map<String, >

  TickerProvider? tickerProvider;

  GlobalKey getGlobalKey(String messageId) {
    GlobalKey? key = globalKeyMap[messageId];
    if(key == null) {
      globalKeyMap[messageId] = GlobalKey();
      key = globalKeyMap[messageId];
    }
    return key!;
  }

  void disposeGlobalKey(String messageId) {
    globalKeyMap.remove(messageId);
  }

  static void destroy() {
    _instance = null;
  }

  void registerTickerProvider(TickerProvider tickerProvider) {
    this.tickerProvider = tickerProvider;
  }

  void changeLinkMessage(String oldMessageKey, String newMessageKey, {MessageModel? newMessageModel}) {
    if(oldMessageKey != newMessageKey) {
      StreamController<Map<String, String?>>? old = linkMessageMap[oldMessageKey];
      if(old != null) {
        linkMessageMap[newMessageKey] = old;
        linkMessageMap.remove(oldMessageKey);
      }

      Timer? oldTimer = linkMessageTimerMap[oldMessageKey];
      if(oldTimer != null) {
        linkMessageTimerMap[newMessageKey] = oldTimer;
        linkMessageTimerMap.remove(oldMessageKey);
      }

      int? oldTimerCnt = linkMessageTimerCntMap[oldMessageKey];
      if(oldTimerCnt != null) {
        linkMessageTimerCntMap[newMessageKey] = oldTimerCnt;
        linkMessageTimerCntMap.remove(oldMessageKey);
      }
    }

    if(newMessageModel != null) {
      changeLinkMessageModel(oldMessageKey, newMessageModel);
    }
  }

  void removeLinkMessageMap(String key) {
    linkMessageTimerMap[key]?.cancel();
    linkMessageTimerCntMap.remove(key);
    linkMessageMap[key]?.close();
    linkMessageMap.remove(key);
    linkMessageTimerMap.remove(key);
  }

  StreamController<Map<String, String?>> getLinkMessageMap(MessageModel messageModel) {
    StreamController<Map<String, String?>>? streamController = linkMessageMap[messageModel.messageManagerKey];
    if(streamController != null) {
      return streamController;
    }
    updateLinkMessage(messageModel);
    return linkMessageMap[messageModel.messageManagerKey]!;
  }

  void updateLinkMessage(MessageModel messageModel) {
    bool isSquareMsgModel = messageModel is SquareChatMsgModel;
    final int timerDelay = isSquareMsgModel ? 800 : 500;
    if(messageModel.messageManagerKey == null) return ;

    linkMessageMap.putIfAbsent(messageModel.messageManagerKey!, () => StreamController.broadcast());
    linkMessageTimerCntMap.putIfAbsent(messageModel.messageManagerKey!, () => 0);
    linkMessageTimerMap.putIfAbsent(messageModel.messageManagerKey!, () => Timer.periodic(Duration(milliseconds: timerDelay), (Timer timer) async {
      MessageModel? newMessage = newLinkMessageMap[messageModel.messageManagerKey];
      String key = newMessage?.messageManagerKey ?? messageModel.messageManagerKey!;

      if(linkMessageTimerCntMap[key] == null
        || linkMessageTimerCntMap[key]! > 6) {
        removeLinkMessageMap(key);
        timer.cancel();
        linkMessageMap[key]?.add({});
        return ;
      }
      linkMessageTimerCntMap[key] = linkMessageTimerCntMap[key]! + 1;
      if(isSquareMsgModel) {
        int receivedTime = (newMessage as SquareChatMsgModel?)?.receivedTime ?? messageModel.receivedTime!;
        if(DateTime.now().millisecondsSinceEpoch - receivedTime > 10 * 1000) {
          timer.cancel();
          return ;
        }
        GetSquareMessageCommand command = GetSquareMessageCommand(messageModel.squareId!, messageModel.channelId!, messageModel.sender!.playerId, receivedTime);
        if(await DataService().request(command)) {
          if(command.message != null) {
            getLinkMessageSuccessFunc(command.message!, key, newMessage, timer);
          }
        }
      } else {
        if(DateTime.now().millisecondsSinceEpoch - messageModel.sendTime! > 10 * 1000) {
          timer.cancel();
          return ;
        }
        GetMessageCommand command = GetMessageCommand(messageModel.roomId!, messageModel.sender!.playerId, messageModel.sendTime!);
        if(await DataService().request(command)) {
          if(command.message != null) {
            getLinkMessageSuccessFunc(command.message!, key, newMessage, timer);
          }
        }
      }
    }));
  }

  void getLinkMessageSuccessFunc(MessageModel messageModel, String messageManagerKey, MessageModel? newMessage, Timer timer) {
    if(messageModel.thumbnailUrl != null) {
      if(newMessage != null) {
        newMessage.thumbnailUrl = messageModel.thumbnailUrl;
        newMessage.fullContentUrl = messageModel.fullContentUrl;
      }
      linkMessageMap[messageManagerKey]?.add({
        "thumbnailUrl" : messageModel.thumbnailUrl,
        "fullContentUrl" : messageModel.fullContentUrl,
      });
      removeLinkMessageMap(messageManagerKey);
      timer.cancel();
    }
  }

  void changeLinkMessageModel(String key, MessageModel messageModel) {
    newLinkMessageMap[key] = messageModel;
    // List<String>? oldMessageIds = oldMessageIdListMap[messageId];
    // if(oldMessageIds != null) {
    //   oldMessageIdListMap.putIfAbsent(messageId, () => [messageId] + oldMessageIds);
    // } else {
    //   oldMessageIdListMap.putIfAbsent(messageId, () => [messageId]);
    // }
  }

  void changeMessage(String oldMessageManagerkey, String newMessageManagerKey) {
    if(oldMessageManagerkey != newMessageManagerKey) {
      popUpAnimCache.change(oldMessageManagerkey, newMessageManagerKey);
      vibrateAnimCache.change(oldMessageManagerkey, newMessageManagerKey);
      colorAnimCache.change(oldMessageManagerkey, newMessageManagerKey);
      if(chatSkillSet.contains(oldMessageManagerkey)) {
        chatSkillSet.remove(oldMessageManagerkey);
        chatSkillSet.add(newMessageManagerKey);
      }
    }
  }

  void clearCache() {
    linkMessageTimerMap.values.forEach((element) => element.cancel());
    linkMessageTimerMap.clear();
    linkMessageTimerCntMap.clear();
    linkMessageMap.values.forEach((element) => element.close());
    linkMessageMap.clear();
    newLinkMessageMap.clear();
    popUpAnimCache.expireAll();
    vibrateAnimCache.expireAll();
    colorAnimCache.expireAll();
    chatSkillSet.clear();
  }

  void add(Map<MessageAnimType, AnimationController?> result, MessageAnimType messageAnimType, AnimationController? animationController) {
    if(animationController != null) {
      result.putIfAbsent(messageAnimType, () => animationController);
    }
  }

  Map<MessageAnimType, AnimationController?> initMessageAnim(MessageModel messageModel, {bool action = false}) {
    if (messageModel.messageManagerKey == null)
      return {};
    String key = messageModel.messageManagerKey!;
    if(tickerProvider == null) return {};
    Map<MessageAnimType, AnimationController?> result = {};
    add(result, MessageAnimType.popUp, popUpAnimCache.call(key, tickerProvider!, Duration(milliseconds: 300)));
    if(messageModel.messageBody != null) {
      if(ChatSkill.rocketSkillPattern.any((element) => messageModel.messageBody!.toLowerCase().contains(element))) {
        add(result, MessageAnimType.vibrate, vibrateAnimCache.call(key, tickerProvider!, Duration(milliseconds: 400)));
        add(result, MessageAnimType.color, colorAnimCache.call(key, tickerProvider!, Duration(milliseconds: 500)));
      }
    }
    messageModel.hasAnimation = false;
    return result;
  }

  Map<MessageAnimType, AnimationController?> getMessageAnim(MessageModel messageModel) {
    if (messageModel.messageManagerKey == null)
      return {};
    String key = messageModel.messageManagerKey!;
    Map<MessageAnimType, AnimationController?> result = {};
    add(result, MessageAnimType.popUp, popUpAnimCache.get(key));
    add(result, MessageAnimType.vibrate, vibrateAnimCache.get(key));
    add(result, MessageAnimType.color, colorAnimCache.get(key));
    return result;
  }

  void registerChatSkill(MessageModel messageModel, Offset offset) {
    final key = messageModel.messageManagerKey;
    if(key == null) return ;
    if(!chatSkillSet.contains(key)) {
      chatSkillSet.add(key);
      chatSkillStreamController.add(ChatSkillModel(
          messageId: messageModel.messageId,
          skillType: SkillType.rocket,
          startOffset: offset,
          isMyChatMessage: messageModel.sender?.playerId == MeModel().playerId));
    }
  }

  static Future<ui.Image?> loadImage(List<int>? img) async {
    if(img == null)
      return null;
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img as Uint8List, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}


class ChatSkillImageModel {
  String? path;
  ui.Image? image;

  ChatSkillImageModel({this.path});

  double get imageSize => image!.width*1.0;

  Future<void> loadImage() async {
    if(image != null)
      return ;
    await rootBundle.load(path!).then((data) {
      ChatMessageManager.loadImage(Uint8List.view(data.buffer)).then((value) => image = value);
    });
    return ;
  }

  void disposeImage() {
    if(image == null)
      return ;

    LogWidget.debug("ChatSkillImageModel dispose $path");
    image!.dispose();
    image = null;
  }
}
