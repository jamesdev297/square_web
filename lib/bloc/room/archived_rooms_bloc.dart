import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';

import 'rooms_bloc.dart';

part 'archived_rooms_bloc_event.dart';
part 'archived_rooms_bloc_state.dart';

class ArchivedRoomsBloc extends Bloc<ArchivedRoomsBlocEvent, ArchivedRoomsBlocState> {
  ArchivedRoomsBloc() : super(ArchivedRoomsUninitialized()) {
    final int limit = 30;

    on<OpenArchiveRoomEvent>((event, emit) async {

      String roomId = event.roomId;

      RoomModel? room = await RoomManager().getTwinRoom(roomId);

      if(room == null)
        return;

      if (state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        currentState.roomMap[room.roomId!] = room;
        HomeNavigator.push(RoutePaths.chat.open, arguments: room, moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<LoadArchivedRoomsEvent>((event, emit) async {
      if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        if(currentState.keyword == event.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await RoomManager().loadArchivedRoomsFromServer(limit, cursor: currentState.cursor, keyword: currentState.keyword);
          if (result == null) {
            emit(ArchivedRoomsError());
            return;
          }

          currentState.roomMap.addAll(result['room']);
          int? cursor = result['cursor'];

          emit(currentState.copyWith(roomMap: currentState.roomMap, cursor: cursor, hasReachedMax: cursor == null, reload: true));
          return;
        }

        Map<String, dynamic>? result = await RoomManager().loadArchivedRoomsFromServer(limit, keyword: event.keyword);
        emit(ArchivedRoomsLoading());

        if (result == null) {
          emit(ArchivedRoomsError());
          return;
        }

        int? cursor = result['cursor'];

        emit(ArchivedRoomsLoaded(roomMap: result['room'], totalCount: currentState.totalCount, cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
        return;
      }

    });

    on<ArchiveRoomEvent>((event, emit) async {
      if(await RoomManager().archiveRoom(event.roomModel.roomId!) == false) {
        emit(ArchivedRoomsError());
        return;
      }

      event.roomModel.status = "archived";
      BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());

      event.successFunc?.call();

      if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.roomModel.roomId!)) {
          totalCount += 1;
        }
        currentState.roomMap[event.roomModel.roomId!] = event.roomModel;

        emit(currentState.copyWith(roomMap: currentState.roomMap, totalCount: totalCount, reload: true));
      }

    });

    on<UnarchiveRoomEvent>((event, emit) async {
      if(await RoomManager().unarchiveRoom(event.roomId) == false) {
        emit(ArchivedRoomsError());
        return;
      }

      BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());

      event.successFunc?.call();
      BlocManager.getBloc<ChatPageBloc>()?.add(Update());

      if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(currentState.roomMap.containsKey(event.roomId)) {
          currentState.roomMap.remove(event.roomId);
          totalCount -= 1;
        }

        emit(currentState.copyWith(roomMap: currentState.roomMap, totalCount: totalCount, reload: true));
      }
    });

    on<UpdateTargetArchivedRoomMember>((event, emit) async {

      if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;
        currentState.roomMap[event.roomId]?.searchName = event.nickname;

        if(event.profileImgUrl != null) {
          currentState.roomMap[event.roomId]?.targetProfileImgUrl = event.profileImgUrl;
        }

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<ReceivedArchivedRoomMessageOnlinePush>((event, emit) async {
      try {
        LogWidget.debug("ReceivedArchivedRoomMessageOnlinePush ${event.message.roomId}");

        if (state is ArchivedRoomsLoaded) {
          final currentState = state as ArchivedRoomsLoaded;

          if(event.isInRoom == true) {
            RoomModel room = currentState.roomMap[event.message.roomId!]!;

            if(!(room.isAiChat == true)) {
              MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(room.roomId!, room.me?.lastReadTime ?? 0, setReadTime: true);
              room.updateLastMsg(lastMessage);
            } else {
              RoomManager().currentMessageBloc?.add(AiMessageReceivedMessage(event.message));

              if(event.message.status == MessageStatus.normal) {
                MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(room.roomId!, room.me?.lastReadTime ?? 0, setReadTime: true);
                room.updateLastMsg(lastMessage);
              }
            }

          } else {
            RoomModel room = currentState.roomMap[event.message.roomId]!;
            room.updateLastMsg(event.message, isUnread: true);
            BlocManager.getBloc<BlueDotBloc>()!.add(AddNewKey(naviCode: TabCode.chat, key: BlueDotKey.unreadArchivedRoom));
          }

          emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("ArchivedRoomsError $e $stacktrace");
        emit(ArchivedRoomsError());
      }
    });

    on<AddArchivedRoom>((event, emit) async {

      if(event.moveFolder)
        RoomManager().selectedRoomFolder.value = RoomFolder.archives;

      if(state is ArchivedRoomsUninitialized) {
        add(InitLoadArchivedRoomsEvent(MeModel().playerId!));
      } else if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.roomModel.roomId!)) {
          totalCount += 1;
        }

        currentState.roomMap[event.roomModel.roomId!] = event.roomModel;

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
      }
    });

    on<SayMessageArchivedRoom>((event, emit) async {

      MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(event.room.roomId!, event.room.me?.lastReadTime ?? 0, setReadTime: true);
      event.room.updateLastMsg(lastMessage);

      if(state is ArchivedRoomsUninitialized) {
        add(InitLoadArchivedRoomsEvent(MeModel().playerId!));;
      } else if(state is ArchivedRoomsLoaded) {
        final currentState = state as ArchivedRoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.room.roomId!)) {
          totalCount += 1;
        }

        currentState.roomMap[event.room.roomId!] = event.room;

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
      }
    });

    on<ReloadArchivedRoomsEvent>((event, emit) async {
      if(state is ArchivedRoomsLoaded) {
        Map<String, dynamic>? result = await RoomManager().loadArchivedRoomsFromServer(limit, withCount: true);

        if (result == null) {
          emit(ArchivedRoomsError());
          return;
        }

        int? cursor = result['cursor'];

        emit(ArchivedRoomsLoaded(roomMap: result['room'], totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null));
      }
    });

    on<OpenArchivedRoomByLinkEvent>((event, emit) async {
      Map<String, dynamic>? result = await RoomManager().loadArchivedRoomsFromServer(limit, withCount: true);
      if (result == null) {
        emit(ArchivedRoomsError());
        return;
      }

      int? cursor = result['cursor'];

      Map<String, RoomModel> roomMap = result['room'];
      roomMap.putIfAbsent(event.room.roomId!, () => event.room);

      RoomManager().selectedRoomFolder.value = RoomFolder.archives;
      HomeNavigator.push(RoutePaths.chat.open, arguments: event.room, moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

      emit(ArchivedRoomsLoaded(roomMap: roomMap, totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null));
    });

    on<InitLoadArchivedRoomsEvent>((event, emit) async {
      emit(ArchivedRoomsLoading());

      Map<String, dynamic>? result = await RoomManager().loadArchivedRoomsFromServer(limit, keyword: event.keyword, withCount: true);

      if (result == null) {
        emit(ArchivedRoomsError());
        return;
      }

      int? cursor = result['cursor'];

      emit(ArchivedRoomsLoaded(roomMap: result['room'], totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
    });
  }

  bool _hasReachedMax(ArchivedRoomsBlocState state) => state is ArchivedRoomsLoaded && state.hasReachedMax!;

  @override
  void onEvent(ArchivedRoomsBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("ArchivedRoomsBloc event:$event state:$state");
  }
}
