part of 'select_ai_player_bloc.dart';

@immutable
abstract class SelectAiPlayerBlocState extends Equatable {
  const SelectAiPlayerBlocState();

  @override
  List<Object?> get props => [];
}

class SelectAiPlayerInitial extends SelectAiPlayerBlocState {}

class SelectAiPlayerLoading extends SelectAiPlayerBlocState {}

class SelectAiPlayerError extends SelectAiPlayerBlocState {}

class SelectAiPlayerLoaded extends SelectAiPlayerBlocState {
  final ContactModel selectedAiPlayer;
  final int reloadId;

  const SelectAiPlayerLoaded({
    required this.selectedAiPlayer,
    this.reloadId = 0,
  });

  SelectAiPlayerLoaded copyWith({
    ContactModel? selectedAiPlayer,
    final bool reload = true,
  }) {
    var loaded = SelectAiPlayerLoaded(
      selectedAiPlayer: selectedAiPlayer ?? this.selectedAiPlayer,
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [selectedAiPlayer, reloadId];

  @override
  String toString() => 'SelectAiPlayerLoaded { selectedAiPlayer: $selectedAiPlayer, reloadId: $reloadId }';
}
