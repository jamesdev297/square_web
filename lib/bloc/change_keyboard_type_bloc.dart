import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/page/room/chat_page.dart';

part 'change_keyboard_type_bloc_event.dart';
part 'change_keyboard_type_bloc_state.dart';

class ChangeKeyboardTypeBloc extends Bloc<ChangeKeyboardTypeEvent, ChangeKeyboardTypeState> {
  ChangeKeyboardTypeBloc({ChangeKeyboardTypeState? initialState}) : super(initialState ?? DefaultTypeState()) {
    on<ChangeKeyboardType>((event, emit) {
      switch(event.keyboardType) {
        case KeyboardType.keyboard:
          emit(KeyboardTypeState());
          break;
        case KeyboardType.emoticon:
          emit(EmoticonTypeState());
          break;
        case KeyboardType.album:
          emit(AlbumTypeState());
          break;
        case KeyboardType.restricted:
          emit(RestrictedTypeState());
          break;
        case KeyboardType.none:
          emit(DefaultTypeState());
          break;
        default:
          emit(DefaultTypeState());
          break;
      }
    });

    on<ChangeKeyboardTypeForOpenChat>((event, emit) {
      switch(event.keyboardType) {
        case KeyboardType.keyboard:
          emit(KeyboardTypeState());
          break;
        case KeyboardType.emoticon:
          emit(EmoticonTypeState());
          break;
        case KeyboardType.restricted:
          emit(RestrictedTypeState());
          break;
        case KeyboardType.none:
          emit(DefaultTypeState());
          break;
        default:
          emit(DefaultTypeState());
          break;
      }
    });
  }

  @override
  void onEvent(ChangeKeyboardTypeEvent event) {
    super.onEvent(event);
    LogWidget.debug("ChangeKeyboardTypeBloc currentState : $state event: $event" );
  }
}
