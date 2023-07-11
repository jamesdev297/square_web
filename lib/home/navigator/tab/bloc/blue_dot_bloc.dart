import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/service/bloc_manager.dart';

part 'blue_dot_bloc_event.dart';
part 'blue_dot_bloc_state.dart';

class BlueDotBloc extends Bloc<BlueDotBlocEvent, BlueDotState> {
  BlueDotBloc() : super(BlueDotState(map: Map.fromIterable(TabCode.values, key: (e) => e, value: (e) => new Set<String>()))) {
    on<AddNewKey> ((event, emit) {
      emit(state.copyWith(reload: true)..add(event.naviCode, event.key));
    });
    on<RemoveKey> ((event, emit) => emit(state.copyWith(reload: true)..remove(event.naviCode, event.key)));
  }
}

class BlueDotState {
  final int reloadId;
  final Map<TabCode, Set<String>> map;
  BlueDotState({
    this.reloadId = 0,
    required this.map
  });

  BlueDotState copyWith({
    bool reload = false,
    Map<TabCode, Set<String>>? map,
  }) {
    var loaded = BlueDotState(
      reloadId: reload ? (this.reloadId+1)%987654321 : 0,
      map: map ?? this.map
    );
    return loaded;
  }

  void add(TabCode naviCode, String key) => map[naviCode]!.add(key);
  void remove(TabCode naviCode, String key) => map[naviCode]!.remove(key);
  bool hasBlueDot(TabCode naviCode, {String? key, String? prefix}) {
    if(prefix != null)
      return map[naviCode]!.firstWhere((e) => e.startsWith(prefix), orElse: () => "").isNotEmpty;
    else if(key != null)
      return map[naviCode]!.contains(key);

    return map[naviCode]!.isNotEmpty;
  }
}

class BlueDotKey {
  static const String notice = "notice";
  static String room(String roomId) => "room_${roomId}";
  static String newFriend = "newFriend";
  static String receiveFriendRequest = "receiveFriendRequest";
  static String unreadRoom = 'unreadRoom';
  static String unreadArchivedRoom = 'unreadArchivedRoom';
}

class BlueDotBuilder extends StatelessWidget {
  final double right;
  final double top;
  final double width;
  final TabCode naviCode;
  final String? blueDotKey;
  final String? prefix;
  final Widget child;

  const BlueDotBuilder({Key? key, this.right = 3, this.top = 3, this.width = 16,
    required this.naviCode, this.blueDotKey, this.prefix, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          child,
          BlocBuilder<BlueDotBloc, BlueDotState>(
            bloc: BlocManager.getBloc(),
            builder: (context, state) {
              if (state.hasBlueDot(naviCode, key: blueDotKey, prefix: prefix))
                return Positioned(
                    right: Zeplin.size(right),
                    top: Zeplin.size(top),
                    child: Image.asset(
                      Assets.img.fill_blue,
                      width: Zeplin.size(width),
                    ));
              return Container();
            },
          ),
        ],
      );
  }
}
