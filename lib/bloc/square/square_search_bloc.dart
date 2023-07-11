import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/square_manager.dart';

part 'square_search_event.dart';
part 'square_search_state.dart';

class SquareSearchBloc extends Bloc<SquareSearchEvent, SquareSearchState> {
  List<SquareModel> recentSearchedList = [];

  SquareSearchBloc() : super(SquareSearching()) {
    on<InitSquareSearch>((event, emit) async {
      List<String>? recentSearchedIds = prefs.getStringList(PrefsKey.recentSearchSquareList);
      LogWidget.debug(" on init square search!");
      recentSearchedList = [];
      List<SquareModel>? result = null;
      if (recentSearchedIds != null && recentSearchedIds.isNotEmpty) {
        GetSquareListCommand command = GetSquareListCommand(recentSearchedIds);
        if (await DataService().request(command)) {
          recentSearchedList.addAll(command.squares ?? []);
        }
      }
      return emit(SquareSearchRecent(recentSearchedList));
    });
    on<LoadMoreSquare>((event, emit) async {
      final currentState = state;
      if(currentState is SquareSearched) {
        if(currentState.hasReachedMax) return ;

        SearchSquareByNameCommand command = SearchSquareByNameCommand(
            keyword: currentState.keyword, fromAll: currentState.fromAll, cursor: currentState.cursor, limit: 20);

        if(await DataService().request(command)) {
          Map<String, SquareModel> squareMap = Map.fromIterable(command.squares ?? [], key: (e) => e.squareId, value: (e) => e);
          currentState.searchedMap.addAll(squareMap);

          return emit(SquareSearched(
            fromAll: currentState.fromAll,
            searchedMap: currentState.searchedMap,
            keyword: currentState.keyword,
            cursor: command.nextCursor,
            hasReachedMax: command.nextCursor == null
          ));
        }
      }
    });
    on<SearchSquare>((event, emit) async {
      emit(SquareSearching());

      if(event.fromAll && walletAddressRegExp.hasMatch(event.keyword)) {
        SearchSquareByAddressCommand command = SearchSquareByAddressCommand(contractAddress: event.keyword);
        if (!await DataService().request(command)) {
          return emit(SquareSearchFail());
        }

        return emit(SquareSearched(
            searchedMap: command.square != null ? { command.square!.squareId : command.square! } : {},
            keyword: event.keyword,
            cursor: null,
            fromAll: event.fromAll,
            hasReachedMax: true
        ));

      } else {

        /*SearchSquareByNameCommand command = SearchSquareByNameCommand(keyword: event.keyword, fromAll: event.fromAll, limit: 20);
        if (!await DataService().request(command)) {
          return emit(SquareSearchFail());
        }*/

        Map<String, SquareModel> squareMap = Map.fromIterable(SquareManager().globalSquareMap.values.map((e) => e["square"] as SquareModel).where((element) => element.squareName!.contains(event.keyword)), key: (e)=>e.squareId, value: (e)=>e);

        // Map<String, SquareModel> squareMap = Map.fromIterable(command.squares ?? [], key: (e) => e.squareId, value: (e) => e);

        return emit(SquareSearched(
            searchedMap: squareMap,
            keyword: event.keyword,
            cursor: null,
            fromAll: event.fromAll,
            hasReachedMax: true
        ));
      }
    });
    on<RefreshSearchSquare>((event, emit) async {
      emit(SquareSearching());
    });
    on<ResetSquareSearch>((event, emit) async {
      return emit(SquareSearchRecent(recentSearchedList));
    });
    on<ClickSearchedSquare>((event, emit) async {
      if (recentSearchedList.contains(event.square)) recentSearchedList.remove(event.square);

      recentSearchedList.add(event.square);
      if (recentSearchedList.length > 10) {
        recentSearchedList.removeAt(0);
      }
      prefs.setStringList(PrefsKey.recentSearchSquareList, recentSearchedList.map((e) => e.squareId).toList());
    });
    on<RemoveRecentSearchedSquare>((event, emit) async {
      if (event.removeAll)
        recentSearchedList.clear();
      else {
        recentSearchedList.removeWhere((element) => element.squareId == event.squareId);
      }

      prefs.setStringList(PrefsKey.recentSearchSquareList, recentSearchedList.map((e) => e.squareId).toList());
      return emit(SquareSearchRecent(recentSearchedList, reload: true));
    });
  }
}
