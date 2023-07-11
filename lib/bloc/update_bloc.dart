import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

part 'update_event.dart';
part 'update_state.dart';

class MessageDelegateBloc extends UpdateBloc {}
class MyWalletPropertyBloc extends UpdateBloc {}
class SelectedContactBloc extends UpdateBloc {}
class MyProfileBloc extends UpdateBloc {}
class ChatPageBloc extends UpdateBloc {}
class SelectedRoomBloc extends UpdateBloc {}

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc() : super(UpdateInitial()) {
    on<Update>((event, emit) {
      if(state is UpdateInitial) {
        final currentState = state as UpdateInitial;
        emit(currentState.copyWith(reload : true, param: event.param));
      }
    });
  }

  @override
  void onEvent(UpdateEvent event) {
    super.onEvent(event);
    LogWidget.info("UpdateBloc event:$event state:$state");
  }
}
