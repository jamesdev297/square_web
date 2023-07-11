import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/data_service.dart';

part 'recent_search_contact_bloc_event.dart';
part 'recent_search_contact_bloc_state.dart';

class RecentSearchContactBloc extends Bloc<RecentSearchContactBlocEvent, RecentSearchContactBlocState> {
  RecentSearchContactBloc() : super(RecentSearchContactInitial()) {
    on<LoadEvent>((event, emit) async {
      List<String>? recentSearchPlayerIdList = prefs.getStringList(PrefsKey.recentSearchPlayer);

      if(recentSearchPlayerIdList == null || recentSearchPlayerIdList.isEmpty) {
        emit(RecentSearchContactLoaded(recentSearchPlayerList: []));
      } else {

        recentSearchPlayerIdList = recentSearchPlayerIdList.getRange(0, recentSearchPlayerIdList.length > maxTempSaveCount ? maxTempSaveCount : recentSearchPlayerIdList.length).toList();

        Map<String, ContactModel>? playerMap = await loadFromServer(recentSearchPlayerIdList);

        if(playerMap == null) {
          emit(RecentSearchContactError());
          return;
        }

        List<ContactModel> recentSearchPlayerList = [];

        recentSearchPlayerIdList.forEach((element) {
          if(playerMap.containsKey(element)) {
            recentSearchPlayerList.add(playerMap[element]!);
          }
        });

        emit(RecentSearchContactLoaded(recentSearchPlayerList: recentSearchPlayerList));
      }
    });

    on<RemoveEvent>((event, emit) async {
      final currentState = state;

      if(currentState is RecentSearchContactLoaded) {

        List<String>? recentSearchPlayerIdList = prefs.getStringList(PrefsKey.recentSearchPlayer);
        recentSearchPlayerIdList?.remove(event.playerId);
        prefs.setStringList(PrefsKey.recentSearchPlayer, recentSearchPlayerIdList ?? []);

        emit(currentState.copyWith(recentSearchPlayerList: currentState.recentSearchPlayerList!.where((e) => e.playerId != event.playerId).toList(), reload: true));
      }
    });

    on<RemoveAllEvent>((event, emit) async {
      final currentState = state;

      if(currentState is RecentSearchContactLoaded) {

        prefs.setStringList(PrefsKey.recentSearchPlayer, []);

        emit(currentState.copyWith(recentSearchPlayerList: [], reload: true));
      }
    });

    on<AddEvent>((event, emit) async {
      List<String> recentSearchPlayerIdList = prefs.getStringList(PrefsKey.recentSearchPlayer) ?? [];

      if(recentSearchPlayerIdList.length > maxTempSaveCount-1) {
        recentSearchPlayerIdList.removeLast();
      }
      if(recentSearchPlayerIdList.contains(event.contact.playerId) == true) {
        recentSearchPlayerIdList.remove(event.contact.playerId);
      }

      recentSearchPlayerIdList.insert(0, event.contact.playerId);
      prefs.setStringList(PrefsKey.recentSearchPlayer, recentSearchPlayerIdList);

      emit(RecentSearchContactLoaded(recentSearchPlayerList: []));
    });

    on<LoadingEvent>((event, emit) async {
      emit(RecentSearchContactLoading());
    });

    on<InitEvent>((event, emit) async {
      emit(RecentSearchContactInitial());
    });

    on<ReloadEvent>((event, emit) async {
      final currentState = state;

      if(currentState is RecentSearchContactLoaded) {
       add(LoadEvent());
      }
    });

  }

  @override
  void onEvent(RecentSearchContactBlocEvent event) {
    super.onEvent(event);
    LogWidget.info("RecentSearchPlayerBloc event:$event state:$state");
  }

  Future<Map<String, ContactModel>?> loadFromServer(List<String> targetPlayerIds) async {
    LogWidget.debug("load recent search player list from server!");

    try {
      GetTargetContactsCommand command = GetTargetContactsCommand(targetPlayerIds);
      if(await DataService().request(command)) {
        LogWidget.debug("GetTargetPlayersCommand success");

        Map<String, ContactModel> targetPlayerMap = {};

        command.contacts!.forEach((element) {
          ContactModel contactModel = ContactModel.fromMap(element);
          targetPlayerMap.putIfAbsent(contactModel.playerId, () => contactModel);
        });

        return targetPlayerMap;
      } else {
        LogWidget.debug("GetTargetPlayersCommand fail");

        return null;
      }
    } catch(e) {
      LogWidget.debug("error $e");
      return null;
    }
    return {};
  }

}
