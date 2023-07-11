import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/command/command_room.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/extract_url_util.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

import './bloc.dart';

class ChatMessageBloc extends MessageBloc {
  RoomModel _model;
  int? baseTopCursorTime;
  int? baseBottomCursorTime;
  MessageModel? typingMessage;
  Timer? receiveTypingTimer;
  RoomModel get model => _model;
  MessageModel? notSignedUpSystemMessage;
  MessageModel? notKnownSystemMessage;
  MessageModel? tempChatSystemMessage;

  ChatMessageBloc(this._model) : super(MessageUninitialized()) {
    int limit = 25;

    on<FetchMessage>((event, emit) async {
      final currentState = state;

      if((event.backward == false && event.reload == false && _hasTopReachedMax(state)) || (event.backward == true && _hasBottomReachedMax(state))) {
        return;
      }

      try {
        if (state is MessageUninitialized) {
          if (_model.roomId == null) {
            emit(MessageLoaded.empty(hasTopReachedMax: true, hasBottomReachedMax: true));
            return;
          }

          int nowTime = DateTime.now().millisecondsSinceEpoch;
          int lastReadTime =  _model.me?.lastReadTime ?? nowTime;
          baseTopCursorTime = lastReadTime;
          baseBottomCursorTime = lastReadTime;

          MessageLoaded newState = MessageLoaded.empty();
          List<MessageModel> beforeMessages = await _fetchMessages(baseBottomCursorTime!, limit, setReadTime: false, backward: true);
          newState.hasBottomReachedMax = beforeMessages.length < limit;

          if(_model.isTwin) {
            RoomMemberModel targetRoomMember = _model.members.where((element) => element.playerId != MeModel().playerId).first;
            if(targetRoomMember.status == Status.notSignedUp) {
              addNotSignedUpSystemMessage(beforeMessages, _model.smallerSearchName!);
            }

            if(_model.isKnown == false && beforeMessages.length < limit) {
              addNotKnownSystemMessage(beforeMessages);
            }

            if(_model.status == "temp") {
              addTempStatusSystemMessage(beforeMessages);
            }
          }

          newState.messages?.addAll(beforeMessages);

          List<MessageModel> afterMessages = await _fetchMessages(baseTopCursorTime!, limit, setReadTime: _model.isBlocked == true ? false : true, backward: false);
          newState.hasTopReachedMax = afterMessages.length < limit;
          addSeenHereSystemMessage(afterMessages, newState.messages, lastReadTime);

          if(_model.isTwin && !(_model.isAiChat == true)) {
            RoomMemberModel roomMemberModel = _model.members.where((element) => element.playerId != MeModel().playerId).first;
            if(roomMemberModel.isTyping == true) {
              addTypingMessage(roomMemberModel.playerId!);
              newState.messages?.add(typingMessage!);
            }
          }

          RoomManager().getUnreadRoom();

          emit(newState);

        } else if (currentState is MessageLoaded) {

          if(event.backward == true) {
            final messages = await _fetchMessages(baseBottomCursorTime!, limit, setReadTime: false, backward: true);
            bool hasBottomReachedMax = messages.length < limit;

            if(_model.isKnown == false && hasBottomReachedMax == true) {
              addNotKnownSystemMessage(messages);
            }

            _addAllListToSet(currentState.messages, messages);
            emit(currentState.copyWith(messages: currentState.messages, hasBottomReachedMax: hasBottomReachedMax));
          } else {

            final messages = await _fetchMessages(baseTopCursorTime!, limit, setReadTime: _model.isBlocked == true ? false : true, backward: false);
            bool hasTopReachedMax = messages.length < limit;

            _addAllListToSet(currentState.messages, messages);
            emit(currentState.copyWith(messages: currentState.messages, hasTopReachedMax: hasTopReachedMax));
          }
        }
      } catch (e, stacktrace) {
        LogWidget.error("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<ReceivedMessage>((event, emit) async {
      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          if (event.messages!.isNotEmpty && currentState.messages!.length > 0 && currentState.messages?.first.sendTime != event.messages!.first.sendTime
              && event.messages!.first.sender != MeModel().contact!.player) {
            event.messages!.first.hasAnimation = true;
          }

          _addAllListToSet(currentState.messages, event.messages!);
          emit(currentState.copyWith(messages: currentState.messages, reload: true));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<AiMessageReceivedMessage>((event, emit) async {
      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          if (currentState.messages?.first.sendTime != event.message.sendTime && event.message.sender != MeModel().contact!.player) {
            event.message.hasAnimation = true;
          }

          currentState.messages?.forEach((element) {
            if(element.messageId == event.message.messageId) {
              element.messageBody = event.message.messageBody;
              element.status = event.message.status;
            }
          });

          emit(currentState.copyWith(messages: currentState.messages, reload: true));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<SendTextMessage>((event, emit) async {

      late MessageModel messageModel;
      String? firstUrl = ExtractUrlUtil.getFirstUrl(event.text);
      if(firstUrl != null) {
        messageModel = MessageModel(
            sender: MeModel().contact!.player,
            roomId: model.roomId,
            isAiChat: model.isAiChat,
            // contentId: firstUrl,
            fullContentUrl: json.encode({'link': firstUrl}),
            messageBody: event.text,
            messageType: MessageType.link,
            status: MessageStatus.normal);
      } else {
        messageModel = MessageModel(
            sender: MeModel().contact!.player,
            roomId: model.roomId,
            isAiChat: model.isAiChat,
            messageBody: event.text,
            messageType: MessageType.text,
            status: MessageStatus.normal);
      }
      if (messageModel.isInvalid()) {
        LogWidget.debug("SendMessage has invalid messageModel");
        return;
      }
      await RoomManager().sayMessage(messageModel, model);

      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          messageModel.hasAnimation = true;

          currentState.messages!.add(messageModel);
          currentState.messages!.add(MessageModel.dateSystemMessage(
            messageModel.roomId,
            sendTime: messageModel.sendTime));

          emit(currentState.copyWith(
            messages: currentState.messages,
            reload: true
          ));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<RetrySendMessage>((event, emit) async {
      MessageModel newMessage = MessageModel.copyWithSendTime(event.messageModel!, DateTime.now().millisecondsSinceEpoch);
      if(!WebsocketDao().isOpen() && !await WebsocketDao().waitUntilConnect(2000)) {
        event.func.call();
        return;
      }

      await RoomManager().sayMessage(newMessage, model);

      event.func.call();
      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;
          if(currentState.messages!.first != event.messageModel) {
            newMessage.hasAnimation = true;
          }

          currentState.messages!.remove(event.messageModel);

          currentState.messages!.add(MessageModel.dateSystemMessage(
              event.messageModel!.roomId,
              sendTime: event.messageModel!.sendTime));

          emit(currentState.copyWith(messages: currentState.messages));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<SendFailedMessage>((event, emit) {
      try{
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          currentState.messages!.add(event.messageModel);

          emit(currentState.copyWith(messages: currentState.messages));
        }
      }catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<TypingMessage>((event, emit) {
      try{
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          if(event.isTyping == true) {
            addTypingMessage(event.targetPlayerId!);
            currentState.messages!.add(typingMessage!);
          } else {
            receiveTypingTimer?.cancel();
            currentState.messages!.remove(typingMessage);
            typingMessage = null;
          }

          emit(currentState.copyWith(messages: currentState.messages, reload: true));
        }
      }catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<SendEmoticonMessage>((event, emit) async {
      MessageModel _messageModel = MessageModel(
        sender: MeModel().contact!.player,
        roomId: model.roomId,
        messageType: MessageType.emoticon,
        contentId: event.emoticonId,
        messageBody: event.withText,
        status: MessageStatus.normal,
      );

      await RoomManager().sayMessage(_messageModel, model);

      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          _messageModel.hasAnimation = true;

          currentState.messages!.add(_messageModel);
          currentState.messages!.add(MessageModel.dateSystemMessage(
              _messageModel.roomId,
              sendTime: _messageModel.sendTime));

          emit(currentState.copyWith(
              messages: currentState.messages,
          ));
          return ;
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(MessageError());
      }
    });

    on<SendImageMessage>((event, emit) async {

      //multi
      if(event.images != null) {
        for(XFile image in event.images!) {
          await getStateFromSendImage(image.mimeType!, await image.readAsBytes()).then((value) => emit(value));
        }
      } else {
        emit(await getStateFromSendImage(event.mimeType!, event.bytes!));
      }

      FullScreenSpinner.hide();
    });

    on<RemoveForMeMessage>((event, emit) {
      if (state is MessageLoaded) {
        final currentState = state as MessageLoaded;
        currentState.messages!.remove(event.messageModel);
        emit(currentState.copyWith(messages: currentState.messages, reload: true));
      }
    });

    on<ReloadMessage>((event, emit) {
      if (state is MessageLoaded) {
        final currentState = state as MessageLoaded;

        if(_model.isTwin) {
          if (_model.isKnown == true && notKnownSystemMessage != null) {
            currentState.messages?.remove(notKnownSystemMessage!);
            notKnownSystemMessage = null;
          }

          if(_model.isKnown == false && notKnownSystemMessage== null && currentState.hasBottomReachedMax == true) {
            List<MessageModel> messages = [];
            addNotKnownSystemMessage(messages);
            currentState.messages?.addAll(messages);
          }

          if(_model.status != "temp" && tempChatSystemMessage != null) {
            currentState.messages?.remove(tempChatSystemMessage!);
            tempChatSystemMessage = null;
          }
        }

        emit(currentState.copyWith(messages: currentState.messages, reload: true));
      }
    });

    on<InitializeMessage>((event, emit) async {

      if(state is MessageLoaded) {

        final messages = await _fetchMessages(_model.lastMsgTime!, limit, setReadTime: false, backward: true);
        return emit(MessageLoaded.empty()..messages!.addAll(messages)..hasTopReachedMax = true);
      }
    });

  }

  @override
  void onEvent(MessageBlocEvent event) {
    super.onEvent(event);
    LogWidget.debug("ChatMessageBloc event:$event state:$state");
  }

  Future<List<MessageModel>> _fetchMessages(int baseMsgTime, int limit, {bool? setReadTime = false, bool backward = false}) async {
    //TODO: command backward 변경후에 !backward 수정해야됨 : backward
    GetMessagesCommand command = GetMessagesCommand(model.roomId!, baseMsgTime, limit, setReadTime, !backward);
    if(await DataService().request(command)) {
      if(command.lastMessageTime != null) {
        if (backward == true)
          baseBottomCursorTime = command.lastMessageTime;
        else
          baseTopCursorTime = command.lastMessageTime;
      }

      if(setReadTime == true) {
        if(model.isBlocked)
          BlocManager.getBloc<BlockedRoomsBloc>()?.add(UpdateLastMsgBlockedRoom(model.roomId!, message: command.lastMessage));
        else
          BlocManager.getBloc<RoomsBloc>()?.add(UpdateLastMsgRoom(model.roomId!, message: command.lastMessage));
      }

      return command.messages ?? [];
    }
    return [];
  }


  Future<void> _videoUploadToServer(RoomModel roomModel, MessageModel? messageModel, Uint8List originBytes, String? videoFormat) async {

    UploadVideoCommand fullCommand = UploadVideoCommand(roomId: roomModel.roomId, video: originBytes, videoFormat: videoFormat);
    await DataService().request(fullCommand).then((success) async {
      if (success) {
        LogWidget.debug("upload fullVideo command success");
        messageModel!.fullContentUrl = fullCommand.uploadedUrl;

      } else {
        LogWidget.debug("upload fullVideo command fail");
      }
    });
  }

  void addTypingMessage(String playerId) {
    MessageModel messageModel = MessageModel(
      sender:  ContactModelPool().getPlayerContact(playerId).player,
      roomId: model.roomId, messageType: MessageType.typing, status: MessageStatus.normal, regTime: int64MaxValue);

    typingMessage = messageModel;
    if(!(_model.isAiChat ?? false)) {
      receiveTypingTimer?.cancel();
      receiveTypingTimer = Timer(Duration(seconds: receiveTypingTime), () {

        RoomManager().currentMessageBloc?.add(TypingMessage(isTyping: false));
      });
    }

  }

  void _addAllListToSet(SplayTreeSet<MessageModel>? sourceSet, List<MessageModel> targetList) {
    targetList.forEach((target) {
      MessageModel? source = sourceSet!.lookup(target);
      if(source != null) {
        target.hasAnimation = source.hasAnimation;
        target.status = source.status;
        // 이미 존재하면, state는 기존걸 사용하고 객체 교체 => 애니메이션의 초기화가 안일어나게함.
        sourceSet.remove(source);
        sourceSet.add(target);
      }else{
        sourceSet.add(target);
      }
    });
  }

  static Future<void> imageUploadToServer(RoomModel roomModel, MessageModel messageModel, Uint8List thumbData, Uint8List originBytes, String mimeType) async {

    UploadImageCommand fullCommand = UploadImageCommand(roomId: roomModel.roomId!, image: originBytes, thImage: thumbData, mimeType: mimeType);

    await DataService().request(fullCommand).then((success) async {
      if (success) {
        LogWidget.debug("upload image/thImage command success");
        messageModel.thumbnailUrl = fullCommand.uploadedThUrl;
        messageModel.fullContentUrl = fullCommand.uploadedUrl;

      } else {
        LogWidget.debug("upload image/thImage command fail");
      }
    });
  }

  bool _hasTopReachedMax(MessageBlocState state) => state is MessageLoaded && state.hasTopReachedMax!;
  bool _hasBottomReachedMax(MessageBlocState state) => state is MessageLoaded && state.hasBottomReachedMax!;

  static Future<Uint8List> getThumbBytes(Uint8List originBytes) async {
    image.Image img = image.decodeImage(originBytes)!;
    image.Image? resizedImg;
    if(img.width < thumbnailMaxWidth && img.height < thumbnailMaxHeight) {
      resizedImg = img;
    }else if(img.width < thumbnailMaxWidth) {
      resizedImg = image.copyResize(img, height: min(img.height, thumbnailMaxHeight), interpolation: image.Interpolation.average);
    }else if(img.height < thumbnailMaxHeight) {
      resizedImg = image.copyResize(img, width: min(img.width, thumbnailMaxWidth), interpolation: image.Interpolation.average);
    }else {
      if(img.width > img.height) {
        resizedImg = image.copyResize(img, width: thumbnailMaxWidth, interpolation: image.Interpolation.average);
      }else{
        resizedImg = image.copyResize(img, height: thumbnailMaxHeight, interpolation: image.Interpolation.average);
      }
    }
    return Uint8List.fromList(image.encodePng(resizedImg));
  }

  void addSeenHereSystemMessage(List<MessageModel> afterMessages, SplayTreeSet<MessageModel>? messages, int lastReadTime) {
    if(afterMessages.isNotEmpty) {
      MessageModel messageModel = MessageModel(
        messageType: MessageType.system,
        messageBody: L10n.common_15_seen_here,
        sender: MeModel().contact!.player,
        contentId: ConstMsgContentId.seen,
        regTime: lastReadTime,
      );
      afterMessages.add(messageModel);
      messages?.addAll(afterMessages);
    }
  }

  void addNotSignedUpSystemMessage(List<MessageModel> beforeMessages, String name) {
    notSignedUpSystemMessage = MessageModel(
      messageType: MessageType.system,
      messageBody: L10n.common_60_not_signed_up(name),
      sender: MeModel().contact!.player,
      contentId: ConstMsgContentId.notSignedUp,
      regTime: 0,
    );
    beforeMessages.add(notSignedUpSystemMessage!);
  }

  void addNotKnownSystemMessage(List<MessageModel> beforeMessages) {
    notKnownSystemMessage = MessageModel(
      messageType: MessageType.system,
      messageBody: L10n.common_16_not_added_contact,
      sender: MeModel().contact!.player,
      contentId: ConstMsgContentId.notKnown,
      regTime: 1,
    );
    beforeMessages.add(notKnownSystemMessage!);
  }

  void addTempStatusSystemMessage(List<MessageModel> beforeMessages) {
    tempChatSystemMessage = MessageModel(
      messageType: MessageType.system,
      messageBody: L10n.common_62_temp_chat_system_message,
      sender: MeModel().contact!.player,
      contentId: ConstMsgContentId.notKnown,
      regTime: 2,
    );
    beforeMessages.add(tempChatSystemMessage!);
  }

  Future<MessageBlocState> getStateFromSendImage(String mimeType, Uint8List bytes) async {
    MessageModel? messageModel;

    if (mimeType.contains("image/")) {
      Uint8List? thumbData;
      /*
      try {
        thumbData = await ImageUtil.resizeImageWeb(bytes, mimeType);
      } catch(e) {
        LogWidget.debug("getThumbBytes error :$e");
        thumbData = bytes;
      }*/
      thumbData = bytes;

      messageModel = MessageModel(
        sender: MeModel().contact!.player,
        roomId: model.roomId,
        messageType: MessageType.image,
        messageBody: base64Encode(bytes),
        status: MessageStatus.normal,
      );

      await imageUploadToServer(model, messageModel, thumbData!, bytes, mimeType);

    } else {
      return MessageError();
    }

    await RoomManager().sayMessage(messageModel, model);

    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;

      messageModel.hasAnimation = true;

      currentState.messages!.add(messageModel);
      currentState.messages!.add(MessageModel.dateSystemMessage(messageModel.roomId, sendTime: messageModel.sendTime));

      return currentState.copyWith(messages: currentState.messages);
    }

    return MessageError();
  }
}