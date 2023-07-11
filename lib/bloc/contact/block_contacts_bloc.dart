import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/contact/recent_search_contact_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/room_manager.dart';

import 'search_contacts_bloc.dart';

part 'block_contacts_bloc_event.dart';
part 'block_contacts_bloc_state.dart';

class BlockedContactsBloc extends Bloc<BlockContactsBlocEvent, BlockContactsBlocState> {
  BlockedContactsBloc() : super(BlockContactsInitial()) {

    final int limit = 30;

    on<BlockContactEvent>((event, emit) async {

      if(await ContactManager().blockContact(event.playerId, event.contactModel.playerId)) {

        event.contactModel.friendTime = null;
        event.contactModel.relationshipStatus = RelationshipStatus.blocked;

        if(RoomManager().currentChatRoom?.roomId == event.contactModel.twinRoomId) {
          RoomManager().currentChatRoom?.isKnown = false;
          RoomManager().currentChatRoom?.blockedTime = DateTime.now().millisecondsSinceEpoch;
          RoomManager().blockedRoomIdList.add(RoomManager().currentChatRoom!.roomId!);
          RoomManager().activeRoomIdList.remove(RoomManager().currentChatRoom!.roomId!);
        }

        BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReloadBlockedRoomsEvent());
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReloadArchivedRoomsEvent());
        BlocManager.getBloc<RecentSearchContactBloc>()?.add(ReloadEvent());
        BlocManager.getBloc<SearchContactsBloc>()?.add(ReloadSearchContactsEvent());
        BlocManager.getBloc<ContactsBloc>()?.add(ReloadContactsEvent());
        ContactManager().onlinePlayerStatusMap.value[event.contactModel.playerId] = false;

        event.successFunc?.call();
      } else {
        emit(BlockContactsError());
      }

      if(state is BlockContactsLoaded) {
        final currentState = state as BlockContactsLoaded;

        currentState.blockedPlayerMap.putIfAbsent(event.contactModel.playerId, () => event.contactModel);

        emit(currentState.copyWith(blockedPlayerMap: currentState.blockedPlayerMap, totalCount: currentState.totalCount! +1, reload: true));
      }

      return;
    });

    on<UnblockContactEvent>((event, emit) async {

      if(await ContactManager().unblockContact(event.playerId, event.targetPlayerId)) {

        BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReloadBlockedRoomsEvent());
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReloadArchivedRoomsEvent());
        BlocManager.getBloc<RecentSearchContactBloc>()?.add(ReloadEvent());
        BlocManager.getBloc<SearchContactsBloc>()?.add(ReloadSearchContactsEvent());
        BlocManager.getBloc<ChatPageBloc>()?.add(Update());

        event.successFunc?.call();
      } else {
        emit(BlockContactsError());
        return ;
      }

      if(state is BlockContactsLoaded) {
        final currentState = state as BlockContactsLoaded;

        currentState.blockedPlayerMap.remove(event.targetPlayerId);
        emit(currentState.copyWith(blockedPlayerMap: currentState.blockedPlayerMap, totalCount: currentState.totalCount! -1, reload: true));
      }

      return;
    });

    on<UpdateBlockedContactEvent>((event, emit) async {
      if(state is BlockContactsLoaded) {
        final currentState = state as BlockContactsLoaded;

        currentState.blockedPlayerMap[event.playerId]?.updateTargetMember(event.nickname, profileImgUrl: event.profileImgUrl);
        ContactModelPool().playerMap[event.playerId]?.updateTargetMember(event.nickname, profileImgUrl: event.profileImgUrl);

        emit(currentState.copyWith(reload: true));
      }
    });

    on<LoadBlockedContactsEvent>((event, emit) async {
      if(state is BlockContactsInitial) {

        Map<String, dynamic>? result = await ContactManager().loadBlockContactsFromServer(limit, keyword: event.keyword, withCount: true);
        emit(BlockContactsLoading());

        if (result == null) {
          emit(BlockContactsError());
          return;
        }

        Map<String, ContactModel> newContactMap = result['contactMap'];
        String? cursor = result['cursor'];

        emit(BlockContactsLoaded(blockedPlayerMap: newContactMap, totalCount: result['totalCount'], cursor: cursor, hasReachedMax: cursor == null, keyword: event.keyword));
      } else if(state is BlockContactsLoaded) {
        final currentState = state as BlockContactsLoaded;

        if(currentState.keyword == event.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await ContactManager().loadBlockContactsFromServer(limit, cursor: currentState.cursor, keyword: currentState.keyword);
          if (result == null) {
            emit(BlockContactsError());
            return;
          }

          Map<String, ContactModel> newContactMap = result['contactMap'];
          String? cursor = result['cursor'];

          currentState.blockedPlayerMap.addAll(newContactMap);
          emit(currentState.copyWith(blockedPlayerMap: currentState.blockedPlayerMap, cursor: cursor, hasReachedMax: cursor == null, reload: true));
          return;
        }

        Map<String, dynamic>? result = await ContactManager().loadBlockContactsFromServer(limit, keyword: event.keyword);

        if (result == null) {
          emit(BlockContactsError());
          return;
        }

        Map<String, ContactModel> newContactMap = result['contactMap'];
        String? cursor = result['cursor'];

        emit(BlockContactsLoaded(blockedPlayerMap: newContactMap, totalCount: currentState.totalCount, cursor: result['cursor'], hasReachedMax: cursor == null, keyword: event.keyword));
        return;
      }
    });

    on<InitBlockedContactsEvent>((event, emit) async {
      emit(BlockContactsInitial());
    });
  }

  bool _hasReachedMax(BlockContactsBlocState state) => state is BlockContactsLoaded && state.hasReachedMax!;

  @override
  void onEvent(BlockContactsBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("BlockPlayerBloc event:$event state:$state");
  }
}
