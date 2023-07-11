part of 'search_ai_player_bloc.dart';

abstract class SearchAiPlayerBlocEvent {}

class SearchAiPlayerEvent extends SearchAiPlayerBlocEvent {
  String keyword;

  SearchAiPlayerEvent(this.keyword);
}