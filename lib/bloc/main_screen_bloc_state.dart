part of 'main_screen_bloc.dart';

abstract class MainScreenBlocState extends Equatable {
  const MainScreenBlocState();
}

class MainScreenInitial extends MainScreenBlocState {
  @override
  List<Object> get props => [];
}

class MainScreenUpdated extends MainScreenBlocState {
  final String name;
  final dynamic param;

  MainScreenUpdated(this.name, {this.param});

  @override
  List<Object> get props => [name, param ?? ''];
}
