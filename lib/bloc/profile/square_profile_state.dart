part of 'square_profile_bloc.dart';

@immutable
abstract class SquareProfileState {}

class SquareProfileInitial extends SquareProfileState {}

class SquareProfileError extends SquareProfileState {}

class SquareProfileLoaded extends SquareProfileState {
  final SquareModel squareModel;
  final int reloadId;

  SquareProfileLoaded({required this.squareModel, this.reloadId = 0});

  SquareProfileLoaded copyWith({
    SquareModel? squareModel,
    bool reload = false,
  }) {
    var loaded = SquareProfileLoaded(
      squareModel: squareModel ?? this.squareModel,
      reloadId: reload ? (this.reloadId + 1) % 987654321 : 0,
    );
    return loaded;
  }

  @override
  List<Object?> get props => [squareModel, reloadId];

  @override
  String toString() => 'SquareProfileLoaded {square: ${squareModel.squareId}, reloadId: $reloadId }';
}
