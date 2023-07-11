
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quiver/collection.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

class TabIconManager {
  final LruMap<int, Image> cacheImage;

  TabIconManager({
    int capacity = 20,
  }) : cacheImage = LruMap(maximumSize: capacity) {

    for(TabCode tabCode in TabCode.values) {
      callOnOff(false, tabCode);
    }

    for(TabCode tabCode in TabCode.values) {
      callOnOff(true, tabCode);
    }
  }

  void init() {
  }

  Widget callOnOff(bool on, TabCode tabCode) {
    switch(tabCode) {
      case TabCode.chat:
      case TabCode.square:
      case TabCode.contacts:
      case TabCode.more:
        break;
      default:
        return Container();
    }

    int selected = (on == true)? 1:0;
    int tabIconIndex = (tabCode.index*100+selected);

    return cacheImage[tabIconIndex] ??= buildImage(on, tabCode.index);
  }

  Widget call(int selectedIndex, TabCode tabCode) {
    return callOnOff(selectedIndex == tabCode.index, tabCode);
  }

  void expire(int tabCodeIndex) => cacheImage.remove(tabCodeIndex);
  void expireAll() => cacheImage.clear();

  int get length => cacheImage.length;

  Future<Uint8List> loadMemory(bool on, int index) async {
    if(on == false) {
      if(index == TabCode.chat.index) {
        return (await rootBundle.load(Assets.img.ico_46_talk_gy)).buffer.asUint8List();
      } else if(index == TabCode.square.index) {
        return (await rootBundle.load(Assets.img.ico_46_square_gy)).buffer.asUint8List();
      } else if(index == TabCode.contacts.index) {
        return (await rootBundle.load(Assets.img.ico_46_friend_outline)).buffer.asUint8List();
      } else {
        return (await rootBundle.load(Assets.img.ico_46_my_info_gr)).buffer.asUint8List();
      }
    } else {
      if(index == TabCode.chat.index) {
        return (await rootBundle.load(Assets.img.ico_46_talk_on)).buffer.asUint8List();
      } else if(index == TabCode.square.index) {
        return (await rootBundle.load(Assets.img.ico_46_square_yw)).buffer.asUint8List();
      } else if(index == TabCode.contacts.index) {
        return (await rootBundle.load(Assets.img.ico_46_friend_outline_t)).buffer.asUint8List();
      } else {
        return (await rootBundle.load(Assets.img.ico_46_my_info_t)).buffer.asUint8List();
      }
    }
  }

  Image buildImage(bool on, int index) {
    if(on == false) {
      if(index == TabCode.chat.index) {
        return Image.asset(Assets.img.ico_46_talk_gy, width: Zeplin.size(46), gaplessPlayback: true);
      } else if(index == TabCode.square.index) {
        return Image.asset(Assets.img.ico_46_square_gy, width: Zeplin.size(46), gaplessPlayback: true);
      } else if(index == TabCode.contacts.index) {
        return Image.asset(Assets.img.ico_46_friend_outline, width: Zeplin.size(46), gaplessPlayback: true);
      } else {
        return Image.asset(Assets.img.ico_46_my_info_gr, width: Zeplin.size(46), gaplessPlayback: true);
      }
    } else {
      if(index == TabCode.chat.index) {
        return Image.asset(Assets.img.ico_46_talk_on, width: Zeplin.size(46), gaplessPlayback: true);
      } else if(index == TabCode.square.index) {
        return Image.asset(Assets.img.ico_46_square_yw, width: Zeplin.size(46), gaplessPlayback: true);
      } else if(index == TabCode.contacts.index) {
        return Image.asset(Assets.img.ico_46_friend_outline_t, width: Zeplin.size(46), gaplessPlayback: true);
      } else {
        return Image.asset(Assets.img.ico_46_my_info_t, width: Zeplin.size(46), gaplessPlayback: true);
      }
    }
  }

  void precache(BuildContext context) {
    LogWidget.debug("TabIconManager precache");
    for(Image image in cacheImage.values) {
      precacheImage(image.image, context);
    }
  }
}
