import 'dart:async';
import 'dart:typed_data';

import 'package:square_web/command/command.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/dao/http_dao.dart';
import 'package:square_web/dao/storage/web/localstge_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/emoticon/emoticon_pack_model.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/model/squarepacket.dart';


/*class GetContactByLinkCommand extends HttpCommand {
  late String playerId;
  GetContactByLinkCommand(this.playerId) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.profile.getContactByLink;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        'playerId' : playerId
      }),
    );

    if(!await processRequest(packet))
      return false;

    return true;
  }
}*/


class SetUrlProfileCommand extends WsCommand {
  String? playerId;
  String? profileImgUrl;
  String? nftId;

  SetUrlProfileCommand(this.playerId, this.profileImgUrl, {this.nftId});

  @override
  String getUri() => Uris.profile.updateProfileImg;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({"playerId": "$playerId", "profileImgUrl": profileImgUrl, "nftId" : nftId}));
    return false;

    if (!await processRequest(packet)) {
      return false;
    }

    MeModel().contact!.profileImgUrl = profileImgUrl;
    int result = await StorageDao().setUrlProfile(playerId, profileImgUrl);

    LogWidget.debug("SetUrlProfileCommand : $profileImgUrl : $result");

    return true;
  }
}

class SetShowOnlineStatusCommand extends WsCommand {
  String? playerId;
  bool showOnlineStatus;

  SetShowOnlineStatusCommand(this.playerId, this.showOnlineStatus);

  @override
  String getUri() => Uris.profile.updateEtcInfo;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({"showOnlineStatus": "$showOnlineStatus"}));

    MeModel().showOnlineStatus = showOnlineStatus;
    return true;
    if (!await processRequest(packet)) {
      return false;
    }

    MeModel().showOnlineStatus = showOnlineStatus;

    LogWidget.debug("SetShowOnlineStatusCommand showOnlineStatus : $showOnlineStatus");
    return true;
  }
}

class UploadThumbnailCommand extends WsCommand {
  Uint8List? image;
  String? imageFormat;
  String? objectKey;

  UploadThumbnailCommand({this.image, this.imageFormat, this.objectKey});

  String? uploadedUrl;

  @override
  String getUri() => Uris.profile.uploadThumbnail;

  @override
  Future<bool> execute() async {
    if (image == null) {
      LogWidget.debug("image is null");
      return false;
    }

    return true;

    var packet = SquarePacket(uri: getUri(), body: JsonMap({"playerId": "${MeModel().playerId}", "objectKey": "$objectKey"}));
    if (!await processRequest(packet)) {
      return false;
    }

    String url = resPacket!.getContent().get("url");
    var result = await HttpDao().uploadMedia(url, headers: {"Content-Type": "image/$imageFormat"}, body: this.image);
    if (result?.status == 200) {
      uploadedUrl = resPacket!.getContent().get("uploadedUrl");
      LogWidget.debug("uploaded success : $uploadedUrl");
      return true;
    } else {
      LogWidget.debug("uploaded ${result?.toJson()}");
      return false;
    }
  }
}

class GetPlayerOnlineStatusCommand extends WsCommand {
  String? playerId;
  List<String> targetPlayerIds;
  Map<String, bool> onlineStatus = {};

  GetPlayerOnlineStatusCommand(this.playerId, this.targetPlayerIds);

  @override
  String getUri() => Uris.profile.getPlayerOnlineStatus;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": playerId,
          "targetPlayerIds": targetPlayerIds,
        }));

    return false;

    if (!await processRequest(packet)) {
      return false;
    }

    dynamic status = this.content["status"];
    if (status != null) {
      status.keys.forEach((playerId) {
        onlineStatus.putIfAbsent(playerId, () => status[playerId]);
      });
    }

    return true;
  }
}

class GetMyEmoticonPackListCommand extends WsCommand {
  Set<EmoticonPackModel> emoticons = {};
  String? cursor;
  int? limit;

  GetMyEmoticonPackListCommand({this.cursor, this.limit = 50});

  @override
  String getUri() => Uris.profile.getMyEmoticons;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": MeModel().playerId,
          "limit": limit,
          "cursor": cursor
        }));


   /* if(!await processRequest(packet)) {
      return false;
    }*/

    dynamic emoticons = {
      "playerId":MeModel().playerId,
      "playerEmoticons": {"key":[],"value":null},
      "defaultEmoticons": [
        {"packId":"e001","regTime":1659509823000},
        // {"packId":"e002","regTime":1659509823000}
      ]
    };
    cursor = emoticons["playerEmoticons"]["value"];
    LogWidget.debug("emoticons $emoticons");

    emoticons["playerEmoticons"]["key"]?.forEach((element) {
      this.emoticons.add(EmoticonPackModel.fromMap(element));
    });
    emoticons["defaultEmoticons"]?.forEach((element) {
      this.emoticons.add(EmoticonPackModel.fromMap(element));
    });
    return true;
  }
}

class GetMyNftListCommand extends WsCommand {
  String? cursor;
  String? keyword;
  int limit;

  List<PlayerNftModel> nftModels = [];
  NftQueueStatus? queueStatus;

  GetMyNftListCommand({
    this.cursor,
    this.keyword,
    required this.limit
  });

  @override
  String getUri() => Uris.profile.getMyNftList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "playerId": MeModel().playerId,
      "cursor" : cursor,
      // "blockchainNetType" : MeModel().selectedChainNetType.value.name,
      "keyword": keyword,
      "limit" : limit,
    }));

    if (!await processRequest(packet)) {
      return false;
    }

    cursor = this.content["cursor"];
    String? queueStatusString = this.content["queueStatus"];
    queueStatus = queueStatusString != null ? NftQueueStatus.values.byName(queueStatusString) : null;
    final temp = this.content["nftList"];

    for(var element in temp) {
      final nftModel = PlayerNftModel.fromMap(element);
      nftModels.add(nftModel);
    }
    return true;
  }
}

class SetBlockOptionCommand extends WsCommand {
  late List<String> blockOptions;

  SetBlockOptionCommand(this.blockOptions);

  @override
  String getUri() => Uris.profile.setBlockOptions;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "playerId": MeModel().playerId,
      "blockOptionList": blockOptions
    }));
    return true;

    if (!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class RefreshNftListCommand extends WsCommand {
  String targetPlayerId;
  RefreshNftListCommand(this.targetPlayerId);

  @override
  String getUri() => Uris.profile.refreshMyNftList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "playerId": MeModel().playerId,
      "targetPlayerId" : targetPlayerId,
      "blockchainNetType" : MeModel().selectedChainNetType.value.name,
    }));
    return true;

    if (!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class UpdateProfileCommand extends WsCommand {
  String? profileImgUrl;
  String? nftId;
  String? nickname;
  String? statusMessage;

  UpdateProfileCommand({ this.profileImgUrl, this.nftId, this.nickname, this.statusMessage });

  @override
  String getUri() => Uris.profile.update;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "profileImgUrl": profileImgUrl,
        "nftId": nftId,
        "nickname": nickname,
        "statusMessage": statusMessage,
      }));
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    // 닉네임 중복 상태 코드: 703
    if(status == 703) {

      return false;
    }

    return true;
  }
}

class GetProfilePictureCommand extends WsCommand {
  String targetPlayerId;
  String profileImgNftId;

  GetProfilePictureCommand({
    required this.targetPlayerId,
    required this.profileImgNftId,
  });

  @override
  String getUri() => Uris.profile.getProfilePicture;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "playerId": MeModel().playerId,
      "targetPlayerId": targetPlayerId,
      "profileImgNftId": profileImgNftId,
    }));
    return false;

    if (!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}