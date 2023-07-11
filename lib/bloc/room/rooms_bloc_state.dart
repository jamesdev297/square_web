import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:square_web/model/room_model.dart';

@immutable
abstract class RoomsBlocState extends Equatable {
  const RoomsBlocState();

  @override
  List<Object?> get props => [];
}

class RoomsUninitialized extends RoomsBlocState {}

class RoomsError extends RoomsBlocState {}

class RoomsLoading extends RoomsBlocState {}

class RoomsLoaded extends RoomsBlocState {
  final Map<String, RoomModel> roomMap;
  final int? totalCount;
  final int? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const RoomsLoaded({
    required this.roomMap,
    required this.totalCount,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0
  });

  RoomsLoaded copyWith({
    final Map<String, RoomModel>? roomMap,
    final int? totalCount,
    final int? cursor,
    final String? keyword,
    final bool? hasReachedMax,
    final bool reload = true,
  }) {
    var loaded = RoomsLoaded(
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
  String toString() => 'RoomsLoaded { totalCount : $totalCount, cursor: $cursor, keyword: $keyword, hasReachedMax: $hasReachedMax, reloadId: $reloadId }';
}
