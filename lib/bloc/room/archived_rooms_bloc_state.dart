part of 'archived_rooms_bloc.dart';

@immutable
abstract class ArchivedRoomsBlocState extends Equatable {
  const ArchivedRoomsBlocState();

  @override
  List<Object?> get props => [];
}
class ArchivedRoomsUninitialized extends ArchivedRoomsBlocState {}

class ArchivedRoomsError extends ArchivedRoomsBlocState {}

class ArchivedRoomsLoading extends ArchivedRoomsBlocState {}

class ArchivedRoomsLoaded extends ArchivedRoomsBlocState {
  final Map<String, RoomModel> roomMap;
  final int? totalCount;
  final int? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const ArchivedRoomsLoaded({
    required this.roomMap,
    required this.totalCount,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0
  });

  ArchivedRoomsLoaded copyWith({
    final Map<String, RoomModel>? roomMap,
    final int? totalCount,
    final int? cursor,
    final String? keyword,
    final bool? hasReachedMax,
    final bool reload = true,
  }) {
    var loaded = ArchivedRoomsLoaded(
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
  String toString() => 'ArchivedRoomsLoaded { totalCount: $totalCount, cursor: $cursor, keyword: $keyword, hasReachedMax: $hasReachedMax, reloadId: $reloadId }';
}
