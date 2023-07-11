import 'package:meta/meta.dart';

@immutable
abstract class SwitchBlocState {}


class SwitchBlocOffState extends SwitchBlocState {}

class SwitchBlocOnState extends SwitchBlocState {
  final dynamic param;
  SwitchBlocOnState({this.param});
}


