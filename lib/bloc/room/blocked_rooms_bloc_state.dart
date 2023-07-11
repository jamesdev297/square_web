part of 'blocked_rooms_bloc.dart';

abstract class BlockedRoomsBlocState extends Equatable {
  const BlockedRoomsBlocState();

  @override
  List<Object?> get props => [];
}

class BlockedRoomsUninitialized extends BlockedRoomsBlocState {}

class BlockedRoomsError extends BlockedRoomsBlocState {}

class BlockedRoomsLoading extends BlockedRoomsBlocState {}

class BlockedRoomsLoaded extends BlockedRoomsBlocState {
  final Map<String, RoomModel> roomMap;
  final int? totalCount;
  final int? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const BlockedRoomsLoaded({
    required this.roomMap,
    required this.totalCount,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0
  });

  BlockedRoomsLoaded copyWith({
    final Map<String, RoomModel>? roomMap,
    final int? totalCount,
    final int? cursor,
    final String? keyword,
    final bool? hasReachedMax,
    final bool reload = true,
  }) {
    var loaded = BlockedRoomsLoaded(
      roomMap: roomMap ?? this.roomMap,
      totalCount: totalCount ?? this.totalCount,
      cursor: cursor ?? this.cursor,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [roomMap, totalCount, cursor, keyword, hasReachedMax,reloadId];

  @override
  String toString() => 'BlockedRoomsLoaded { totalCount : $totalCount, cursor: $cursor, keyword: $keyword, hasReachedMax: $hasReachedMax, reloadId: $reloadId }';
}
