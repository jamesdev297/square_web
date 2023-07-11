part of 'player_profile_bloc.dart';

@immutable
abstract class PlayerProfileBlocEvent {}

class FetchPlayerProfileEvent extends PlayerProfileBlocEvent {
  final String? targetPlayerId;
  final VoidCallback? successFunc;
  final VoidCallback? failFunc;

  FetchPlayerProfileEvent({this.targetPlayerId, this.successFunc, this.failFunc});
}

class ReloadPlayerProfileEvent extends PlayerProfileBlocEvent {
  ContactModel player;

  ReloadPlayerProfileEvent(this.player);
}