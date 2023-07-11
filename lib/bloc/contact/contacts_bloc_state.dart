part of 'contacts_bloc.dart';

@immutable
abstract class ContactsBlocState extends Equatable {
  const ContactsBlocState();

  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsBlocState {}

class ContactsError extends ContactsBlocState {}

class ContactsLoading extends ContactsBlocState {}

class ContactsLoaded extends ContactsBlocState {
  final Map<String, ContactModel> contactMap;
  final int? totalCount;
  final String? cursor;
  final String? keyword;
  final bool? hasReachedMax;
  final int reloadId;

  const ContactsLoaded({
    required this.contactMap,
    required this.totalCount,
    this.cursor,
    this.keyword,
    this.hasReachedMax = false,
    this.reloadId = 0,
  });

  ContactsLoaded copyWith({
    final Map<String, ContactModel>? contactMap,
    final int? totalCount,
    final String? cursor,
    final String? keyword,
    final bool? hasReachedMax,
    final bool reload = true,
  }) {
    var loaded = ContactsLoaded(
      contactMap: contactMap ?? this.contactMap,
      totalCount: totalCount ?? this.totalCount,
      cursor: cursor ?? this.cursor,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [contactMap, totalCount, cursor, keyword, hasReachedMax, reloadId];

  @override
  String toString() => 'ContactsLoaded { totalCount: $totalCount, cursor: $cursor, keyword: $keyword, hasReachedMax: $hasReachedMax, reloadId: $reloadId }';
}
