import 'dart:async';

import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:quiver/collection.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/emoticon/emoticon_model.dart';
import 'package:square_web/model/emoticon/emoticon_pack_model.dart';
import 'package:square_web/model/emoticon/network_sprite.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/data_service.dart';

class EmoticonCache {
  final LruMap<String, Future<Sprite?>> cache;
  final Future<Sprite?> Function(String) _getter = (emoticonId) =>
      NetworkSprite.load(EmoticonModel(emoticonId: emoticonId));

  EmoticonCache({
    int capacity = 10,
  }) : cache = LruMap(maximumSize: capacity);

  Future<Sprite?> call(String emoticonId) => cache[emoticonId] ??= _getter(emoticonId);

  void expire(String emoticonId) => cache.remove(emoticonId);
  void expireAll() => cache.clear();

  int get length => cache.length;
}

class EmoticonManager {
  static EmoticonManager? _instance;
  EmoticonManager._internal();
  factory EmoticonManager() => _instance ??= EmoticonManager._internal();

  final EmoticonCache emoticonCache = EmoticonCache();

  static void destroy() {
    _instance = null;
  }

  Completer<List<EmoticonPackModel>> loadEmoticonPackIdListCompleter = Completer();

  Future<void> loadEmoticonPackList() async {
    if(loadEmoticonPackIdListCompleter.isCompleted) return ;
    List<EmoticonPackModel> result = await _loadMyEmoticonPackList();
    loadEmoticonPackIdListCompleter.complete(result);
  }

  Future<List<EmoticonPackModel>> _loadMyEmoticonPackList() async {
    List<EmoticonPackModel> result = [];
    String? cursor;
    int limit = 50;
    GetMyEmoticonPackListCommand command;
    do {
      command = GetMyEmoticonPackListCommand(cursor: cursor, limit: limit);
      if(await DataService().request(command)) {
        result.addAll(command.emoticons);
      } else {
        break;
      }
    } while(command.cursor != null);
    return result;
  }

  Future<Sprite?> initMessageSprite(MessageModel messageModel) {
    if (messageModel.contentId == null)
      return Future.value(null);

    Future<Sprite?> futureSprite = emoticonCache.call(messageModel.contentId!);

    //LogWidget.debug("initMessageSprite : ${messageModel.contentId} : ${emoticonCache.length}");
    return futureSprite;
  }

  void disposeMessageSprite(MessageModel messageModel) {
    //LogWidget.debug("disposeMessageSprite : ${messageModel.contentId} : ${emoticonCache.length}");
  }

  void clearEmoticonSprite() {
    int prev = emoticonCache.length;
    emoticonCache.expireAll();
    LogWidget.debug("clearAllEmoticonSprite : $prev -> ${emoticonCache.length}");
  }

}
