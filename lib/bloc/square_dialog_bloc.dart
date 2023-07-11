import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'square_dialog_event.dart';
part 'square_dialog_state.dart';

class SquareDialogBloc extends Bloc<SquareDialogEvent, SquareDialogState> {
  SquareDialogBloc(SquareDialogState initialState) : super(initialState);
}
