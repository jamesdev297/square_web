import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:square_web/bloc/square/square_bloc.dart';
import 'package:square_web/bloc/square/square_chat_message_bloc.dart';
import 'package:square_web/bloc/square/trending_square_bloc.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_member_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/square/user_square_data.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/page/room/chat_page.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/square/square_dialog.dart';

import '../bloc/change_keyboard_type_bloc.dart';

class SquareManager {
  static SquareManager? _instance;

  SquareManager._internal();

  factory SquareManager() => _instance ??= SquareManager._internal();

  // key: address
  Map<String, SquareModel> _squareMap = {};

  // key: address
  Map<String, SquareModel> get squareMap => _squareMap;

  // key : squareId
  Map<String, ValueNotifier<AiChatSquareStatus?>> _aiChatSquareStatusMap = {};

  ValueNotifier<SquareFolder> selectedSquareFolder = ValueNotifier(SquareFolder.public);

  List<ContactModel> getMockMembers() {
    int totalMemberCnt = ContactManager().globalPlayerMap.keys.length;
    var members = ContactManager().globalPlayerMap.values.map((e) => ContactModel.fromMap(e)).toList();
    List<ContactModel> result = [];
    for(int i=0;i<totalMemberCnt;i++) {
      if(random.nextBool()) {
        result.add(members[i]);
      }
    }
    return result;
  }

  SquareMember getMockSquareMember(ContactModel contact) {
    return SquareMember.fromMap({
      "playerId": contact.playerId,
      "status":"active",
      "squareMemberStatus":"joined",
      "nickname":contact.nickname,
      "targetNickname":null,
      "addedContract":true,
      "profileImgUrl":contact.profileImgUrl,
      "profileImgNftId":null,
      "statusMessage":"",
      "blockchainNetType":"ethereum",
      "regTime":1682313093117,
      "signedUp":true,
      "online":true
    });
  }

  Map<String, Map<String, dynamic>> globalSquareMap = {};

  List<dynamic> initMockMessages(String squareId, List<SquareMember> members) {
    List<dynamic> result = [];
    var msgCnt = random.nextInt(100);

    int lastTime = DateTime.now().millisecondsSinceEpoch - random.nextInt(100000);

    if(members.isNotEmpty) {
      for(int i=0;i<msgCnt;i++) {
        result.add(
            {
              "playerId" : members[random.nextInt(members.length)].playerId,
              "status" : "normal",
              "messageType" : "text",
              "messageBody" : "테스트입니다.",
              "sendTime" : lastTime,
              "squareId" : squareId,
              "channelId" : "0",
              "receivedTime" : lastTime,
            }
        );
        lastTime -= random.nextInt(10000);
      }
    }

    return result;
  }

  void init() {
    globalSquareMap = {
      "testSquare" : {
        "square" : SquareModel(
            squareName: "바른생활",
            squareImgUrl: "https://image.aladin.co.kr/product/28299/21/cover500/e232539892_1.jpg",
            squareId: "testSquare",
            contractAddress: "testSquare",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList()..add(getMockSquareMember(MeModel().contact)),
      },
      "testSquare2" : {
        "square" : SquareModel(
            squareName: "BAYC",
            squareImgUrl: "https://www.coindeskkorea.com/news/photo/202112/76663_16784_041.jpg",
            squareId: "testSquare2",
            contractAddress: "testSquare2",
            chainNetType: ChainNetType.ethereum),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList()..add(getMockSquareMember(MeModel().contact)),
      },
      "testSquare3" : {
        "square" : SquareModel(
            squareName: "비트코인",
            squareImgUrl: "https://media.istockphoto.com/id/1035399110/vector/blockchain-bitcoin-icon.jpg?s=612x612&w=0&k=20&c=OOMeer3q-ZxhGQTOwbOin2v2Ga7wbyCquuo77jDvQak=",
            squareId: "testSquare3",
            contractAddress: "testSquare3",
            chainNetType: ChainNetType.ethereum),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare4" : {
        "square" : SquareModel(
            squareName: "통기타",
            squareImgUrl: "https://www.artinsight.co.kr/data/tmp/1909/13ddee06b95ae39ecab5f6bdc7f13968_Zbm8ChBAciaWsTqfMmpxwbTqoQPUNlxp.jpg",
            squareId: "testSquare4",
            contractAddress: "testSquare4",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare5" : {
        "square" : SquareModel(
            squareName: "대나무숲",
            squareImgUrl: "https://gongu.copyright.or.kr/gongu/wrt/cmmn/wrtFileImageView.do?wrtSn=13274696&filePath=L2Rpc2sxL25ld2RhdGEvMjAyMC85OC9DTFMxMDAwNi8xMzI3NDY5Nl9XUlRfOThfQ0xTMTAwMDZfMjAyMDEyMThfMQ==&thumbAt=Y&thumbSe=b_tbumb&wrtTy=10006",
            squareId: "testSquare5",
            contractAddress: "testSquare5",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare6" : {
        "square" : SquareModel(
            squareName: "버킷리스트",
            squareImgUrl: "https://media.istockphoto.com/id/899960464/ko/%EC%82%AC%EC%A7%84/%EB%B2%84%ED%82%B7-%EB%A6%AC%EC%8A%A4%ED%8A%B8.jpg?s=1024x1024&w=is&k=20&c=h6fhlacUclNM70QRu-8gSK51iY5RhmJc3Yqoj1Tw33c=",
            squareId: "testSquare6",
            contractAddress: "testSquare6",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare7" : {
        "square" : SquareModel(
            squareName: "해외여행",
            squareImgUrl: "https://m.hanacard.co.kr/images/contents/travel/travel-3-02.png",
            squareId: "testSquare7",
            contractAddress: "testSquare7",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare8" : {
        "square" : SquareModel(
            squareName: "패션",
            squareImgUrl: "https://static.luck-d.com/community/board/530/thumbnail_1677422507727.jpg",
            squareId: "testSquare8",
            contractAddress: "testSquare8",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      },
      "testSquare9" : {
        "square" : SquareModel(
            squareName: "연애",
            squareImgUrl: "https://img1.daumcdn.net/thumb/R1280x0.fjpg/?fname=http://t1.daumcdn.net/brunch/service/user/1r5A/image/ZxO6SVvYrqvMT7lYC8oGWC_omUI.jpg",
            squareId: "testSquare9",
            contractAddress: "testSquare9",
            chainNetType: ChainNetType.user),
        "members" : getMockMembers().map((e) => getMockSquareMember(e)).toList(),
      }
    };

    globalSquareMap.forEach((key, value) {
      List<SquareMember> members = value["members"];
      value.putIfAbsent("messages", () => initMockMessages(key, members));
    });
  }

  static void destroy() {
    _instance = null;
  }

  void setSquares(List<SquareModel> square) {
    squareMap.addAll(Map.fromIterable(square, key: (e) => e.squareId, value: (e) => e));
  }

  bool hasSquare(String squareId) {
    return squareMap.containsKey(squareId);
  }

  String makeSquareId(String address) {
    return 'ai-${address}';
  }


  ValueNotifier<AiChatSquareStatus?> getAiChatSquareStatus(String squareId) {
    if(_aiChatSquareStatusMap.containsKey(squareId)) {
      return _aiChatSquareStatusMap[squareId]!;
    }
    return _aiChatSquareStatusMap.putIfAbsent(squareId, () => ValueNotifier<AiChatSquareStatus?>(null));
  }

  Future<SquareBloc?>? getPlayerSquareBlocAsync(ContactModel contactModel, {bool? initBloc = true}) async {
    Completer initCompleter = Completer();
    SquareBloc squareBloc = _getPlayerSquareBloc(contactModel.playerId, initBloc: initBloc, initCompleter: initCompleter);
    await initCompleter.future;
    return squareBloc;
  }

  SquareBloc? getPlayerSquareBloc(ContactModel contactModel, {bool? initBloc = true, bool? isPublic}) {
    return _getPlayerSquareBloc(contactModel.playerId, initBloc: initBloc,isPublic: isPublic);
  }

  SquareBloc _getPlayerSquareBloc(String wallet, {bool? initBloc = true, Completer? initCompleter, bool? isPublic}) {
    SquareBloc? value = SquareBloc(playerId: wallet, isPublic: isPublic);
    if (initBloc ?? false) {
      value.add(InitSquare(initCompleter: initCompleter));
    }
    return value;
  }

  void _showSquareLeftDialog() {
    SquareDefaultDialog.showSquareDialog(
        uniqueDialogKey: UniqueDialogKey.squareLeftMember,
        title: L10n.square_01_36_square_cant_enter_dialog_title,
        description: L10n.square_01_36_square_cant_enter_dialog_content,
        button1Text: L10n.common_02_confirm,
        button1Action: () {
          HomeNavigator.initCurrentTab();
          HomeNavigator.expandOneDepth(true);
          HomeNavigator.popTwoDepth();
          SquareListPageHome.isIconView = true;
          SquareDefaultDialog.closeDialog().call();
        });
  }

  int messageEasingCount = 0;
  int latestBaseMsgTime = 0;
  bool finishMessageEasing = true;
  Future<GetSquareMessagesCommand> fetchMessages(SquareModel model, String channelId, int baseMsgTime, int limit, {bool? setReadTime = false, bool backward = false}) async {

    var msgTime = baseMsgTime;
    if(!backward && messageEasingCount > 0) {
      msgTime = latestBaseMsgTime - 1000;
      messageEasingCount--;
      if(messageEasingCount <= 0) {
        messageEasingCount = 0;
        finishMessageEasing = true;
      }
    }

    GetSquareMessagesCommand command = GetSquareMessagesCommand(model.squareId, channelId, msgTime, limit, setReadTime, backward);
    await DataService().request(command);
    if (command.status == CustomStatus.SQUARE_LEFT_PLAYER) {
      _showSquareLeftDialog();
    }
    if(SquareModel.isAiChatSquare(model.squareId)) {
      ValueNotifier<AiChatSquareStatus?> statusNotifier = SquareManager().getAiChatSquareStatus(model.squareId);
      if(command.isAiSaying == true) {
        statusNotifier.value = AiChatSquareStatus.RUNNING;
      } else {
        statusNotifier.value = AiChatSquareStatus.ENABLE;
      }
    }

    if(!backward && messageEasingCount == 0 && command.messages?.isEmpty == true && latestBaseMsgTime == baseMsgTime && !finishMessageEasing) {
      messageEasingCount = 2;
    }

    if(!backward && latestBaseMsgTime < baseMsgTime) {
      latestBaseMsgTime = baseMsgTime;
      finishMessageEasing = false;
    }

    return command;
  }

  Future<MapEntry<MessageStatus, Object?>> sayMessage(SquareChatMsgModel messageModel, SquareChatMessageBloc messageBloc, ChangeKeyboardTypeBloc changeKeyboardTypeBloc) async {
    // messageModel.sendCompleter = Completer<bool>();
    final oldMessageManagerKey = messageModel.messageManagerKey;

    SayToSquareCommand command = SayToSquareCommand(messageModel, messageBloc: messageBloc);
    if (!await DataService().request(command)) {
      LogWidget.debug("SayCommand failed, ${command.isRestricted}");
      if (command.isRestricted) {
        changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.restricted));
        showRestrictedDialog();
        return MapEntry(MessageStatus.restricted, null);
      }
      if (command.status == CustomStatus.SQUARE_LEFT_PLAYER) {
        _showSquareLeftDialog();
      }
      return MapEntry(MessageStatus.sendFailed, null);
    }

    LogWidget.debug("SayCommand success");
    SquareManager().globalSquareMap[messageModel.squareId]?["messages"].add(messageModel.toMap());


    // messageModel.sendTime = command.content["receivedTime"] as int?;
    // messageModel.receivedTime = command.content["receivedTime"] as int?;
    if(command.aiLimitReachedInfo != null) {
      return MapEntry(MessageStatus.aiLimitReached, command.aiLimitReachedInfo);
    }
    return MapEntry(MessageStatus.normal, null);
  }

  Future<MapEntry<List<SquareMember>, String?>?> getSquareMembers(SquareModel square, OrderType orderType,
      {String? cursor, SquareMemberType? memberType}) async {
    GetSquareMembersCommand cmd =
        GetSquareMembersCommand(squareId: square.squareId, orderType: orderType, memberType: memberType, cursor: cursor, limit: 30);
    if (!await DataService().request(cmd)) {
      return null;
    }

    return MapEntry(cmd.members!, cmd.nextCursor);
  }

  Future<MapEntry<List<SquareMember>, String?>?> searchSquareMembers(SquareModel square, String keyword, {String? cursor}) async {
    SearchSquareMembersCommand cmd = SearchSquareMembersCommand(squareId: square.squareId, keyword: keyword.trim(), cursor: cursor, limit: 30);
    if(!await DataService().request(cmd)) {
      LogWidget.error("search square fail. code : ${cmd.resPacket?.getStatus()}");
      return null;
    }
    return MapEntry(cmd.contacts!, cmd.nextCursor);
  }

  Future<PlayerNftModel?> loadProfilePicture(String targetPlayerId, String profileImgNftId) async {
    GetProfilePictureCommand command = GetProfilePictureCommand(targetPlayerId: targetPlayerId, profileImgNftId: profileImgNftId);
    if (await DataService().request(command)) {
      LogWidget.debug("GetPlayerNftCommand success!!!!");

      PlayerNftModel playerNftModel = PlayerNftModel.fromMap(command.content['profilePicture']);
      // playerNftModel.imgUrl = await ImageUtil.getNftImgUrl(playerNftModel.imgUrl, playerNftModel.contractAddress, playerNftModel.tokenId);
      return playerNftModel;
    }

    return null;
  }

  Future<int> reportSquareMessage(SquareChatMsgModel reportTargetMessage) async {
    SquareMessageReportCommand command = SquareMessageReportCommand(reportTargetMessage.squareId!,
        reportTargetMessage.channelId!, reportTargetMessage.sendTime!, reportTargetMessage.playerId!);
    await DataService().request(command);
    return command.resPacket?.getStatus() ?? -1;
  }

  Future<int> checkReportedSquareMessage(SquareChatMsgModel reportTargetMessage) async {
    CheckMessageReportCommand command = CheckMessageReportCommand(reportTargetMessage.squareId!,
        reportTargetMessage.channelId!, reportTargetMessage.sendTime!, reportTargetMessage.playerId!);
    await DataService().request(command);
    return command.resPacket?.getStatus() ?? -1;
  }

  void showRestrictedDialog() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(MeModel().squareRestrictEndTime);
    SquareDefaultDialog.showSquareDialog(
        title: L10n.square_01_31_chat_restricted_dialog_title,
        description: L10n.square_01_32_chat_restricted_dialog_context(dateTime.year, dateTime.month, dateTime.day,
            dateTime.hour.toString().padLeft(2, '0'), dateTime.minute.toString().padLeft(2, '0')),
        button1Text: L10n.common_02_confirm);
  }

  void clickSquare(SquareModel square, {bool popBeforeWidget = false, bool? joined}) async {
    HomeNavigator.clearTwoDepthPopUp();
    RoomManager().popActionRoom();
    SquareListPageHome.isIconView = false;
    HomeNavigator.push(RoutePaths.square.squareChat, arguments: square);

    return ;
    SquareModel? squareModel = await getSquare(square.squareId);

    if(square.squareType == SquareType.token || square.squareType == SquareType.etc || square.squareType == SquareType.user) {
      SquareDialog.enterSquare(squareModel ?? square, popBeforeWidget: popBeforeWidget);
    } else {
      SquareDialog.show(square: squareModel ?? square, joined: squareModel?.joined ?? SquareManager().hasSquare(square.squareId), popBeforeWidget: popBeforeWidget);
    }
  }

  Future<bool> joinSquare(SquareModel square) async {
    JoinSquareCommand command = JoinSquareCommand(square.squareId);
    if(await DataService().request(command)) {

      if(square.squareType == SquareType.user) {
        BlocManager.getBloc<SecretSquareBloc>()?.add(InitSquare());
      } else {
        BlocManager.getBloc<TrendingSquareBloc>()?.add(RemoveTrendingSquareEvent(square.squareId));
        BlocManager.getBloc<PublicSquareBloc>()?.add(InitSquare());
      }
      return true;
    }

    return false;
  }

  Future<bool> leaveSquare(SquareModel square) async {
    LeaveSquareCommand command = LeaveSquareCommand(square.squareId);
    if(await DataService().request(command)) {

      if(square.squareType == SquareType.user) {
        BlocManager.getBloc<SecretSquareBloc>()?.add(InitSquare());
      } else {
        BlocManager.getBloc<TrendingSquareBloc>()?.add(AddTrendingSquareEvent(square));
        BlocManager.getBloc<PublicSquareBloc>()?.add(InitSquare());
      }
      return true;
    }

    return false;
  }

  Future<SquareModel?> getSquare(String squareId) async {
    return SquareManager().globalSquareMap[squareId]!["square"];
    GetSquareCommand command = GetSquareCommand(squareId);
    if(await DataService().request(command)) {
      return command.square;
    }

    return null;
  }

  Future<SquareChatMsgModel> getSquareChatMsg(SquareChatMsgModel msgModel) async {

    GetSquareMessageCommand command = GetSquareMessageCommand(msgModel.squareId!, msgModel.channelId!, msgModel.sender!.playerId, msgModel.sendTime!);
    if(await DataService().request(command)) {
      if(command.message != null) {
        return command.message!;
      }
    }
    msgModel.status = MessageStatus.normal;

    return msgModel;
  }

  Future<bool> resetAiHistory(String squareId, SquareChatMessageBloc messageBloc) async {
    String channelId = "0";

    ResetAiHistorySquareCommand command = ResetAiHistorySquareCommand(squareId, channelId);
    if(await DataService().request(command)) {

      messageBloc.add(FetchMessage(false, reload: true));

      return true;
    }

    return false;
  }

  Future<String?> addUserSquare(UserSquareData updatedData) async {

    AddUserSquareCommand command = AddUserSquareCommand(updatedData);
    if(await DataService().request(command)) {
      return command.content['squareId'];
    }

    return null;
  }

  Future<bool> editUserSquare(String squareId, { String? squareName, String? aiPlayerId }) async {

    EditUserSquareCommand command = EditUserSquareCommand(squareId, SquareType.user, squareName: squareName, aiPlayerId: aiPlayerId);
    if(await DataService().request(command)) {

      return true;
    }

    return false;
  }

  Future<String?> uploadThumbnailSquare(String squareId, Uint8List imageFile) async {
    LogWidget.debug("_pickImage : selected");
    if (await WebsocketDao().waitUntilConnect(3000) == false) {
      LogWidget.debug("waitUntilConnect failed");
      return null;
    }

    LogWidget.debug("waitUntilConnect : success");

    UploadThumbnailSquareCommand uploadThumbnailCommand = UploadThumbnailSquareCommand(squareId, image: imageFile, imageFormat: "png");
    if (await DataService().request(uploadThumbnailCommand)) {
      LogWidget.debug("uploadedPath : ${uploadThumbnailCommand.uploadedUrl}");

    }
    return uploadThumbnailCommand.uploadedUrl;
  }

  Future<ContactModel?> getAiMemberSquare(String squareId) async {

    GetAiMemberInSquareCommand command = GetAiMemberInSquareCommand(squareId: squareId);
    if(await DataService().request(command)) {
      ContactModelPool().add(command.contactModel!);

      return command.contactModel!;
    }

    return null;
  }


}
