part of 'trending_square_bloc.dart';

@immutable
abstract class TrendingSquareBlocEvent {}

class InitTrendingSquareEvent extends TrendingSquareBlocEvent {}

class LoadTrendingSquareEvent extends TrendingSquareBlocEvent {}

class RemoveTrendingSquareEvent extends TrendingSquareBlocEvent {
  String squareId;

  RemoveTrendingSquareEvent(this.squareId);
}

class AddTrendingSquareEvent extends TrendingSquareBlocEvent {
  SquareModel square;

  AddTrendingSquareEvent(this.square);
}