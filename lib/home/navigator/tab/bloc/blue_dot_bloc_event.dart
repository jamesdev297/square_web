part of 'blue_dot_bloc.dart';

abstract class BlueDotBlocEvent {}

class AddNewKey extends BlueDotBlocEvent{
  final TabCode naviCode;
  final String key;

  AddNewKey({required this.naviCode, required this.key});
}

class RemoveKey extends BlueDotBlocEvent{
  final TabCode naviCode;
  final String key;

  RemoveKey({required this.naviCode, required this.key});
}