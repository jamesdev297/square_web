import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/bloc/contact/recent_search_contact_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/room_manager.dart';

import 'search_contacts_bloc.dart';

part 'contacts_bloc_event.dart';
part 'contacts_bloc_state.dart';

class ContactsBloc extends Bloc<ContactsBlocEvent, ContactsBlocState> {
  ContactsBloc() : super(ContactsInitial()) {

    final int limit = 30;

    on<AddContactEvent>((event, emit) async {

      ContactModel? contact = await ContactManager().addContact(event.playerId, event.targetPlayerId);
      if (contact != null) {

        if(contact.twinRoomId == RoomManager().currentChatRoom?.roomId) {
          RoomManager().globalRoomMap[RoomManager().currentChatRoom?.roomId]["known"] = true;
          RoomManager().currentChatRoom?.isKnown = true;
        }
        BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReloadBlockedRoomsEvent());
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReloadArchivedRoomsEvent());
        BlocManager.getBloc<RecentSearchContactBloc>()?.add(ReloadEvent());
        BlocManager.getBloc<SearchContactsBloc>()?.add(ReloadSearchContactsEvent(addContact: contact));
        BlocManager.getBloc<ChatPageBloc>()?.add(Update());

        if(event.successFunc != null)
          event.successFunc!(contact)?.call();
      }

      if(state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;

        if(contact != null)
          currentState.contactMap.putIfAbsent(contact.playerId, () => contact);
        emit(currentState.copyWith(contactMap: currentState.contactMap, totalCount: currentState.totalCount! +1, reload: true));
      }

    });

    on<RemoveContactEvent>((event, emit) async {
      if (await ContactManager().removeContact(event.playerId, event.targetPlayerId)) {

        if(RoomManager().getTwinRoomId(event.playerId, event.targetPlayerId) == RoomManager().currentChatRoom?.roomId) {
          RoomManager().globalRoomMap[RoomManager().currentChatRoom?.roomId]["known"] = false;
          RoomManager().currentChatRoom?.isKnown = false;
        }
        BlocManager.getBloc<RoomsBloc>()?.add(ReloadRoomsEvent());
        BlocManager.getBloc<BlockedRoomsBloc>()?.add(ReloadBlockedRoomsEvent());
        BlocManager.getBloc<ArchivedRoomsBloc>()?.add(ReloadArchivedRoomsEvent());
        BlocManager.getBloc<RecentSearchContactBloc>()?.add(ReloadEvent());
        BlocManager.getBloc<SearchContactsBloc>()?.add(ReloadSearchContactsEvent(removeContactPlayerId: event.targetPlayerId));

        event.successFunc?.call();
      }

      if(state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;

        currentState.contactMap.remove(event.targetPlayerId);
        emit(currentState.copyWith(contactMap: currentState.contactMap, totalCount: currentState.totalCount! -1, reload: true));
      }
    });

    on<LoadContactsEvent>((event, emit) async {
      if(state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;

        /*if(currentState.keyword == event.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await ContactManager().loadContactsFromServer(limit, cursor: currentState.cursor, keyword: currentState.keyword);
          if (result == null) {
            emit(ContactsError());
            return;
          }

          Map<String, ContactModel> newContactMap = result['contactMap'];
          String? cursor = result['cursor'];

          currentState.contactMap.addAll(newContactMap);
          emit(currentState.copyWith(contactMap: currentState.contactMap, cursor: result['cursor'], hasReachedMax: cursor == null, reload: true));
          return;
        }*/

       /* Map<String, dynamic>? result = await ContactManager().loadContactsFromServer(limit, keyword: event.keyword);
        emit(ContactsLoading());

        if (result == null) {
          emit(ContactsError());
          return;
        }*/


        Map<String, ContactModel> newContactMap = {};
        ContactManager().globalPlayerMap.forEach((key, value) {
          if((value["searchName"] as String).contains(event.keyword ?? "")) {
            newContactMap.putIfAbsent(key, () => ContactModel.fromMap(value));
          }
        });

        emit(ContactsLoaded(contactMap: newContactMap, totalCount: currentState.totalCount, cursor: null, hasReachedMax: true, keyword: event.keyword));
        return;
      }
    });

    on<UpdateContactEvent>((event, emit) async {
      if(state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;

        currentState.contactMap[event.playerId]?.updateTargetMember(event.nickname, profileImgUrl: event.profileImgUrl);
        ContactModelPool().playerMap[event.playerId]?.updateTargetMember(event.nickname, profileImgUrl: event.profileImgUrl);

        emit(currentState.copyWith(reload: true));
      }
    });

    on<UpdateOnlineContactEvent>((event, emit) async {
      if(state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;

        ContactManager().onlinePlayerStatusMap.value[event.playerId] = event.online;

        emit(currentState.copyWith(reload: true));
      }
    });

    on<ReloadContactsEvent>((event, emit) async {
      if(state is ContactsLoaded) {
        Map<String, dynamic>? result = await ContactManager().loadContactsFromServer(limit, withCount: true);

        if (result == null) {
          emit(ContactsError());
          return;
        }

        Map<String, ContactModel> newContactMap = result['contactMap'];
        String? cursor = result['cursor'];

        emit(ContactsLoaded(contactMap: newContactMap, totalCount: result['totalCount'], cursor: result['cursor'], hasReachedMax: cursor == null));
      }
    });

    on<InitLoadContactsEvent>((event, emit) async {
      emit(ContactsLoading());

      Map<String, dynamic>? result = await ContactManager().loadContactsFromServer(limit, keyword: event.keyword, withCount: true);

      if (result == null) {
        emit(ContactsError());
        return;
      }

      Map<String, ContactModel> newContactMap = result['contactMap'];
      String? cursor = result['cursor'];

      emit(ContactsLoaded(contactMap: newContactMap, totalCount: result['totalCount'], cursor: result['cursor'], hasReachedMax: cursor == null, keyword: event.keyword));
    });
  }

  bool _hasReachedMax(ContactsBlocState state) => state is ContactsLoaded && state.hasReachedMax!;

  @override
  void onEvent(ContactsBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("ContactsBloc event:$event state:$state");
  }
}
