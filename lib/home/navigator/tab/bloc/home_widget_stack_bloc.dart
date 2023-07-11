import 'package:bloc/bloc.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/util/dart_stack.dart';

class HomeWidgetStackEvent {}
class Push extends HomeWidgetStackEvent {
  HomeWidget widget;
  Push(this.widget);
}

class Pop extends HomeWidgetStackEvent {}

class HomeWidgetStackBloc extends Bloc<HomeWidgetStackEvent, DartStack<HomeWidget>> {
  // DartStack<HomeWidget> widgetStack = DartStack();
  HomeWidgetStackBloc() : super(DartStack()) {
    on<HomeWidgetStackEvent>((event, emit) {
      if(event is Push) {
        emit(state..push(event.widget));
      } else if (event is Pop) {
        emit(state..pop());
      }
    });
  }
}