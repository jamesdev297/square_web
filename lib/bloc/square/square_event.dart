part of 'square_bloc.dart';

@immutable
abstract class SquareEvent {}

class InitSquare extends SquareEvent {
  final Completer? initCompleter;
  InitSquare({this.initCompleter});
}

class LoadSquare extends SquareEvent {}

class RefreshSquare extends SquareEvent {}

class ChangeSquareSort extends SquareEvent {
  final OrderType orderType;
  ChangeSquareSort(this.orderType);
}

class SearchSquareFromAll extends SquareEvent {
  final String keyword;
  SearchSquareFromAll(this.keyword);
}