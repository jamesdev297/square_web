part of 'square_search_bloc.dart';

abstract class SquareSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SquareSearchRecent extends SquareSearchState {
  final List<SquareModel> recentSearchedList;
  final int? reloadId;

  SquareSearchRecent(this.recentSearchedList, {bool reload = false}) : this.reloadId = reload ? DateTime.now().millisecondsSinceEpoch : null;

  @override
  List<Object?> get props => [recentSearchedList, reloadId];
}
class SquareSearching extends SquareSearchState {}
class SquareSearched extends SquareSearchState {
  final Map<String, SquareModel> searchedMap;
  final String keyword;
  final String? cursor;
  final bool fromAll;
  final bool hasReachedMax;
  final int reloadId;

  SquareSearched({required this.searchedMap, required this.keyword, required this.fromAll, this.cursor, this.hasReachedMax = false, this.reloadId = 0});

  SquareSearched copyWith({
    Map<String, SquareModel>? searchedMap,
    String? keyword,
    String? cursor,
    bool? fromAll,
    bool? hasReachedMax,
    bool reload = false,
  }) {
    var loaded = SquareSearched(
      searchedMap: searchedMap ?? this.searchedMap,
      keyword: keyword ?? this.keyword,
      cursor: cursor ?? this.cursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      fromAll: fromAll ?? this.fromAll,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [searchedMap, keyword, cursor, hasReachedMax, reloadId];
}
class SquareSearchFail extends SquareSearchState {}