import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'rooms_bloc_event.dart';

part 'blocked_rooms_bloc_event.dart';
part 'blocked_rooms_bloc_state.dart';

class BlockedRoomsBloc extends Bloc<BlockedRoomsBlocEvent, BlockedRoomsBlocState> {
  BlockedRoomsBloc() : super(BlockedRoomsUninitialized()) {
    final int limit = 30;

    on<OpenBlockedRoomEvent>((event, emit) async {

      String roomId = event.roomId;

      RoomModel? room = await RoomManager().getTwinRoom(roomId);

      if(room == null)
        return;

      if (state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;

        currentState.roomMap[room.roomId!] = room;
        HomeNavigator.push(RoutePaths.chat.open, arguments: room, moveTab: TabCode.chat, popAction: (_) => RoomManager().popActionRoom());

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<UpdateLastMsgBlockedRoom>((event, emit) {
      if (state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;

        RoomModel room = currentState.roomMap[event.roomId]!;
        room.updateLastMsg(event.message);
        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<UnblockRoom>((event, emit) async {
      if(await RoomManager().unblockRoom(event.roomId) == false) {
        emit(BlockedRoomsError());
        return;
      }

      BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());
      BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReloadArchivedRoomsEvent());

      event.successFunc?.call();

      if(state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;

        if(currentState.roomMap.containsKey(event.roomId)) {
          currentState.roomMap.remove(event.roomId);
        }

        emit(currentState.copyWith(roomMap: currentState.roomMap, totalCount: currentState.totalCount! -1, reload: true));
      }
    });

    on<ReceivedBlockedRoomMessageOnlinePush>((event, emit) async {
      try {
        LogWidget.debug("ReceivedBlockedRoomMessageOnlinePush ${event.message.roomId}");

        if (state is BlockedRoomsLoaded) {
          final currentState = state as BlockedRoomsLoaded;

          if(event.isInRoom == true) {
            RoomModel room = currentState.roomMap[event.message.roomId!]!;

            MessageModel? lastMessage = await RoomManager().loadAfterLastMsgTimeFromServer(room.roomId!, room.isBlocked == true ? event.message.sendTime : room.me?.lastReadTime ?? 0, setReadTime: room.isBlocked == true ? false : true);
            room.updateLastMsg(lastMessage);
          } else {
            RoomModel room = currentState.roomMap[event.message.roomId]!;
            room.updateLastMsg(event.message);
          }

          emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
        }
      } catch (e, stacktrace) {
        LogWidget.debug("BlockedRoomError $e $stacktrace");
        emit(BlockedRoomsError());
      }
    });

    on<AddBlockedRoom>((event, emit) async {

      if(event.moveFolder)
        RoomManager().selectedRoomFolder.value = RoomFolder.block;

      if(state is BlockedRoomsUninitialized) {

        add(InitLoadBlockedRoomsEvent(MeModel().playerId!));
      } else if(state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;

        int totalCount = currentState.totalCount ?? 0;
        if(!currentState.roomMap.containsKey(event.roomModel.roomId!)) {
          totalCount += 1;
        }

        currentState.roomMap[event.roomModel.roomId!] = event.roomModel;

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true, totalCount: totalCount));
      }
    });

    on<LoadBlockedRoomsEvent>((event, emit) async {
      if(state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;

        if(currentState.keyword == event.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await RoomManager().loadBlockedRoomsFromServer(limit, cursor: currentState.cursor, keyword: currentState.keyword);
          if (result == null) {
            emit(BlockedRoomsError());
            return;
          }

          currentState.roomMap.addAll(result['room']);
          int? cursor = result['cursor'];

          emit(currentState.copyWith(roomMap: currentState.roomMap, cursor: cursor, hasReachedMax: cursor == null, reload: true));
          return;
        }

        Map<String, dynamic>? result = await RoomManager().loadBlockedRoomsFromServer(limit, keyword: event.keyword);
        emit(BlockedRoomsLoading());

        if (result == null) {
          emit(BlockedRoomsError());
          return;
        }

        int? cursor = result['cursor'];

        emit(BlockedRoomsLoaded(roomMap: result['room'], totalCount: currentState.totalCount, cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
        return;
      }

    });

    on<UpdateTargetBlockedRoomMember>((event, emit) async {

      if(state is BlockedRoomsLoaded) {
        final currentState = state as BlockedRoomsLoaded;
        currentState.roomMap[event.roomId]?.searchName = event.nickname;

        if(event.profileImgUrl != null) {
          currentState.roomMap[event.roomId]?.targetProfileImgUrl = event.profileImgUrl;
        }

        emit(currentState.copyWith(roomMap: currentState.roomMap, reload: true));
      }
    });

    on<ReloadBlockedRoomsEvent>((event, emit) async {
      if(state is BlockedRoomsLoaded) {
        Map<String, dynamic>? result = await RoomManager().loadBlockedRoomsFromServer(limit, withCount: true);

        if (result == null) {
          emit(BlockedRoomsError());
          return;
        }

        int? cursor = result['cursor'];

        emit(BlockedRoomsLoaded(roomMap: result['room'], totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null));
      }
    });

    on<InitLoadBlockedRoomsEvent>((event, emit) async {
      emit(BlockedRoomsLoading());
      Map<String, dynamic>? result = await RoomManager().loadBlockedRoomsFromServer(limit, keyword: event.keyword, withCount: true);

      if (result == null) {
        emit(BlockedRoomsError());
        return;
      }

      int? cursor = result['cursor'];

      emit(BlockedRoomsLoaded(roomMap: result['room'], totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
    });
  }

  bool _hasReachedMax(BlockedRoomsBlocState state) => state is BlockedRoomsLoaded && state.hasReachedMax!;

  @override
  void onEvent(BlockedRoomsBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("BlockedRoomsBloc event:$event state:$state");
  }
}
