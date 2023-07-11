part of 'recent_search_contact_bloc.dart';

abstract class RecentSearchContactBlocState extends Equatable {
  const RecentSearchContactBlocState();

  @override
  List<Object?> get props => [];
}

class RecentSearchContactInitial extends RecentSearchContactBlocState {}

class RecentSearchContactError extends RecentSearchContactBlocState {}

class RecentSearchContactLoading extends RecentSearchContactBlocState {}

class RecentSearchContactLoaded extends RecentSearchContactBlocState {
  final List<ContactModel>? recentSearchPlayerList;
  final int reloadId;

  const RecentSearchContactLoaded({
    this.recentSearchPlayerList,
    this.reloadId = 0,
  });

  RecentSearchContactLoaded copyWith({
    List<ContactModel>? recentSearchPlayerList,
    bool reload = false
  }) {
    var loaded = RecentSearchContactLoaded(
      recentSearchPlayerList: recentSearchPlayerList ?? this.recentSearchPlayerList,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [recentSearchPlayerList, reloadId];

  @override
  String toString() => 'RecentSearchContactLoaded { reloadId: $reloadId }';
}
