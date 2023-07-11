part of 'search_ai_player_bloc.dart';

abstract class SearchAiPlayerBlocState extends Equatable {
  const SearchAiPlayerBlocState();

  @override
  List<Object?> get props => [];
}

class SearchAiPlayerInitial extends SearchAiPlayerBlocState {}

class SearchAiPlayerError extends SearchAiPlayerBlocState {}

class SearchAiPlayerLoaded extends SearchAiPlayerBlocState {
  final Map<String, ContactModel> contactMap;
  final String? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const SearchAiPlayerLoaded({
    required this.contactMap,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0,
  });

  SearchAiPlayerLoaded copyWith({
    final Map<String, ContactModel>? contactMap,
    String? cursor,
    String? keyword,
    final bool? hasReachedMax,
    bool reload = false
  }) {
    var loaded = SearchAiPlayerLoaded(
      contactMap: contactMap ?? this.contactMap,
      cursor: cursor ?? this.cursor,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [contactMap, cursor, keyword, hasReachedMax, reloadId];

  @override
  String toString() => 'SearchAiPlayerLoaded { reloadId: $reloadId }';
}
