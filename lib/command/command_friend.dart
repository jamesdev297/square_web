import 'dart:async';

import 'package:square_web/constants/uris.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/player_model.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/squarepacket.dart';
import 'package:square_web/service/contact_manager.dart';

import 'command.dart';



class GetPlayerProfileCommand extends WsCommand {
  String? playerId;
  String? targetPlayerId;
  ContactModel? contactModel;
  GetPlayerProfileCommand({this.playerId, this.targetPlayerId});

  @override
  String getUri() => Uris.friend.getProfile;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "targetPlayerId": targetPlayerId
      })
    );

    contactModel = ContactModel.fromMap(ContactManager().globalPlayerMap[targetPlayerId]);
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    dynamic player = this.content["player"];
    if(player == null) {
      return false;
    }

    contactModel = ContactModel.fromMap(player);

    return true;
  }
}

/*
class GetSimpleProfileCommand extends WsCommand {
  final String targetPlayerId;
  Player? simpleProfile;
  GetSimpleProfileCommand(this.targetPlayerId);

  @override
  String getUri() => Uris.contacts.getSimpleProfile;

  @override
  Future<bool> execute() async {

    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId" : "${MeModel().playerId}",
        "targetPlayerId" : "$targetPlayerId",
      }));

    if(!await processRequest(packet)) {
      return false;
    }
    simpleProfile = Player.fromMap(content.map!);
    return true;
  }
}
*/


class LoadContactsCommand extends WsCommand {
  String playerId;
  bool withCount;
  String? cursor;
  String? keyword;
  int limit;
  int? totalCount;

  List<dynamic>? contacts;

  LoadContactsCommand(this.playerId, this.limit, { this.cursor, this.keyword, this.withCount = false });

  @override
  String getUri() => Uris.profile.getContactsList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        if(cursor != null)
          "cursor": cursor,
        if(keyword != null)
          "keyword": keyword,
        if(withCount == true)
          "withCount": true,
        "limit": limit
      })
    );

    contacts = ContactManager().globalPlayerMap.values.toList();
    totalCount = contacts!.length;
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    contacts = this.content["relationship"];
    totalCount = this.content["totalCount"];

    return true;
  }
}

class AddContactCommand extends WsCommand {
  String playerId;
  String targetPlayerId;
  AddContactCommand(this.playerId, this.targetPlayerId);

  @override
  String getUri() => Uris.profile.addContacts;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": playerId,
          "targetPlayerId": targetPlayerId,
        }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class RemoveContactCommand extends WsCommand {
  String playerId;
  String targetPlayerId;

  RemoveContactCommand(this.playerId, this.targetPlayerId);

  @override
  String getUri() => Uris.profile.removeContacts;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": playerId,
          "targetPlayerId": targetPlayerId,
        }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class BlockPlayerCommand extends WsCommand {
  String playerId;
  String targetPlayerId;

  BlockPlayerCommand(this.playerId, this.targetPlayerId);

  @override
  String getUri() => Uris.profile.blockContacts;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "targetPlayerId": targetPlayerId,
      })
    );
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class UnblockContactCommand extends WsCommand {
  String playerId;
  String targetPlayerId;

  UnblockContactCommand(this.playerId, this.targetPlayerId);

  @override
  String getUri() => Uris.profile.unblockBlockedContacts;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        "targetPlayerId": targetPlayerId,
      })
    );
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class LoadBlockedContactsCommand extends WsCommand {
  String playerId;
  bool withCount;
  String? cursor;
  String? keyword;
  int limit;
  int? totalCount;

  List<dynamic>? contacts;

  LoadBlockedContactsCommand(this.playerId, this.limit, { this.cursor, this.keyword, this.withCount = false });

  @override
  String getUri() => Uris.profile.getBlockedContactsList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": playerId,
        if(cursor != null)
          "cursor": cursor,
        if(keyword != null)
          "keyword": keyword,
        if(withCount == true)
          "withCount": true,
        "limit": limit
      })
    );
    contacts = [];
    totalCount = 0;
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    contacts = this.content["relationship"];
    totalCount = this.content["totalCount"];

    return true;
  }
}

class GetTargetContactsCommand extends WsCommand {
  List<String> targetPlayerIds;
  List<dynamic>? contacts;

  GetTargetContactsCommand(this.targetPlayerIds);

  @override
  String getUri() => Uris.friend.getTargetContacts;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "targetPlayerIds": targetPlayerIds,
        }));

    if(!await processRequest(packet)) {
      return false;
    }

    contacts = this.content["targetPlayers"];

    return true;
  }
}

class SetTargetNicknameCommand extends WsCommand {
  String? playerId;
  String? targetPlayerId;
  String? nickname;

  SetTargetNicknameCommand(this.playerId, this.targetPlayerId, this.nickname);

  @override
  String getUri() => Uris.friend.setTargetNickname;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "playerId": "$playerId",
      "targetPlayerId" : targetPlayerId,
      "nickname": nickname
    }));
    return true;

    if (!await processRequest(packet)) {
      return false;
    }


    return true;
  }
}

class SearchPlayersCommand extends WsCommand {
  String keyword;
  bool searchRelationship;
  String? relationshipCursor;
  String? playerCursor;
  int limit;
  List<dynamic>? contacts;

  SearchPlayersCommand({ required this.keyword, required this.searchRelationship, this.relationshipCursor, this.playerCursor, this.limit = 25});

  @override
  String getUri() => Uris.friend.searchPlayers;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "playerId": MeModel().playerId,
        "keyword": keyword,
        "searchRelationship": searchRelationship,
        "relationshipCursor": relationshipCursor,
        "playerCursor": playerCursor,
        "limit": limit
      })
    );
    return false;

    if(!await processRequest(packet)) {
      return false;
    }

    contacts = this.content["relationship"];

    return true;
  }
}

class SearchAiPlayersCommand extends WsCommand {
  String keyword;
  String? cursor;
  int limit;
  List<dynamic>? contacts;

  SearchAiPlayersCommand({ required this.keyword, this.cursor, this.limit = 25});

  @override
  String getUri() => Uris.ai.aiPlayerList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "keyword": keyword,
        "cursor": cursor,
        "limit": limit
      })
    );
    return false;

    if(!await processRequest(packet)) {
      return false;
    }

    contacts = this.content["aiPlayers"];

    return true;
  }
}