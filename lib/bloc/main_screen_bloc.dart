
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

part 'main_screen_bloc_event.dart';
part 'main_screen_bloc_state.dart';

class MainScreenBloc extends Bloc<MainScreenBlocEvent, MainScreenBlocState> {
  MainScreenBloc() : super(MainScreenInitial()) {
    on<UpdateMainScreen>((event, emit) {
      emit(MainScreenUpdated(event.name, param: event.param));
    });
  }

  @override
  void onEvent(MainScreenBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("MainScreenBloc event:$event state:$state");
  }
}
