part of 'square_members_bloc.dart';

abstract class SquareMembersBlocState extends Equatable {
  const SquareMembersBlocState();

  @override
  List<Object?> get props => [];
}

class SquareMembersUninitialized extends SquareMembersBlocState {}

class SquareMembersError extends SquareMembersBlocState {}

class SquareMembersLoaded extends SquareMembersBlocState {
  final List<SquareMember> members;
  late Set<String> playerIds;
  final String? nextCursor;
  final int reloadId;

  SquareMembersLoaded({this.members = const [], this.nextCursor, this.reloadId = 0})
      : this.playerIds = members.map((e) => e.playerId).toSet();

  SquareMembersLoaded copyWith({
    List<SquareMember>? members,
    String? nextCursor,
    bool reload = false,
  }) {
    return SquareMembersLoaded(
      members: members ?? this.members,
      nextCursor: nextCursor ?? this.nextCursor,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
  }

  @override
  List<Object?> get props => [members, nextCursor, reloadId];
}

class OnSearchingSquareMembers extends SquareMembersBlocState {}

class SquareMembersSearched extends SquareMembersBlocState {
  final List<SquareMember> members;
  late Set<String> playerIds;
  final String? nextCursor;
  final int reloadId;

  SquareMembersSearched({this.members = const [], this.nextCursor, this.reloadId = 0})
      : this.playerIds = members.map((e) => e.playerId).toSet();

  SquareMembersSearched copyWith({
    List<SquareMember>? members,
    String? nextCursor,
    bool reload = false,
  }) {
    return SquareMembersSearched(
      members: members ?? this.members,
      nextCursor: nextCursor ?? this.nextCursor,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
  }

  @override
  List<Object?> get props => [members, nextCursor, reloadId];
}