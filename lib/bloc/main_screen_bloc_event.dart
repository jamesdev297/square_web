part of 'main_screen_bloc.dart';

abstract class MainScreenBlocEvent extends Equatable {
  const MainScreenBlocEvent();
}

class UpdateMainScreen extends MainScreenBlocEvent {
  final String name;
  final dynamic param;

  UpdateMainScreen(this.name, {this.param});

  @override
  List<Object?> get props => [name, param ?? ''];
}

