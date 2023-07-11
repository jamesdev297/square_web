import 'package:bloc/bloc.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

import './bloc.dart';

class ShowEmoticonExampleBloc extends SwitchBloc {}

class SwitchBloc extends Bloc<SwitchBlocEvent, SwitchBlocState> {
  SwitchBloc() : super(SwitchBlocOffState()) {
    on<OnEvent>((event, emit) {
      emit(SwitchBlocOnState(param: event.param));
    });

    on<OffEvent>((event, emit) {
      emit(SwitchBlocOffState());
    });
  }

  @override
  void onEvent(SwitchBlocEvent event) {
    super.onEvent(event);
    LogWidget.debug("SwitchBloc event is $event ${this.runtimeType}");
  }
}
