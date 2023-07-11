part of 'change_keyboard_type_bloc.dart';

@immutable
abstract class ChangeKeyboardTypeEvent {}

class ChangeKeyboardType extends ChangeKeyboardTypeEvent {
  final KeyboardType? keyboardType;

  ChangeKeyboardType({required this.keyboardType});
}

class ChangeKeyboardTypeForOpenChat extends ChangeKeyboardTypeEvent {
  final KeyboardType? keyboardType;

  ChangeKeyboardTypeForOpenChat({this.keyboardType});
}