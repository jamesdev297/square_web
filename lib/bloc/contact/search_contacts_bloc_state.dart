part of 'search_contacts_bloc.dart';

@immutable
abstract class SearchContactsBlocState extends Equatable {
  const SearchContactsBlocState();

  @override
  List<Object?> get props => [];
}

class SearchContactsInitial extends SearchContactsBlocState {}

class SearchContactsError extends SearchContactsBlocState {}

class SearchContactsLoaded extends SearchContactsBlocState {
  final Map<String, ContactModel> contactMap;
  final bool searchRelationship;
  final String? relationshipCursor;
  final String? playerCursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const SearchContactsLoaded({
    required this.contactMap,
    this.searchRelationship = true,
    this.relationshipCursor,
    this.playerCursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0,
  });

  SearchContactsLoaded copyWith({
    final Map<String, ContactModel>? contactMap,
    bool? searchRelationship,
    String? relationshipCursor,
    String? playerCursor,
    String? keyword,
    final bool? hasReachedMax,
    bool reload = false
  }) {
    var loaded = SearchContactsLoaded(
      contactMap: contactMap ?? this.contactMap,
      searchRelationship: searchRelationship ?? this.searchRelationship,
      relationshipCursor: relationshipCursor ?? this.relationshipCursor,
      playerCursor: playerCursor ?? this.playerCursor,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [contactMap, searchRelationship, relationshipCursor, playerCursor, keyword, hasReachedMax, reloadId];

  @override
  String toString() => 'SearchContactsLoaded { reloadId: $reloadId }';
}
