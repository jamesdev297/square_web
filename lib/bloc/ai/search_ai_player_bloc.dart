import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/data_service.dart';

part 'search_ai_player_bloc_event.dart';
part 'search_ai_player_bloc_state.dart';

class SearchAiPlayerBloc extends Bloc<SearchAiPlayerBlocEvent, SearchAiPlayerBlocState> {
  SearchAiPlayerBloc() : super(SearchAiPlayerInitial()) {
    on<SearchAiPlayerEvent>((event, emit) async {
      final currentState = state;
      if(currentState is SearchAiPlayerInitial) {
        String keyword = event.keyword.trim();
        Map<String, dynamic>? result = await searchAiPlayers(keyword);
        if (result == null) {
          emit(SearchAiPlayerError());
        }

        Map<String, ContactModel> newContactMap = result!['contactMap'];
        String? cursor = result['cursor'];

        emit(SearchAiPlayerLoaded(contactMap: newContactMap, keyword: keyword, cursor: cursor, hasReachedMax: cursor == null));
      } else if(currentState is SearchAiPlayerLoaded) {
        String keyword = event.keyword.trim();
        if(keyword == currentState.keyword) {

          if(_hasReachedMax(state)) {
            return;
          }

          Map<String, dynamic>? result = await searchAiPlayers(keyword, cursor: currentState.cursor);
          if (result == null) {
            emit(SearchAiPlayerError());
          }

          Map<String, ContactModel> newContactMap = result!['contactMap'];
          String? cursor = result['cursor'];

          currentState.contactMap.addAll(newContactMap);
          emit(currentState.copyWith(contactMap: currentState.contactMap, keyword: keyword, cursor: cursor, hasReachedMax: cursor == null));

        } else {

          Map<String, dynamic>? result = await searchAiPlayers(keyword);
          if (result == null) {
            emit(SearchAiPlayerError());
          }

          Map<String, ContactModel> newContactMap = result!['contactMap'];
          String? cursor = result['cursor'];

          emit(SearchAiPlayerLoaded(contactMap: newContactMap, keyword: keyword, cursor: cursor, hasReachedMax: cursor == null));
        }
      }
    });
  }

  Future<Map<String, dynamic>?> searchAiPlayers(String keyword, {String? cursor}) async {
    SearchAiPlayersCommand command = SearchAiPlayersCommand(keyword: keyword, cursor: cursor);
    if (await DataService().request(command)) {
      LogWidget.debug("SearchAiPlayersCommand success");

      Map<String, dynamic> result = {};
      Map<String, ContactModel> contactMap = {};

      command.contacts!.forEach((element) {
        ContactModel contactModel = ContactModel.fromMap(element);
        contactMap.putIfAbsent(contactModel.playerId, () => contactModel);
      });
      result.putIfAbsent("contactMap", () => contactMap);
      result.putIfAbsent("cursor", () => command.content['cursor']);

      return result;
    } else {
      LogWidget.debug("SearchAiPlayersCommand failed");
    }

    return null;
  }


  bool _hasReachedMax(SearchAiPlayerBlocState state) => state is SearchAiPlayerLoaded && state.hasReachedMax!;

  @override
  void onEvent(SearchAiPlayerBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("SearchAiPlayer event:$event state:$state");
  }
}
