import 'package:flutter/material.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/room_manager.dart';

class ContactManager {
  static ContactManager? _instance;

  ContactManager._internal();

  factory ContactManager() => _instance ??= ContactManager._internal();

  SelectedContactBloc selectedContactBloc = SelectedContactBloc();

  ValueNotifier<Map<String, bool>> onlinePlayerStatusMap =  ValueNotifier({});

  Map<String, dynamic> globalPlayerMap = {};

  void init() {
    globalPlayerMap = {
      "testid001" : {
        "playerId":"testid001",
        "status":"active",
        "nickname": "영희",
        "searchName":"영희",
        "profileImgUrl":"https://yt3.googleusercontent.com/03Frk7HaJlMPWX07c9mLcqnZVeDYvl1hHed8L_n4H1h7Z29OETw4JBmv0eaWPEfG0TKC2_S2=s900-c-k-c0x00ffffff-no-rj",
        "statusMessage":"",
        "online":true,
        // "customNickname":false,
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid002" : {
        "playerId":"testid002",
        "status":"active",
        "nickname": "철수",
        "searchName":"철수",
        "online":true,
        "profileImgUrl":"https://i2.ruliweb.com/img/18/03/22/1624d6799fc49c14e.jpg",
        "statusMessage":"오늘 날씨 맑음 :)",
        // "online":false,
        // "customNickname":false,
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid003" : {
        "playerId":"testid003",
        "status":"active",
        "nickname":"다연",
        "profileImgUrl":"https://img.daily.co.kr/@files/www.daily.co.kr/content_watermark/life/2016/20160913/b90b4a9fdce4a7682a98afa7f6e45cf1.jpg",
        "searchName":"다연",
        "statusMessage":"우왕앙",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid004" : {
        "playerId":"testid004",
        "status":"active",
        "nickname":"영철",
        "profileImgUrl":"http://dknews.dankook.ac.kr/news/photo/201709/15022_2182_1913.png",
        "searchName":"영철",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid005" : {
        "playerId":"testid005",
        "status":"active",
        "nickname":"민지",
        "profileImgUrl":"https://cdn.pixabay.com/photo/2023/05/05/21/00/cute-7973191_1280.jpg",
        "searchName":"민지",
        "statusMessage":"뿌우",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid006" : {
        "playerId":"testid006",
        "status":"active",
        "nickname":"민철",
        "profileImgUrl":"https://dimg.donga.com/wps/NEWS/IMAGE/2019/04/25/95215551.1.jpg",
        "searchName":"민철",
        "statusMessage":"배고파ㅏㅏㅏㅏㅏㅏㅏㅏ",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid007" : {
        "playerId":"testid007",
        "status":"active",
        "nickname":"덕순",
        "profileImgUrl":"https://blog.yena.io/assets/post-img/171123-nachoi-300.jpg",
        "searchName":"덕순",
        "statusMessage":"얏호 내가 왕이다",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid008" : {
        "playerId":"testid008",
        "status":"active",
        "nickname":"상우",
        "profileImgUrl":"https://cdn.pixabay.com/photo/2020/05/11/05/15/chrome-5156508_1280.png",
        "searchName":"상우",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid009" : {
        "playerId":"testid009",
        "status":"active",
        "nickname":"성철",
        "profileImgUrl":"http://ticketimage.interpark.com/Movie/news_image/1406/0602_hb_s1.jpg",
        "searchName":"성철",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid010" : {
        "playerId":"testid010",
        "status":"active",
        "nickname":"민성",
        "profileImgUrl":"https://img.hani.co.kr/imgdb/resize/2011/0716/00398531701_20110716.JPG",
        "searchName":"민성",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
      "testid011" : {
        "playerId":"testid011",
        "status":"active",
        "nickname":"가영",
        "profileImgUrl":"https://img.daily.co.kr/@files/www.daily.co.kr/content_watermark/life/2016/20160913/065e10b25c26daa4a5c66d24f18f20d0.jpg",
        "searchName":"가영",
        "friendTime":1666172171619,
        "blockchainNetType":"klaytn",
        "relationshipStatus":"normal",
        "relationRegTime":1664330384442,
        "relationModTime":1666172171620,
        "playerRegTime":1653488809737,
        "playerModTime":1653488809737,
        "regTime":1682327649046,
        "modTime":1682411112674,
      },
    };
  }

  static void destroy() {
    _instance = null;
  }

  Future<ContactModel?> addContact(String playerId, String targetPlayerId) async {
    AddContactCommand command = AddContactCommand(playerId, targetPlayerId);
    if (await DataService().request(command)) {
      LogWidget.debug("AddContactCommand success");
      ContactManager().globalPlayerMap[targetPlayerId]["friendTime"] = DateTime.now().millisecondsSinceEpoch;
      return ContactModel.fromMap(ContactManager().globalPlayerMap[targetPlayerId]);

    } else {
      LogWidget.debug("AddContactCommand failed");
      return null;
    }

  }

  Future<bool> removeContact(String playerId, String targetPlayerId) async {
    RemoveContactCommand command = RemoveContactCommand(playerId, targetPlayerId);

    if (await DataService().request(command)) {
      ContactManager().globalPlayerMap[targetPlayerId]["friendTime"] = -1;

      LogWidget.debug("RemoveContactCommand success");
      return true;

    } else {
      LogWidget.debug("RemoveContactCommand failed");
      return false;
    }
  }

  Future<Map<String, bool>> loadOnlineStatusContacts(List<String> targetPlayerIds) async {

    // 온라인 여부
    GetPlayerOnlineStatusCommand command = GetPlayerOnlineStatusCommand(MeModel().playerId, targetPlayerIds);
    if (await DataService().request(command)) {
      LogWidget.debug("GetPlayerOnlineStatusCommand success");
      
      return command.onlineStatus;

    } else {
      LogWidget.debug("GetPlayerOnlineStatusCommand failed");
      
      return command.onlineStatus;
    }
  }

  Future<Map<String, dynamic>?> loadContactsFromServer(int limit, { String? cursor, String? keyword, bool withCount = false }) async {
    LogWidget.debug("load one way friend from server!");

    try {
      LoadContactsCommand command = LoadContactsCommand(MeModel().playerId!, limit, cursor: cursor, keyword: keyword, withCount: withCount);
      if (await DataService().request(command)) {
        LogWidget.debug("LoadContactsCommand success");

        Map<String, dynamic> result = {};

        List<String> targetPlayerIds = [];

        Map<String, ContactModel> contactMap = {};
        command.contacts!.map((e) => ContactModel.fromMap(e)).forEach((element) {
          contactMap.putIfAbsent(element.playerId, () => element);
          targetPlayerIds.add(element.playerId);
        });

        onlinePlayerStatusMap.value.addAll(await loadOnlineStatusContacts(targetPlayerIds));

        result.putIfAbsent("contactMap", () => contactMap);
        result.putIfAbsent("cursor", () => command.cursor);
        if(withCount)
          result.putIfAbsent("totalCount", () => command.totalCount);

        return result;
      } else {
        LogWidget.debug("LoadContactsCommand fail");
        return null;
      }
    } catch(e) {
      LogWidget.debug("error $e");
      return null;
    }
    return null;
  }
  
  Future<bool> blockContact(String playerId, String targetPlayerId) async {
    BlockPlayerCommand command = BlockPlayerCommand(playerId, targetPlayerId);
    if (await DataService().request(command)) {
      LogWidget.debug("BlockPlayerCommand success");
      RoomManager().getUnreadRoom();
      return true;
    } else {
      LogWidget.debug("BlockPlayerCommand fail");
      
      return false;  
    }
  }

  Future<bool> unblockContact(String playerId, String targetPlayerId) async {
    UnblockContactCommand command = UnblockContactCommand(playerId, targetPlayerId);
    if (await DataService().request(command)) {
      LogWidget.debug("UnblockContactCommand success");

      return true;
    } else {
      LogWidget.debug("UnblockContactCommand fail");

      return false;
    }
  }

  Future<Map<String, dynamic>?> loadBlockContactsFromServer(int limit, { String? cursor, String? keyword, bool withCount = false }) async {
    LogWidget.debug("load block player list from server!");

    try {
      LoadBlockedContactsCommand? command = LoadBlockedContactsCommand(MeModel().playerId!, limit, cursor: cursor, keyword: keyword, withCount: withCount);
      if (await DataService().request(command)) {
        LogWidget.debug("LoadBlockedPlayerListCommand success");

        Map<String, dynamic> result = {};

        Map<String, ContactModel> blockedContactMap = {};
        command.contacts!.map((e) => ContactModel.fromMap(e)).forEach((element) {
          blockedContactMap.putIfAbsent(element.playerId, () => element);
        });

        result.putIfAbsent("contactMap", () => blockedContactMap);
        result.putIfAbsent("cursor", () => command.cursor);
        if(withCount)
          result.putIfAbsent("totalCount", () => command.totalCount);

        return result;
      } else {
        LogWidget.debug("LoadBlockedPlayerListCommand fail");
        return null;
      }
    } catch(e) {
      LogWidget.debug("error $e");
      return null;
    }
    return null;
  }

  void updateContact(String targetPlayerId, String? nickname, { String? profileImgUrl }) {
    BlocManager.getBloc<ContactsBloc>()?.add(UpdateContactEvent(playerId: targetPlayerId, nickname: nickname, profileImgUrl: profileImgUrl));
    BlocManager.getBloc<BlockedContactsBloc>()?.add(UpdateBlockedContactEvent(playerId: targetPlayerId, nickname:  nickname, profileImgUrl: profileImgUrl));
  }

  void goProfilePage(String playerId) {
    HomeWidget? oldTwoDepthPopUp = HomeNavigator.getPeekTwoDepthPopUp();

    if(oldTwoDepthPopUp == null || !PageType.isPlayerProfilePage(oldTwoDepthPopUp)) {
      HomeNavigator.push(RoutePaths.profile.player, arguments: playerId, addedPadding: EdgeInsets.symmetric(vertical: Zeplin.size(84)));
    } else if (PageType.isPlayerProfilePage(oldTwoDepthPopUp)) {
      HomeNavigator.clearTwoDepthPopUp();
    }
  }

}