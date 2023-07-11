part of 'square_profile_bloc.dart';

@immutable
abstract class SquareProfileEvent {}

class FetchSquareProfileEvent extends SquareProfileEvent {
  final String? squareId;
  final VoidCallback? successFunc;
  final VoidCallback? failFunc;

  FetchSquareProfileEvent({this.squareId, this.successFunc, this.failFunc});
}
