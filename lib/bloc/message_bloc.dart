import 'package:bloc/bloc.dart';
import 'package:square_web/bloc/bloc.dart';

class MessageBloc extends Bloc<MessageBlocEvent, MessageBlocState> {
  MessageBloc(MessageBlocState initialState) : super(initialState);
}
