part of 'player_profile_bloc.dart';

@immutable
abstract class PlayerProfileBlocState extends Equatable{
  const PlayerProfileBlocState();

  @override
  List<Object?> get props => [];
}

class PlayerProfileUninitialized extends PlayerProfileBlocState {}

class PlayerProfileError extends PlayerProfileBlocState {}

class PlayerProfileLoaded extends PlayerProfileBlocState {
  final ContactModel? player;
  final int reloadId;

  const PlayerProfileLoaded({this.player, this.reloadId = 0});

  PlayerProfileLoaded copyWith({
    ContactModel? player,
    bool reload = false,
  }) {
    var loaded = PlayerProfileLoaded(
      player: player ?? this.player,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [player, reloadId];

  @override
  String toString() => 'PlayerProfileLoaded {player: ${player!.playerId}, reloadId: $reloadId }';

}