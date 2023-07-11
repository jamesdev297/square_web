part of 'trending_square_bloc.dart';

@immutable
abstract class TrendingSquareBlocState {}

class InitialState extends TrendingSquareBlocState {}

class LoadingState extends TrendingSquareBlocState {}

class LoadedState extends TrendingSquareBlocState {
  final Map<String, SquareModel> squaredMap;
  final String? cursor;
  final bool hasReachedMax;
  final int reloadId;

  LoadedState({required this.squaredMap, this.cursor, this.hasReachedMax = false, this.reloadId = 0});

  LoadedState copyWith({
    Map<String, SquareModel>? squaredMap,
    String? cursor,
    bool? hasReachedMax,
    bool reload = false,
  }) {
    var loaded = LoadedState(
      squaredMap: squaredMap ?? this.squaredMap,
      cursor: cursor ?? this.cursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [squaredMap, cursor, hasReachedMax, reloadId];
}

class FailState extends TrendingSquareBlocState {}