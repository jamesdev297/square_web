part of 'square_bloc.dart';

@immutable
abstract class SquareState {}

class SquareInitial extends SquareState {}

class LoadingSquareState extends SquareState {}

class LoadedSquareState extends SquareState {
  final List<SquareModel> squareList;
  final String? cursor;
  final int? limit;
  final int totalCount;
  final bool hasReachedMax;
  final NftQueueStatus? queueStatus;
  final int? errorCode;
  final int reloadId;


  LoadedSquareState({required this.squareList, this.cursor, this.limit, required this.queueStatus, this.reloadId = 0, this.errorCode, this.hasReachedMax = false, this.totalCount = 0});

  LoadedSquareState copyWith({
    final List<SquareModel>? squareList,
    final String? cursor,
    final NftQueueStatus? queueStatus,
    final int? limit,
    final bool reload = true,
    final int? errorCode,
    final bool? hasReachedMax,
    final int? totalCount
  }) {
    var loaded = LoadedSquareState(
      squareList: squareList ?? this.squareList,
      cursor: cursor,
      queueStatus: queueStatus ?? this.queueStatus,
      limit: limit ?? this.limit,
      errorCode : errorCode,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount
    );
    return loaded;
  }

  @override
  String toString() {
    return 'LoadedSquareState{cursor: $cursor, limit: $limit, totalCount: $totalCount, hasReachedMax: $hasReachedMax, queueStatus: $queueStatus, errorCode: $errorCode, reloadId: $reloadId}';
  }

  @override
  List<Object?> get props => [squareList, cursor, queueStatus, limit, reloadId, errorCode, hasReachedMax, totalCount];
}