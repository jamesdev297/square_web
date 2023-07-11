part of 'my_nft_list_bloc.dart';

@immutable
abstract class MyNftListState {}

class MyNftListInitial extends MyNftListState {}

class LoadingMyNftListState extends MyNftListState {}

class LoadedMyNftListState extends MyNftListState {
  final List<PlayerNftModel> nftList;
  final NftQueueStatus? queueStatus;
  final bool hasReachedMax;
  final int reloadId;
  final String? cursor;
  final String? keyword;

  LoadedMyNftListState({
    required this.nftList,
    required this.queueStatus,
    required this.hasReachedMax,
    this.cursor,
    this.keyword,
    this.reloadId = 0
  });

  LoadedMyNftListState copyWith({
    final List<PlayerNftModel>? nftList,
    final NftQueueStatus? queueStatus,
    final bool? hasReachedMax,
    final bool reload = true,
    final String? cursor,
    final String? keyword,
  }) {
    var loaded = LoadedMyNftListState(
      nftList: nftList ?? this.nftList,
      queueStatus: queueStatus,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
      cursor: cursor,
      keyword: keyword ?? this.keyword,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [nftList, queueStatus, reloadId, cursor, keyword, hasReachedMax];

}