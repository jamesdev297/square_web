part of 'select_ai_player_bloc.dart';

@immutable
abstract class SelectAiPlayerBlocEvent {}

class LoadAiPlayerEvent extends SelectAiPlayerBlocEvent {
  final String aiPlayerId;

  LoadAiPlayerEvent(this.aiPlayerId);
}

class SelectAiPlayerEvent extends SelectAiPlayerBlocEvent {
  final ContactModel aiPlayer;

  SelectAiPlayerEvent(this.aiPlayer);
}