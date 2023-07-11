part of 'my_nft_list_bloc.dart';

@immutable
abstract class MyNftListEvent {}

class LoadMyNftList extends MyNftListEvent {
  final String? keyword;

  LoadMyNftList({this.keyword});
}

class LoadingMyNftList extends MyNftListEvent {}
class InitMyNftList extends MyNftListEvent {}