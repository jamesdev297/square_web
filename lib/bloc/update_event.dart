part of 'update_bloc.dart';

@immutable
abstract class UpdateEvent {}

class Update extends UpdateEvent {
  dynamic param;
  Update({this.param});
}