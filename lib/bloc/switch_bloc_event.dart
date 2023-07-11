import 'package:meta/meta.dart';

@immutable
abstract class SwitchBlocEvent {}

class OnEvent extends SwitchBlocEvent {
  final dynamic param;
  OnEvent({this.param});
}

class OffEvent extends SwitchBlocEvent {}

