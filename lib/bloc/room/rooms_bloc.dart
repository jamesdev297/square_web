import 'package:bloc/bloc.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/room/rooms_bloc_state.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/room_manager.dart';


class RoomsBloc extends Bloc<RoomsBlocEvent, RoomsBlocState> {
  RoomsBloc() : super(RoomsUninitialized()) {

    final int limit = 30;

    on<RemoveTempRoomsEvent>((event, emit) {
      final currentState = state;
      if (currentState is RoomsLoaded) {
        removeTempRooms(currentState.roomMap);
        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<OpenRoomEvent>((event, emit) async {

      String roomId = event.roomId;

      RoomModel? room = await RoomManager().getTwinRoom(roomId);

      if(room == null) {
        room = await getTempRoom(roomId);
      }

      if (state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;
        room.isUnread = false;

        removeTempRooms(currentState.roomMap);

        currentState.roomMap[room.roomId!] = room;
        HomeNavigator.push(RoutePaths.chat.open, arguments: room, moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<OpenRoomByLinkEvent>((event, emit) async {
      Map<String, dynamic>? result = await RoomManager().loadRoomsFromServer(limit, withCount: true);
      if (result == null) {
        emit(RoomsError());
        return;
      }

      int? cursor = result['cursor'];

      Map<String, RoomModel> roomMap = result['room'];
      late String roomId;
      if(event.room != null) {
        roomId = event.room!.roomId!;
        roomMap[roomId] =event.room!;
      } else {
        RoomModel roomModel = await getTempRoom(event.roomId!);
        roomId = event.roomId!;
        roomMap[roomId] = roomModel;
      }

      RoomManager().selectedRoomFolder.value = RoomFolder.chat;

      HomeNavigator.push(RoutePaths.chat.open, arguments: roomMap[roomId], moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

      emit(RoomsLoaded(roomMap: roomMap, totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null));
    });

    on<ReceivedRoomMessageOnlinePush>((event, emit) async {
      try {
        LogWidget.debug("ReceivedRoomMessageOnlinePush ${event.message.roomId}");

        if (state is RoomsLoaded) {
          final currentState = state as RoomsLoaded;

          if(event.isInRoom == true) {
            RoomModel room = currentState.roomMap[event.message.roomId!]!;

            if(!(room.isAiChat == true)) {
              if (event.message.messageSender == MessageSender.friend)
                RoomManager().currentMessageBloc?.add(TypingMessage(isTyping: false));

              MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(room.roomId!, room.me?.lastReadTime ?? 0, setReadTime: true);
              room.updateLastMsg(lastMessage);
            } else {
              RoomManager().currentMessageBloc?.add(AiMessageReceivedMessage(event.message));

              if(event.message.status == MessageStatus.normal) {
                MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(room.roomId!, event.message.sendTime ?? 0, setReadTime: true);
                room.updateLastMsg(lastMessage);
              }
            }

          } else {
            RoomModel? room;
            if (currentState.roomMap.containsKey(event.message.roomId)) {
              room = currentState.roomMap[event.message.roomId];
            } else {
              room = await RoomManager().getTwinRoom(event.message.roomId!);
            }

            if (room == null)
              return;

            room.updateLastMsg(event.message, isUnread: true);
            BlocManager.getBloc<BlueDotBloc>()!.add(AddNewKey(naviCode: TabCode.chat, key: BlueDotKey.unreadRoom));

            int totalCount = currentState.totalCount ?? 0;
            if(!currentState.roomMap.containsKey(room.roomId!)) {
              totalCount += 1;
            }

            currentState.roomMap[room.roomId!] = room;

            emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
            return;
          }

          emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("RoomError $e $stacktrace");
        emit(RoomsError());
      }
    });

    on<UpdateLastMsgRoom>((event, emit) {
      if (state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;

        RoomModel? room = currentState.roomMap[event.roomId];
        room?.updateLastMsg(event.message);
        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<UpdateRoomMembers>((event, emit) async {
      if (state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;

        List<RoomMemberModel>? roomMembers = await RoomManager().getTwinRoomMembers(event.roomId);
        if(roomMembers == null)
          return;

        RoomModel? room = RoomManager().currentChatRoom;
        room?.members.clear();
        room?.members.addAll(roomMembers);

        RoomManager().currentMessageBloc?.add(ReloadMessage());
        
        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<UpdateTargetRoomMember>((event, emit) async {

      if(state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;
        currentState.roomMap[event.roomId]?.searchName = event.nickname;

        if(event.profileImgUrl != null) {
          currentState.roomMap[event.roomId]?.targetProfileImgUrl = event.profileImgUrl;
        }

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<AddRoom>((event, emit) async {

      if(event.moveFolder)
        RoomManager().selectedRoomFolder.value = RoomFolder.chat;

      if(state is RoomsUninitialized) {
        add(InitLoadRoomsEvent(MeModel().playerId!));
      } else if(state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.room.roomId!)) {
          totalCount += 1;
        }

        removeTempRooms(currentState.roomMap);
        currentState.roomMap[event.room.roomId!] = event.room;

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
      }
    });

    on<SayMessageRoom>((event, emit) async {

      MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(event.room.roomId!, event.room.me?.lastReadTime ?? 0, setReadTime: true);
      event.room.updateLastMsg(lastMessage);

      if(state is RoomsUninitialized) {
        add(InitLoadRoomsEvent(MeModel().playerId!));
      } else if(state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.room.roomId!)) {
          totalCount += 1;
        }

        currentState.roomMap[event.room.roomId!] = event.room;

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
      }
    });

    on<LoadRoomsEvent>((event, emit) async {
      if(state is RoomsLoaded) {
        final currentState = state as RoomsLoaded;

        Map<String, RoomModel> currentRoomMap = {};
        currentRoomMap = getCurrentRoom();
        currentState.roomMap.addAll(currentRoomMap);

        if(currentState.keyword == event.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await RoomManager().loadRoomsFromServer(limit, cursor: currentState.cursor, keyword: currentState.keyword);
          if (result == null) {
            emit(RoomsError());
            return;
          }

          currentState.roomMap.addAll(result['room']);
          int? cursor = result['cursor'];

          emit(currentState.copyWith(roomMap: currentState.roomMap, cursor: cursor, hasReachedMax: cursor == null, reload: true));
          return;
        }

        Map<String, dynamic>? result = await RoomManager().loadRoomsFromServer(limit, keyword: event.keyword);
        emit(RoomsLoading());

        if (result == null) {
          emit(RoomsError());
          return;
        }

        int? cursor = result['cursor'];

        currentRoomMap.addAll(result['room']);

        emit(RoomsLoaded(roomMap: currentRoomMap, totalCount: currentState.totalCount, cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
        return;
      }

    });

    on<ReloadRoomsEvent>((event, emit) async {
      if(state is RoomsLoaded) {
       /* Map<String, RoomModel> currentRoomMap = {};
        final currentState = state as RoomsLoaded;

        currentRoomMap = getCurrentRoom();

        Map<String, dynamic>? result = await RoomManager().loadRoomsFromServer(limit, withCount: true);

        if (result == null) {
          emit(RoomsError());
          return;
        }

        int? cursor = result['cursor'];
        currentRoomMap.addAll(result['room']);

        emit(RoomsLoaded(roomMap: currentRoomMap, totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null));*/
      }
    });

    on<InitLoadRoomsEvent>((event, emit) async {
      Map<String, RoomModel> currentRoomMap = {};

      if(state is RoomsLoaded) {
        return ;
        final currentState = state as RoomsLoaded;

        currentRoomMap = getCurrentRoom();
      }

      emit(RoomsLoading());

      Map<String, dynamic>? result = await RoomManager().loadRoomsFromServer(limit, keyword: event.keyword, withCount: true);

      if (result == null) {
        emit(RoomsError());
        return;
      }

      int? cursor = result['cursor'];
      currentRoomMap.addAll(result['room']);

      emit(RoomsLoaded(roomMap: currentRoomMap, totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
    });
  }

  void removeTempRooms(Map<String, RoomModel> roomMap) {
    roomMap.removeWhere((key, value) => value.status == "temp");
  }

  Map<String, RoomModel> getCurrentRoom() {
    RoomModel? currentChatRoom = RoomManager().currentChatRoom;
    if(currentChatRoom != null && (currentChatRoom.status == "temp" || (currentChatRoom.status == "active" && currentChatRoom.blockedTime == null))) {
      return { currentChatRoom.roomId! : currentChatRoom };
    }

    return {};
  }

  Future<RoomModel> getTempRoom(String roomId) async {
    GetPlayerProfileCommand command = GetPlayerProfileCommand(playerId: MeModel().playerId!, targetPlayerId: RoomModel.contactPlayerId(roomId: roomId));
    if (await DataService().request(command)) {
      LogWidget.debug("GetFriendProfileCommand success");
      ContactManager().updateContact(command.contactModel!.playerId, command.contactModel!.name, profileImgUrl: command.contactModel!.profileImgUrl);
      RoomManager().updateTargetRoomMember(command.contactModel!, command.contactModel!.name, profileImgUrl: command.contactModel!.profileImgUrl);
    } else {
      LogWidget.debug("GetFriendProfileCommand failed");
    }

    bool isAiChat = (command.contactModel!.blockchainNetType == ChainNetType.ai);
    return RoomModel.temp(roomId: roomId, searchName: command.contactModel!.smallerName, isAiChat: isAiChat, contacts: [ command.contactModel!, MeModel().contact! ], roomType: "twin", isKnown: command.contactModel!.friendTime != null);
  }

  bool _hasReachedMax(RoomsBlocState state) => state is RoomsLoaded && state.hasReachedMax!;

  @override
  void onEvent(RoomsBlocEvent event) {
    super.onEvent(event);
    LogWidget.debug("RoomsBloc event:$event state:$state");
  }
}
