import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/data_service.dart';

part 'square_profile_event.dart';
part 'square_profile_state.dart';

class SquareProfileBloc extends Bloc<SquareProfileEvent, SquareProfileState> {
  final SquareModel squareModel;

  SquareProfileBloc(this.squareModel) : super(SquareProfileInitial()) {
    on<FetchSquareProfileEvent>((event, emit) async {
      try {
        GetSquareProfileCommand command = GetSquareProfileCommand(squareId: event.squareId!);
        if (await DataService().request(command)) {
          LogWidget.debug("GetSquareProfileCommand success");
          emit(SquareProfileLoaded(squareModel: command.squareModel ?? squareModel));
        } else {
          emit(SquareProfileLoaded(squareModel: squareModel));
          LogWidget.debug("GetSquareProfileCommand failed");
        }
      } catch (e) {
        emit(SquareProfileLoaded(squareModel: squareModel));
        LogWidget.debug("GetSquareProfileCommand error $e");
      }
    });
  }

  @override
  void onEvent(SquareProfileEvent event) {
    super.onEvent(event);
    LogWidget.debug("SquareProfileBloc event:$event state:$state");
  }

}
