part of 'update_bloc.dart';

@immutable
abstract class UpdateState {
  const UpdateState();
}

class UpdateInitial extends UpdateState {
  final int reloadId;
  final dynamic param;
  const UpdateInitial({
    this.reloadId = 0,
    this.param
  });

  UpdateInitial copyWith({
    bool reload = false,
    dynamic param,
  }) {
    var loaded = UpdateInitial(
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
      param: param
    );
    return loaded;
  }

  @override
  List<Object?> get props => [reloadId, param];
}
