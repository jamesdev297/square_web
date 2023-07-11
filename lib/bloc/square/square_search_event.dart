part of 'square_search_bloc.dart';

abstract class SquareSearchEvent {}
class InitSquareSearch extends SquareSearchEvent {}
class ResetSquareSearch extends SquareSearchEvent {}
class RefreshSearchSquare extends SquareSearchEvent {
  final String keyword;
  RefreshSearchSquare(this.keyword);
}
class LoadMoreSquare extends SquareSearchEvent {}
class SearchSquare extends SquareSearchEvent {
  final String keyword;
  final bool fromAll;
  SearchSquare(this.keyword, {this.fromAll = false});
}
class ClickSearchedSquare extends SquareSearchEvent {
  final SquareModel square;
  ClickSearchedSquare(this.square);
}
class RemoveRecentSearchedSquare extends SquareSearchEvent {
  final String? squareId;
  final bool removeAll;

  RemoveRecentSearchedSquare({this.squareId, this.removeAll = false});
}