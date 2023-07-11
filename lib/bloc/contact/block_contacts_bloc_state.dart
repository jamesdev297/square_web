part of 'block_contacts_bloc.dart';

abstract class BlockContactsBlocState extends Equatable {
  const BlockContactsBlocState();

  @override
  List<Object?> get props => [];
}

class BlockContactsInitial extends BlockContactsBlocState {}

class BlockContactsError extends BlockContactsBlocState {}

class BlockContactsLoading extends BlockContactsBlocState {}

class BlockContactsLoaded extends BlockContactsBlocState {
  final Map<String, ContactModel> blockedPlayerMap;
  final int? totalCount;
  final String? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const BlockContactsLoaded({
    required this.blockedPlayerMap,
    required this.totalCount,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0,
  });

  BlockContactsLoaded copyWith({
    Map<String, ContactModel>? blockedPlayerMap,
    final int? totalCount,
    final String? cursor,
    final String? keyword,
    final bool? hasReachedMax,
    final bool reload = true,
  }) {
    var loaded = BlockContactsLoaded(
      blockedPlayerMap: blockedPlayerMap ?? this.blockedPlayerMap,
      totalCount: totalCount ?? this.totalCount,
      cursor: cursor ?? this.cursor,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [blockedPlayerMap, totalCount, cursor, keyword, hasReachedMax, reloadId];

  @override
  String toString() => 'BlockContactsLoaded { totalCount: $totalCount, cursor: $cursor, keyword: $keyword, hasReachedMax: $hasReachedMax, reloadId: $reloadId }';
}
