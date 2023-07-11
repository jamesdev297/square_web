import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/data_service.dart';

part 'trending_square_bloc_event.dart';
part 'trending_square_bloc_state.dart';

class TrendingSquareBloc extends Bloc<TrendingSquareBlocEvent, TrendingSquareBlocState> {
  final int limit = 30;

  TrendingSquareBloc() : super(InitialState()) {
    on<LoadTrendingSquareEvent>((event, emit) async {
      final currentState = state;

      if(currentState is InitialState) {
        emit(LoadingState());
        Map<String, dynamic> result = await loadTrendingSquareList(null, limit);
        Map<String, SquareModel> squareMap = Map.fromIterable(result['squares'] as List<SquareModel>, key: (e) => e.squareId, value: (e) => e);

        return emit(LoadedState(
          squaredMap: squareMap,
          cursor: result["cursor"],
          hasReachedMax: result["hasReachedMax"],
        ));
      } else if(currentState is LoadedState) {
        if(currentState.hasReachedMax) return ;

        Map<String, dynamic> result = await loadTrendingSquareList(currentState.cursor, limit);
        Map<String, SquareModel> squareMap = Map.fromIterable(result['squares'] as List<SquareModel>, key: (e) => e.squareId, value: (e) => e);

        currentState.squaredMap.addAll(squareMap);

        return emit(currentState.copyWith(
          squaredMap: currentState.squaredMap,
          cursor: result["cursor"],
          hasReachedMax: result["hasReachedMax"], reload: true));
      }
    });

    on<RemoveTrendingSquareEvent>((event, emit) async {
      final currentState = state;

      if(currentState is LoadedState) {

        currentState.squaredMap.remove(event.squareId);

        return emit(currentState.copyWith(squaredMap: currentState.squaredMap, reload: true));
      }
    });

    on<AddTrendingSquareEvent>((event, emit) async {
      final currentState = state;

      if(currentState is LoadedState) {
        currentState.squaredMap.putIfAbsent(event.square.squareId, () => event.square);

        return emit(currentState.copyWith(squaredMap: currentState.squaredMap, reload: true));
      }
    });

  }

  Future<Map<String, dynamic>> loadTrendingSquareList(String? cursor, int limit) async {
    GetTrendingSquareListCommand command = GetTrendingSquareListCommand(cursor: cursor, limit: limit);

    if(await DataService().request(command)) {
      if((command.squares?.length ?? 0) < limit && command.cursor != null) {
        this.add(LoadTrendingSquareEvent());
      }
      return {
        "squares" : command.squares ?? [],
        "hasReachedMax" : command.cursor == null,
        "cursor" : command.cursor
      };
    }

    return {
      "squares" : [],
      "hasReachedMax" : true,
      "cursor" : null
    };
  }

  @override
  void onEvent(TrendingSquareBlocEvent event) {
    super.onEvent(event);
    LogWidget.debug("SquareRecommendBloc event:$event state:$state");
  }
}
