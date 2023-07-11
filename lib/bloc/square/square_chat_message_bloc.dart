import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:scidart/numdart.dart';
import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
import 'package:square_web/bloc/message_bloc.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/bloc/message_bloc_state.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/extract_url_util.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

class SquareChatMessageBloc extends MessageBloc {
  SquareModel _model;
  String _channelId;
  late int oldestSendTime;
  late int latestSendTime;
  Timer? messagePoller;
  final ChangeKeyboardTypeBloc _changeKeyboardTypeBloc;

  SquareModel get model => _model;
  bool pauseFetching = false;

  final int limit = 50;
  static final int POLLING_DELAY = 500;

  Map<String, SquareChatMsgModel> aiSayingMessageMap = {};

  MessageBlocState makeError(MessageBlocState state) {
    if(state is MessageLoaded)
      return state.copyWith(isOnError: true, reload: true);
    else
      return MessageError();
  }

  SquareChatMessageBloc(this._model, this._channelId, this._changeKeyboardTypeBloc) : super(MessageUninitialized()) {
    on<FetchMessage>((event, emit) async {
      final currentState = state;

      try {
        if (state is MessageUninitialized) {
          messagePoller?.cancel();
          int nowTime = DateTime.now().millisecondsSinceEpoch;
          MessageLoaded newState = MessageLoaded.empty();
          GetSquareMessagesCommand result = await SquareManager().fetchMessages(_model, _channelId, nowTime, limit, setReadTime: true, backward: true);
          // if (result.status != HttpStatus.ok || result.messages == null) {
          if (result.messages == null) {
            return;
          }

          aiSayingMessageMap.addAll(result.aiMessages?? {});

          var latestMessages = result.messages!;

          if(result.aiMessages?.isNotEmpty == true) {
            for (var element in latestMessages) {
              element.status = MessageStatus.normal;
              if (result.aiMessages?.containsKey(element.messageId) == true) {
                element.status = MessageStatus.aiSaying;
                element.messageBody = result.aiMessages?[element.messageId]?.messageBody;
              }
            }
          }

          var cursor = result.nextCursor;

          if (latestMessages.isNotEmpty) {
            oldestSendTime = result.oldestMessage!.sendTime!;
            latestSendTime = result.latestMessage!.sendTime!;
          } else {
            oldestSendTime = latestSendTime = nowTime;
          }

          // addSeenHereSystemMessage(afterMessages, newState.messages, lastReadTime);
          newState.messages?.addAll(latestMessages);
         /* messagePoller = Timer.periodic(Duration(milliseconds: POLLING_DELAY), (timer) {
            if (pauseFetching) return;

            if (this.isClosed) return messagePoller?.cancel();

            // if(!WebsocketDao().isOpen())
            //   return;

            if (state is MessageLoaded) this.add(FetchMessage(false));
          });*/
          return emit(newState);
        } else if (state is MessageLoaded) {
          var currentState = state as MessageLoaded;
          if (event.backward == false) {
            GetSquareMessagesCommand result = await SquareManager().fetchMessages(_model, _channelId, latestSendTime, limit, setReadTime: true);

            if (result == null || result.status != HttpStatus.ok) return emit(makeError(currentState));
            if(result.messages?.isEmpty == true && !(result.isAiSaying == true) && aiSayingMessageMap.isEmpty == true)
              return;

            bool hasBottomReachedMax = result.nextCursor == null;
            // LogWidget.debug("-----latestSendTime : ${messagesEntry.value} / ${ messagesEntry.key.isNotEmpty ? messagesEntry.key.last.sendTime! : null} ${ messagesEntry.key.isNotEmpty ? messagesEntry.key.last : null } / ${ latestSendTime }");
            latestSendTime = result.nextCursor ?? (result.latestMessage != null ? result.latestMessage!.sendTime! : latestSendTime);

            int num = 0;
            for(SquareChatMsgModel element in result.messages!) {
              if (!MeModel().isMe(element.playerId) || element.messageType == MessageType.system) continue;

              for(var sendingMsg in currentState.sendingMessages!) {
                if((sendingMsg as SquareChatMsgModel).receivedTime == element.receivedTime) {
                  // element.updateState(sendingMsg);
                  ChatMessageManager().changeLinkMessage(sendingMsg.messageManagerKey!, element.messageManagerKey!, newMessageModel: element);
                  currentState.sendingMessages!.remove(sendingMsg);
                  break;
                }
              }

            }

            if (result.messages!.isNotEmpty &&
                currentState.messages!.length > 0 &&
                currentState.messages?.first.sendTime != result.latestMessage!.sendTime
                // && result.latestMessage!.sender != MeModel().contact!.player
            ) {
              result.latestMessage!.hasAnimation = true;
            }

            _addAllListToSet(currentState.messages, result.messages!);

            Set<String> newAiSayingMessageIds = result.aiMessages?.keys.toSet() ?? {};
            Set<String> doneMessageIds = aiSayingMessageMap.keys.toSet().difference(newAiSayingMessageIds);
            for(var element in doneMessageIds) {
              SquareChatMsgModel msgModel = aiSayingMessageMap[element]!;

              GetSquareMessageCommand command = GetSquareMessageCommand(_model.squareId, msgModel.channelId!, msgModel.sender!.playerId, msgModel.sendTime!);
              if(await DataService().request(command)) {
                if(command.message != null) {
                  msgModel = command.message!;

                  aiSayingMessageMap[msgModel.messageId] = msgModel;
                  MessageModel? messageModel = currentState.messages!.lookup(msgModel);
                  messageModel?.messageBody = msgModel.messageBody;
                  messageModel?.status = msgModel.status;
                }
              }
            }

            if(result.aiMessages?.isNotEmpty == true) {
              for (var element in currentState.messages!) {
                element.status = MessageStatus.normal;
                if (result.aiMessages?.containsKey(element.messageId) == true) {
                  element.status = MessageStatus.aiSaying;
                  element.messageBody = result.aiMessages?[element.messageId]?.messageBody;
                }

              }
            }

            aiSayingMessageMap = result.aiMessages ?? {};

            return emit(currentState.copyWith(messages: currentState.messages, hasBottomReachedMax: hasBottomReachedMax));
          } else {
            GetSquareMessagesCommand? result = await SquareManager().fetchMessages(_model, _channelId, oldestSendTime, limit, setReadTime: false, backward: true);
            if (result == null || result.status != HttpStatus.ok) return emit(makeError(currentState));
            if(result.messages?.isEmpty == true && !(result.isAiSaying == true) && aiSayingMessageMap.isEmpty == true)
              return;

            bool hasTopReachedMax = result.nextCursor == null;

            oldestSendTime = result.nextCursor ??
                (result.oldestMessage != null ? result.oldestMessage!.sendTime! : oldestSendTime);

            _addAllListToSet(currentState.messages, result.messages!);

            Set<String> newAiSayingMessageIds = result.aiMessages?.keys.toSet() ?? {};
            Set<String> doneMessageIds = aiSayingMessageMap.keys.toSet().difference(newAiSayingMessageIds);

            for(var element in doneMessageIds) {
              SquareChatMsgModel msgModel = aiSayingMessageMap[element]!;

              GetSquareMessageCommand command = GetSquareMessageCommand(_model.squareId, msgModel.channelId!, msgModel.sender!.playerId, msgModel.sendTime!);
              if(await DataService().request(command)) {
                if(command.message != null) {
                  msgModel = command.message!;

                  MessageModel? messageModel = currentState.messages!.lookup(msgModel);
                  messageModel?.messageBody = msgModel.messageBody;
                  messageModel?.status = msgModel.status;
                }
              }
            }


            if(result.aiMessages?.isNotEmpty == true) {
              for (var element in currentState.messages!) {
                element.status = MessageStatus.normal;
                if (result.aiMessages?.containsKey(element.messageId) == true) {
                  element.status = MessageStatus.aiSaying;
                  element.messageBody = result.aiMessages?[element.messageId]?.messageBody;
                }
              }
            }

            aiSayingMessageMap = result.aiMessages ?? {};

            return emit(currentState.copyWith(messages: currentState.messages, hasTopReachedMax: hasTopReachedMax));
          }
        }
      } catch (e, stacktrace) {
        LogWidget.error("MessageError $e $stacktrace");
        return emit(makeError(currentState));
      }
    });
    on<PauseMessage>((event, emit) async {
      pauseFetching = event.pause;
    });
    on<SendTextMessage>((event, emit) async {
      late SquareChatMsgModel messageModel;
      String? firstUrl = ExtractUrlUtil.getFirstUrl(event.text);

      messageModel = SquareChatMsgModel(
          squareId: _model.squareId,
          channelId: _channelId,
          // contentId: firstUrl,
          fullContentUrl: firstUrl == null ? null : json.encode({'link': firstUrl}),
          regTime: DateTime.now().millisecondsSinceEpoch,
          sender: MeModel().contact!.player,
          messageBody: event.text,
          messageType: firstUrl == null ? MessageType.text : MessageType.link,
          status: MessageStatus.normal);


      if (messageModel.isInvalid()) {
        LogWidget.debug("SendMessage has invalid messageModel");
        return;
      }

      var result = await SquareManager().sayMessage(messageModel, this, _changeKeyboardTypeBloc);

      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          messageModel.hasAnimation = true;

          currentState.sendingMessages!.add(messageModel);
          currentState.messages!.add(SquareChatMsgModel.dateSystemMessage(_model.squareId, _channelId, sendTime: messageModel.sendTime));

          return emit(currentState.copyWith(
              messages: currentState.messages, sendingMessages: currentState.sendingMessages, reload: true,
              aiLimitReached: result.key == MessageStatus.aiLimitReached ? result.value as AiLimitReachedInfo? : null));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(makeError(state));
      }
    });

    on<RetrySendMessage>((event, emit) async {
      SquareChatMsgModel newMessage = SquareChatMsgModel.copyWithSendTime(event.messageModel as SquareChatMsgModel, DateTime.now().millisecondsSinceEpoch);
      if(!WebsocketDao().isOpen() && !await WebsocketDao().waitUntilConnect(2000)) {
        event.func.call();
        return;
      }

      await SquareManager().sayMessage(newMessage, this, _changeKeyboardTypeBloc);

      event.func.call();
      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;
          if (currentState.messages!.first != event.messageModel) {
            newMessage.hasAnimation = true;
          }

          // add new message
          currentState.sendingMessages!.add(newMessage);
          // remove old message
          currentState.sendingMessages!.remove(event.messageModel);
          currentState.messages!.remove(event.messageModel);

          currentState.messages!.add(SquareChatMsgModel.dateSystemMessage(_model.squareId, _channelId,
              sendTime: event.messageModel!.sendTime));

          emit(currentState.copyWith(sendingMessages: currentState.sendingMessages, messages: currentState.messages));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(makeError(state));
      }
    });

    on<SendFailedMessage>((event, emit) {
      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          currentState.messages!.add(event.messageModel);
          currentState.sendingMessages!.remove(event.messageModel);

          emit(currentState.copyWith(messages: currentState.messages, sendingMessages: currentState.sendingMessages));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(makeError(state));
      }
    });

    on<SendEmoticonMessage>((event, emit) async {
      SquareChatMsgModel _messageModel = SquareChatMsgModel(
        squareId: _model.squareId,
        channelId: _channelId,
        sender: MeModel().contact!.player,
        messageType: MessageType.emoticon,
        contentId: event.emoticonId,
        messageBody: event.withText,
        status: MessageStatus.normal,
      );

      await SquareManager().sayMessage(_messageModel, this, _changeKeyboardTypeBloc);

      try {
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;

          _messageModel.hasAnimation = true;
          currentState.messages!.add(SquareChatMsgModel.dateSystemMessage(_model.squareId, _channelId, sendTime: _messageModel.sendTime));
          currentState.sendingMessages!.add(_messageModel);

          emit(currentState.copyWith(messages: currentState.messages, sendingMessages: currentState.sendingMessages));
          return;
        }
      } catch (e, stacktrace) {
        LogWidget.debug("MessageError $e $stacktrace");
        emit(makeError(state));
      }
    });

    on<SendImageMessage>((event, emit) async {

      //multi
      if(event.images != null) {
        for(XFile image in event.images!) {
          await getStateFromSendImage(state, image.mimeType!, await image.readAsBytes()).then((value) => emit(value));
        }
      } else {
        emit(await getStateFromSendImage(state, event.mimeType!, event.bytes!));
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

    on<InitializeMessage>((event, emit) {
      emit(MessageLoaded.empty());
    });

    on<ReloadMessage>((event, emit) {
      if (state is MessageLoaded) {
        final currentState = state as MessageLoaded;
        emit(currentState.copyWith(messages: currentState.messages, reload: true));
      }
    });
  }

  @override
  void onEvent(MessageBlocEvent event) {
    super.onEvent(event);
    // LogWidget.debug("ChatMessageBloc event:$event state:$state");
  }

  void _addAllListToSet(SplayTreeSet<MessageModel>? sourceSet, List<MessageModel> targetList) {
    targetList.forEach((target) {
      MessageModel? source = sourceSet!.lookup(target);
      if (source != null) {
        target.hasAnimation = source.hasAnimation;
        target.status = source.status;
        // 이미 존재하면, state는 기존걸 사용하고 객체 교체 => 애니메이션의 초기화가 안일어나게함.
        // target.updateState(source);
        sourceSet.remove(source);
        sourceSet.add(target);
      } else {
        sourceSet.add(target);
      }
    });
  }

  static Future<void> imageUploadToServer(
      SquareChatMsgModel messageModel, Uint8List thumbData, Uint8List originBytes, String mimeType) async {
    UploadSquareChatImageCommand fullCommand = UploadSquareChatImageCommand(
        squareId: messageModel.squareId!,
        channelId: messageModel.channelId!,
        image: originBytes,
        thImage: thumbData,
        mimeType: mimeType);

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
    if (img.width < thumbnailMaxWidth && img.height < thumbnailMaxHeight) {
      resizedImg = img;
    } else if (img.width < thumbnailMaxWidth) {
      resizedImg = image.copyResize(img,
          height: min(img.height, thumbnailMaxHeight), interpolation: image.Interpolation.average);
    } else if (img.height < thumbnailMaxHeight) {
      resizedImg =
          image.copyResize(img, width: min(img.width, thumbnailMaxWidth), interpolation: image.Interpolation.average);
    } else {
      if (img.width > img.height) {
        resizedImg = image.copyResize(img, width: thumbnailMaxWidth, interpolation: image.Interpolation.average);
      } else {
        resizedImg = image.copyResize(img, height: thumbnailMaxHeight, interpolation: image.Interpolation.average);
      }
    }
    return Uint8List.fromList(image.encodePng(resizedImg));
  }

  void addSeenHereSystemMessage(
      List<MessageModel> afterMessages, SplayTreeSet<MessageModel>? messages, int lastReadTime) {
    if (afterMessages.isNotEmpty) {
      SquareChatMsgModel messageModel = SquareChatMsgModel(
        squareId: _model.squareId,
        channelId: _channelId,
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

  Future<MessageBlocState> getStateFromSendImage(MessageBlocState currentState, String mimeType, Uint8List bytes) async {
    SquareChatMsgModel? messageModel;

    if (mimeType.contains("image/")) {
      late Uint8List? thumbData;
      /*try {
        thumbData = await ImageUtil.resizeImageWeb(bytes, mimeType);
      } catch(e) {
        LogWidget.debug("getThumbBytes error :$e");
        thumbData = bytes;
      }*/
      thumbData = bytes;


      messageModel = SquareChatMsgModel(
        squareId: _model.squareId,
        channelId: _channelId,
        sender: MeModel().contact!.player,
        messageType: MessageType.image,
        messageBody: base64Encode(bytes),
      );

      await imageUploadToServer(messageModel, thumbData!, bytes, mimeType);

    } else {
      return makeError(currentState);
    }

    await SquareManager().sayMessage(messageModel, this, _changeKeyboardTypeBloc);

    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;

      messageModel.hasAnimation = true;

      currentState.sendingMessages!.add(messageModel);
      currentState.messages!.add(SquareChatMsgModel.dateSystemMessage(_model.squareId, _channelId, sendTime: messageModel.sendTime));

      return currentState.copyWith(messages: currentState.messages, sendingMessages: currentState.sendingMessages);
    }

    return makeError(currentState);
  }
}
