import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/message/message_model.dart';

part 'localstge_room_dao.dart';
part 'localstge_me_dao.dart';

//local storage (prefs) for web
class StorageDao {
  static final StorageDao _instance = StorageDao._internal();
  factory StorageDao() => _instance;
  StorageDao._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    LogWidget.debug("local storage initialized.");
  }

  Future<void> clearStorage() async {
    _prefs.clear();
  }

  void close() async {
    return;
  }

  bool isOpen() {
    return true;
  }
}

class _PrefsKey {}
