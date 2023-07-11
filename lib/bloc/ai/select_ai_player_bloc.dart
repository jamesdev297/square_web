
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/model/contact/contact_model.dart';

part 'select_ai_player_bloc_event.dart';
part 'select_ai_player_bloc_state.dart';

class SelectAiPlayerBloc extends Bloc<SelectAiPlayerBlocEvent, SelectAiPlayerBlocState> {
  SelectAiPlayerBloc() : super(SelectAiPlayerInitial()) {
    on<LoadAiPlayerEvent>((event, emit) async {
      ContactModel? aiPlayer = ContactModelPool().getPlayerContact(event.aiPlayerId);

      if (await aiPlayer.loadComplete.future == true) {

        return emit(SelectAiPlayerLoaded(selectedAiPlayer: aiPlayer));
      }

      emit(SelectAiPlayerLoading());
    });

    on<SelectAiPlayerEvent>((event, emit) async {
      if(state is SelectAiPlayerLoaded) {
        final currentState = state as SelectAiPlayerLoaded;

        emit(currentState.copyWith(selectedAiPlayer: event.aiPlayer, reload: true));
      }

      emit(SelectAiPlayerLoaded(selectedAiPlayer: event.aiPlayer));
    });
  }
}
