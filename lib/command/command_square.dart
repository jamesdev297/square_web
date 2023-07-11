import 'dart:html';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/square/square_chat_message_bloc.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/command/command.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/dao/http_dao.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/square/square_member_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/square/user_square_data.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/squarepacket.dart';
import 'package:square_web/service/square_manager.dart';


class GetSquareListCommand extends HttpCommand {
  final List<String> squareIds;

  List<SquareModel>? squares;
  String? nextCursor;

  GetSquareListCommand(this.squareIds) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getSquareList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "squareIds": this.squareIds,
        }));

    return false;

    if (!await processRequest(packet)) {
      return false;
    }

    this.squares = await Future.wait((content['result'] as List<dynamic>).map((e) async {
      SquareModel squareModel = SquareModel.fromMap(e);
      return squareModel;
    }).toList());
    return true;
  }
}

class GetPlayerSquareListCommand extends HttpCommand {
  String playerId;
  String targetPlayerId;
  ChainNetType? blockchainNetType;
  String? cursor;
  bool? isPublic;
  int limit;
  int? totalCount;

  List<SquareModel> squareModels = [];
  NftQueueStatus? queueStatus;

  GetPlayerSquareListCommand(
      {required this.playerId,
      required this.targetPlayerId,
      this.blockchainNetType,
      this.cursor,
      this.isPublic,
      required this.limit}) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getPlayerSquareList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          'playerId': playerId,
          'targetPlayerId': targetPlayerId,
          'isPublic': isPublic,
          'cursor': cursor,
          'limit': limit,
        }));

    squareModels = SquareManager().globalSquareMap.values.take(2).map((e) => e["square"]! as SquareModel).toList();
    cursor = null;
    totalCount = squareModels.length;
    queueStatus = NftQueueStatus.done;
    return true;


   /* if (!await processRequest(packet)) {
      return false;
    }

    cursor = this.content['cursor'];
    totalCount = this.content['totalCount'];
    String? queueStatusString = this.content['queueStatus'];
    queueStatus = queueStatusString != null ? NftQueueStatus.values.byName(queueStatusString) : null;
    final temp = this.content['contractList'];

    for (var element in temp) {
      final squareModel = SquareModel.fromMap(element);
      squareModels.add(squareModel);
    }
    return true;*/
  }
}

class GetSquareMessageCommand extends HttpCommand {
  final String squareId;
  final String channelId;
  final String playerId;
  final int receivedTime;
  SquareChatMsgModel? message;
  GetSquareMessageCommand(this.squareId, this.channelId, this.playerId, this.receivedTime) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getChanelMessage;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": playerId,
          "squareId": squareId,
          "channelId" : channelId,
          "receivedTime": receivedTime,
        }));
    return false;

    if(!await processRequest(packet)) {
      return false;
    }
    dynamic messageMap = this.content["message"];
    if(messageMap != null) {
      message = SquareChatMsgModel.fromMap(messageMap);
    }
    return true;
  }
}

class GetSquareMessagesCommand extends HttpCommand {
  final String squareId;
  final String channelId;
  final int? cursor;
  final int limit;
  final bool? setReadTime;
  final bool backward;

  bool? isAiSaying;
  List<SquareChatMsgModel>? messages;
  Map<String, SquareChatMsgModel>? aiMessages;

  GetSquareMessagesCommand(this.squareId, this.channelId, this.cursor, this.limit, this.setReadTime, this.backward) : super(HttpMethod.GET, withCredential: false);

  int? nextCursor;
  SquareChatMsgModel? latestMessage;
  SquareChatMsgModel? oldestMessage;

  @override
  String getUri() => Uris.square.getChanelMessages;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "playerId": MeModel().playerId,
          "squareId": squareId,
          "channelId": channelId,
          "cursor": cursor,
          "limit": limit,
          "backward": backward,
          "setReadTime": setReadTime,
        }));




  /*  if (!await processRequest(packet)) {
      return false;
    }

    isAiSaying = this.content["isAiSaying"];
    nextCursor = this.content["cursor"];
    List<dynamic> messageMapList = this.content["messages"];
    List<dynamic>? aiMessageMapList = this.content["aiMessages"];

     if(aiMessageMapList != null)
       aiMessages = SquareChatMsgModel.getAiMapListFromList(aiMessageMapList);
    */

    List<dynamic> messageMapList = SquareManager().globalSquareMap[squareId]!["messages"];
    messages = [];
    messages = SquareChatMsgModel.getListFromMapList(messageMapList);
    if (messages?.isNotEmpty == true) {
      if(messages!.last.sendTime! < messages!.first.sendTime!) {
        latestMessage = messages!.first;
        oldestMessage = messages!.last;
      } else {
        latestMessage = messages!.last;
        oldestMessage = messages!.first;
      }
    }

    Map<String, SquareChatMsgModel> insertDates = {};

    messages!.removeWhere((message) {
      if (message.messageType == MessageType.skill) {
        return true;
      } else {
        String dateString = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(message.sendTime!));
        insertDates.putIfAbsent(
            dateString, () => SquareChatMsgModel.dateSystemMessage(squareId, channelId, dateString: dateString));

        return false;
      }
    });

    messages!.addAll(insertDates.values); //시간메세지 추가
    return true;
  }
}

class UploadSquareChatImageCommand extends HttpCommand {
  final String squareId;
  final String channelId;
  final Uint8List image;
  final Uint8List thImage;
  String mimeType;

  UploadSquareChatImageCommand(
      {required this.squareId,
      required this.channelId,
      required this.image,
      required this.thImage,
      this.mimeType = "image/png"}) : super(HttpMethod.GET, withCredential: false);

  String? uploadedUrl;
  String? uploadedThUrl;

  @override
  String getUri() => Uris.square.uploadSquareChatImage;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(), body: JsonMap({"playerId": MeModel().playerId, "squareId": squareId, "channelId": channelId}));

    return false;

    if (!await processRequest(packet)) {
      return false;
    }
    String putUrl = resPacket!.getContent().get("url");
    String putThUrl = resPacket!.getContent().get("thUrl");
    LogWidget.debug("url : $putUrl, thUrl : $putThUrl");

    List<Future> futures = [];

    futures.add(HttpDao().uploadMedia(putUrl, headers: {"Content-Type": mimeType }, body: this.image));
    futures.add(HttpDao().uploadMedia(putThUrl, headers: {"Content-Type": mimeType }, body: this.thImage));

    return await Future.wait(futures).then((value) {
      if (value[0].status == 200 && value[1].status == 200) {
        uploadedUrl = resPacket!.getContent().get("uploadedUrl");
        uploadedThUrl = resPacket!.getContent().get("thUploadedUrl");
        return true;
      }
      return false;
    });
  }
}

class SayToSquareCommand extends HttpCommand {
  SquareChatMsgModel model;
  SquareChatMessageBloc? messageBloc;

  SayToSquareCommand(this.model, {this.messageBloc}) : super(HttpMethod.GET, withCredential: false);
  bool isRestricted = false;
  AiLimitReachedInfo? aiLimitReachedInfo;

  @override
  String getUri() => Uris.square.sayMessages;

  @override
  Future<bool> execute() async {
    model.sendCompleter?.complete(true);
    model.sendTime = DateTime.now().millisecondsSinceEpoch;
    model.status = MessageStatus.normal;
    return true;

    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "squareId": model.squareId,
          "channelId": model.channelId,
          "playerId": model.sender!.playerId,
          "messageType": model.messageType.name,
          if (model.messageBody != null) "messageBody": model.messageBody,
          if (model.thumbnailUrl != null) "thumbnailUrl": model.thumbnailUrl,
          if (model.fullContentUrl != null) "fullContentUrl": model.fullContentUrl,
          if (model.contentId != null) "contentId": model.contentId,
        }));

    if (!WebsocketDao().isOpen() || !await processRequest(packet)) {
      LogWidget.debug("send failed");
      model.sendCompleter?.complete(false);
      model.status = MessageStatus.sendFailed;
      if(!messageBloc!.isClosed)
        messageBloc!.add(SendFailedMessage(model));

      if(resPacket?.getStatus() == CustomStatus.SQUARE_RESTRICTED_PLAYER) {
        MeModel().squareRestrictEndTime = resPacket!.getContent().map?['restrictEndTime'];
        this.isRestricted = true;
      }
      return false;
    }

    model.sendCompleter?.complete(true);
    model.sendTime = this.content["sendTime"];
    model.status = MessageStatus.normal;
    if(this.content['exceedLimit'] == true) {
      aiLimitReachedInfo = AiLimitReachedInfo(this.content['aiModel'], this.content['dailyLimit']);
    }

    return true;
  }
}

class GetSquareMembersCommand extends HttpCommand {
  final String squareId;
  final OrderType orderType;
  final SquareMemberType? memberType;
  final String? cursor;
  final int limit;

  List<SquareMember>? members;
  String? nextCursor;

  GetSquareMembersCommand({required this.squareId, required this.orderType, this.cursor, this.memberType, required this.limit})
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getSquareMembers;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "squareId": this.squareId,
          "orderType": this.orderType.name,
          if(this.cursor != null)
            "cursor": this.cursor,
          if(this.memberType != null)
            "memberType" : this.memberType!.name,
          "limit": this.limit,
          "withContacts": true
        }));

    members = SquareManager().globalSquareMap[squareId]!["members"];
    return true;


    if (!await processRequest(packet)) {
      return false;
    }
    this.members = (content['members'] as List<dynamic>).map((e) => SquareMember.fromMap(e)).toList();
    this.nextCursor = content['cursor'];
    return true;
  }
}

class SearchSquareByNameCommand extends HttpCommand {
  final String keyword;
  final bool fromAll;
  final ChainNetType? blockchainNetType;
  final String? cursor;
  final int limit;

  List<SquareModel>? squares;
  String? nextCursor;

  SearchSquareByNameCommand({required this.keyword, required this.fromAll, this.blockchainNetType, this.cursor, required this.limit})
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.searchSquareByName;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "keyword": this.keyword,
          "fromAll": this.fromAll,
          if(this.blockchainNetType != null)
            "blockchainNetType": this.blockchainNetType?.name,
          if(this.cursor != null)
            "cursor": this.cursor,
          "limit": this.limit
        }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    this.squares = await Future.wait((content['result'] as List<dynamic>).map((e) async {
      SquareModel squareModel = SquareModel.fromMap(e);
      return squareModel;
    }).toList());

    this.nextCursor = content['cursor'];
    return true;
  }
}

class SquareMessageReportCommand extends HttpCommand {
  final String squareId;
  final String channelId;
  final int sendTime;
  final String targetPlayerId;

  SquareMessageReportCommand(this.squareId, this.channelId, this.sendTime, this.targetPlayerId)
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.reportMessage;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": this.squareId,
        "channelId": this.channelId,
        "sendTime": this.sendTime,
        "targetPlayerId": this.targetPlayerId
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class CheckMessageReportCommand extends HttpCommand {
  final String squareId;
  final String channelId;
  final int sendTime;
  final String targetPlayerId;

  CheckMessageReportCommand(this.squareId, this.channelId, this.sendTime, this.targetPlayerId)
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.checkReportedMessage;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": this.squareId,
        "channelId": this.channelId,
        "sendTime": this.sendTime,
        "targetPlayerId": this.targetPlayerId
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }
    return true;
  }
}

class SearchSquareByAddressCommand extends HttpCommand {
  final String contractAddress;
  final ChainNetType? blockchainNetType;

  SquareModel? square;

  SearchSquareByAddressCommand({required this.contractAddress, this.blockchainNetType})
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.searchSquareByAddress;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "contractAddress": this.contractAddress,
        if(this.blockchainNetType != null)
          "blockchainNetType": this.blockchainNetType?.name,
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    if(content['result'] != null) {
      this.square = SquareModel.fromMap(content['result']);
    }
    return true;
  }
}

class SearchSquareMembersCommand extends HttpCommand {
  final String squareId;
  final String keyword;
  final String? cursor;
  final int limit;

  List<SquareMember>? contacts;
  String? nextCursor;

  SearchSquareMembersCommand({required this.squareId, required this.keyword, this.cursor, required this.limit})
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.searchSquareMembers;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "squareId": this.squareId,
          "keyword": this.keyword,
          if(this.cursor != null)
            "cursor": this.cursor,
          "limit": this.limit
        }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    this.contacts = (content['contacts'] as List<dynamic>).map((e) => SquareMember.fromMap(e)).toList();
    this.nextCursor = content['cursor'];
    return true;
  }
}

class GetTrendingSquareListCommand extends HttpCommand {

  List<SquareModel>? squares;
  String? cursor;
  int limit;

  GetTrendingSquareListCommand({this.cursor, this.limit = 20})
      : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getTrendingSquareList;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "cursor": this.cursor,
        "limit": this.limit
      }));

    squares = SquareManager().globalSquareMap.values.skip(2).map((e) => e["square"]! as SquareModel).toList();
    return true;


    if (!await processRequest(packet)) {
      return false;
    }

    this.cursor = content['cursor'];
    this.squares = await Future.wait((content['result'] as List<dynamic>).map((e) async {
      SquareModel squareModel = SquareModel.fromMap(e);
      return squareModel;
    }).toList());

    return true;
  }
}

class JoinSquareCommand extends HttpCommand {

  String squareId;

  JoinSquareCommand(this.squareId) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.joinSquare;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": squareId,
      }));

    return true;


    if (!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class LeaveSquareCommand extends HttpCommand {

  String squareId;

  LeaveSquareCommand(this.squareId) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.leaveSquare;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": squareId,
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class GetSquareCommand extends HttpCommand {

  String squareId;
  SquareModel? square;

  GetSquareCommand(this.squareId) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getSquare;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": squareId,
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    square = SquareModel.fromMap(this.content['square']);
    square?.joined = this.content['joined'];

    return true;
  }
}


class GetSquareProfileCommand extends HttpCommand {
  String squareId;
  SquareModel? squareModel;
  GetSquareProfileCommand({required this.squareId}) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getSquareProfile;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "squareId": squareId,
        })
    );

    return false;


    if(!await processRequest(packet)) {
      return false;
    }

    dynamic square = this.content["square"];
    if(square == null) {
      return false;
    }

    squareModel = SquareModel.fromMap(square);
    return true;
  }
}

class ResetAiHistorySquareCommand extends HttpCommand {

  final String? squareId;
  final String channelId;

  ResetAiHistorySquareCommand(this.squareId, this.channelId) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.resetAiHistory;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId" : squareId,
        "channelId" : channelId,
      }));

    return false;


    if(!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class AddUserSquareCommand extends HttpCommand {
  UserSquareData updatedData;

  AddUserSquareCommand(this.updatedData) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.addSquare;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareName": updatedData.squareName,
        "squareType": updatedData.squareType.name,
        "aiPlayerId": updatedData.aiPlayerId,
        "lang": updatedData.lang,
      })
    );

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class EditUserSquareCommand extends HttpCommand {
  String squareId;
  SquareType squareType;
  String? squareName;
  String? aiPlayerId;

  EditUserSquareCommand(this.squareId, this.squareType, {this.squareName, this.aiPlayerId }) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.updateSquare;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": squareId,
        "squareType": squareType.name,
        "squareName": squareName,
        "aiPlayerId": aiPlayerId,
      }));

    return false;


    if (!await processRequest(packet)) {
      return false;
    }

    return true;
  }
}

class UploadThumbnailSquareCommand extends HttpCommand {
  String squareId;
  Uint8List? image;
  String? imageFormat;

  UploadThumbnailSquareCommand(this.squareId, {this.image, this.imageFormat}) : super(HttpMethod.GET, withCredential: false);

  String? uploadedUrl;

  @override
  String getUri() => Uris.square.uploadThumbnail;

  @override
  Future<bool> execute() async {
    if (image == null) {
      LogWidget.debug("image is null");
      return false;
    }

    return false;

    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "squareId": squareId
    }));
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

class GetAiMemberInSquareCommand extends HttpCommand {
  String squareId;
  ContactModel? contactModel;
  GetAiMemberInSquareCommand({required this.squareId}) : super(HttpMethod.GET, withCredential: false);

  @override
  String getUri() => Uris.square.getAiMember;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "squareId": squareId,
      })
    );

    return false;

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