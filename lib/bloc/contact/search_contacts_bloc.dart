
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/data_service.dart';

part 'search_contacts_bloc_event.dart';
part 'search_contacts_bloc_state.dart';

class SearchContactsBloc extends Bloc<SearchContactsBlocEvent, SearchContactsBlocState> {
  SearchContactsBloc() : super(SearchContactsInitial()) {
     on<SearchEvent>((event, emit) async {
       final currentState = state;
       if(currentState is SearchContactsInitial) {
         String keyword = event.keyword.trim();

         emit(await stateFromSearchEvent(keyword));
       } else if(currentState is SearchContactsLoaded) {
         String keyword = event.keyword.trim();
         if(keyword == currentState.keyword) {

           if(_hasReachedMax(state)) {
             return;
           }
           emit(await stateCopyWithFromSearchEvent(currentState, keyword));
         } else {
           emit(await stateFromSearchEvent(keyword));
         }
       }
    });

    on<InitSearchContactsEvent>((event, emit) async {
      emit(SearchContactsInitial());
    });

    on<ReloadSearchContactsEvent>((event, emit) async {
      final currentState = state;

      if(currentState is SearchContactsLoaded) {
        if(event.removeContactPlayerId != null) {
          currentState.contactMap[event.removeContactPlayerId]?.friendTime = null;
        }
        if(event.addContact != null) {
          currentState.contactMap[event.addContact!.playerId] = event.addContact!;
        }
        emit(currentState.copyWith(contactMap: currentState.contactMap, reload: true));
        // emit(currentState.copyWith(reload: true));
      }
    });
  }

  Future<SearchContactsBlocState> stateCopyWithFromSearchEvent(SearchContactsLoaded currentState, String keyword) async {
    Map<String, dynamic>? result = await searchContact(keyword, currentState.searchRelationship, relationshipCursor: currentState.relationshipCursor, playerCursor: currentState.playerCursor);
    if (result == null) {
      return SearchContactsError();
    }

    Map<String, ContactModel> newContactMap = result['contactMap'];
    String? cursor = result['cursorId'];

    currentState.contactMap.addAll(newContactMap);

    if(currentState.searchRelationship) {
      return currentState.copyWith(contactMap: currentState.contactMap, keyword: keyword, relationshipCursor: cursor, searchRelationship: cursor != null, reload: true);
    } else {
      return currentState.copyWith(contactMap: currentState.contactMap, keyword: keyword, playerCursor: cursor, hasReachedMax: cursor == null && result.length < 20, reload: true);
    }
  }
  
  Future<SearchContactsBlocState> stateFromSearchEvent(String keyword) async {
    if(keyword.length <= nicknameMaxLength) {
      Map<String, dynamic>? result = await searchContact(keyword, true);
      if (result == null) {
        return SearchContactsError();
      }

      Map<String, ContactModel> newContactMap = result['contactMap'];
      String? cursor = result['cursor'];

      return SearchContactsLoaded(contactMap: newContactMap, keyword: keyword, relationshipCursor: cursor, searchRelationship: cursor != null);
    }


    return SearchContactsLoaded(contactMap: {}, keyword: keyword, hasReachedMax: true);
  }

  bool _hasReachedMax(SearchContactsBlocState state) => state is SearchContactsLoaded && state.hasReachedMax!;

  @override
  void onEvent(SearchContactsBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("SearchContacts event:$event state:$state");
  }

  Future<Map<String, dynamic>?> searchContact(String keyword, bool searchRelationship, {String? relationshipCursor, String? playerCursor}) async {
    SearchPlayersCommand command = SearchPlayersCommand(keyword: keyword, searchRelationship: searchRelationship, relationshipCursor: relationshipCursor, playerCursor: playerCursor);
    if (await DataService().request(command)) {
      LogWidget.debug("SearchPlayersCommand success");

      Map<String, dynamic> result = {};

      Map<String, ContactModel> contactMap = {};

      command.contacts!.forEach((element) {
        ContactModel contactModel = ContactModel.fromMap(element);
        contactMap.putIfAbsent(contactModel.playerId, () => contactModel);
      });
      result.putIfAbsent("contactMap", () => contactMap);
      result.putIfAbsent("cursorId", () => command.content['cursorId']);

      return result;
    } else {
      LogWidget.debug("SearchPlayersCommand failed");
    }

    return null;
  }
  
}
