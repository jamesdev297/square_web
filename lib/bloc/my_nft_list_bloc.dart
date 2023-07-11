import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/service/data_service.dart';

part 'my_nft_list_event.dart';
part 'my_nft_list_state.dart';

class MyNftListBloc extends Bloc<MyNftListEvent, MyNftListState> {
  final int limit = 30;

  MyNftListBloc() : super(MyNftListInitial()) {
    on<InitMyNftList>((event, emit) {
      emit(MyNftListInitial());
    });

    on<LoadingMyNftList>((event, emit) {
      emit(LoadingMyNftListState());
    });

    on<LoadMyNftList>((event, emit) async {
      final currentState = state;

      if(currentState is MyNftListInitial || currentState is LoadingMyNftListState) {
        if(currentState is MyNftListInitial) {
          emit(LoadingMyNftListState());
        }
        Map<String, dynamic> result = await _loadMyNftList(keyword: event.keyword, limit: limit);

        emit(LoadedMyNftListState(
          nftList: result["nftList"] ?? [],
          queueStatus: result["queueStatus"],
          hasReachedMax: result["hasReachedMax"],
          cursor: result["cursor"],
          keyword: event.keyword
        ));
      } else if(currentState is LoadedMyNftListState) {
        if(currentState.keyword == event.keyword) {
          if(currentState.hasReachedMax) return ;

          Map<String, dynamic> result = await _loadMyNftList(cursor: currentState.cursor, keyword: currentState.keyword, limit: limit);
          emit(currentState.copyWith(
            nftList: currentState.nftList + (result["nftList"] ?? []),
            queueStatus: result["queueStatus"],
            hasReachedMax: result["hasReachedMax"],
            cursor: result["cursor"],
            reload: true
          ));

          return;
        }

        Map<String, dynamic> result = await _loadMyNftList(keyword: event.keyword, limit: limit);
        emit(LoadedMyNftListState(
          nftList: result["nftList"] ?? [],
          queueStatus: result["queueStatus"],
          hasReachedMax: result["hasReachedMax"],
          cursor: result["cursor"],
          keyword: event.keyword
        ));

      }
    });
  }

  @override
  void onEvent(MyNftListEvent event) {
    super.onEvent(event);
    LogWidget.info("MyNftListBloc event:$event state:$state");
  }

  Future<Map<String, dynamic>> _loadMyNftList({String? cursor, String? keyword, required int limit}) async {
    GetMyNftListCommand command = GetMyNftListCommand(cursor: cursor, keyword: keyword, limit: limit);
    if(await DataService().request(command)) {
      return {
        "nftList" : command.nftModels,
        "queueStatus" : command.queueStatus,
        "hasReachedMax" : command.cursor == null,
        "cursor" : command.cursor
      };
    }
    return {
      "nftList" : null,
      "queueStatus" : null,
      "hasReachedMax" : true,
      "cursor" : null
    };
  }
}
