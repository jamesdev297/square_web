part of 'square_members_bloc.dart';

abstract class SquareMembersBlocEvent {}

class FetchSquareMembersEvent extends SquareMembersBlocEvent {
  final bool isScroll;
  FetchSquareMembersEvent({this.isScroll = false});
}

class ChangeSquareMembersOrderTypeEvent extends SquareMembersBlocEvent {
  final OrderType orderType;

  ChangeSquareMembersOrderTypeEvent(this.orderType);
}

class SearchStart extends SquareMembersBlocEvent {}

class SearchSquareMembersEvent extends SquareMembersBlocEvent {
  final String keyword;
  final bool isScroll;
  SearchSquareMembersEvent(this.keyword, { this.isScroll = false });
}