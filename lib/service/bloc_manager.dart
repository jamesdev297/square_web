import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/contact/recent_search_contact_bloc.dart';
import 'package:square_web/bloc/contact/search_contacts_bloc.dart';
import 'package:square_web/bloc/main_screen_bloc.dart';
import 'package:square_web/bloc/my_nft_list_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';

enum InitSteps {
  beforeSignUp,
  beforeSignIn,
  afterSignIn,
  onHomeScreen
}

class BlocManager {
  static BlocManager? _instance;
  BlocManager._internal() {
    if(initedSet.contains(InitSteps.beforeSignUp))
      return;
    initedSet.add(InitSteps.beforeSignUp);

    _addBloc(MainScreenBloc())..add(UpdateMainScreen("/"));
    //homeNavi
    _addBloc(BlueDotBloc());
  }

  factory BlocManager() => _instance ??= BlocManager._internal();

  static T? getBloc<T extends BlocBase>() => BlocManager()._getBloc<T>();
  static T addBloc<T extends BlocBase>(T bloc) => BlocManager()._addBloc(bloc);
  static void removeBloc(Type blocType) => BlocManager()._removeBloc(blocType);

  final Map<Type, BlocBase> _blocMap = {};
  T? _getBloc<T extends BlocBase?>() => _blocMap[T] as T?;
  T _addBloc<T extends BlocBase>(T bloc) => _blocMap[T] = bloc;
  void _removeBloc(Type blocType) => _blocMap.remove(blocType);

  final Set<InitSteps> initedSet = {};

  Future<void> initAfterSignIn() async {
    if(initedSet.contains(InitSteps.afterSignIn))
      return;
    initedSet.add(InitSteps.afterSignIn);

    return;
  }

  Future<void> initHomeScreenBlocs() async {
    if(initedSet.contains(InitSteps.onHomeScreen))
      return;
    initedSet.add(InitSteps.onHomeScreen);

    LogWidget.debug("initHomeScreenBlocs start");

    //Contacts
    _addBloc(ContactsBloc());
    _addBloc(BlockedContactsBloc());
    _addBloc(RecentSearchContactBloc());
    _addBloc(SearchContactsBloc());

    //profile
    _addBloc(MyProfileBloc())..add(Update());
    _addBloc(MyNftListBloc());

    //Room
    _addBloc(RoomsBloc());
    _addBloc(BlockedRoomsBloc());
    _addBloc(ArchivedRoomsBloc());
    _addBloc(ChatPageBloc());

    //Chat
    _addBloc(ShowEmoticonExampleBloc());

    LogWidget.debug("initHomeScreenBlocs end");
    return;
  }

  Future<void> destroy() async {
    await Future.forEach(
        _instance!._blocMap.values, (dynamic bloc) => bloc.close());
    _instance = null;
  }
}