import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/contact_manager.dart';

import 'package:square_web/service/data_service.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/room_manager.dart';

part 'player_profile_bloc_state.dart';
part 'player_profile_bloc_event.dart';

class PlayerProfileBloc extends Bloc<PlayerProfileBlocEvent, PlayerProfileBlocState> {
  String? playerId;

  PlayerProfileBloc(this.playerId) : super(PlayerProfileUninitialized()) {

    on<FetchPlayerProfileEvent>((event, emit) async {

      try {
        GetPlayerProfileCommand command = GetPlayerProfileCommand(playerId: MeModel().playerId!, targetPlayerId: event.targetPlayerId);
        if (await DataService().request(command)) {
          LogWidget.debug("GetFriendProfileCommand success");

          ContactManager().updateContact(command.contactModel!.playerId, command.contactModel!.name, profileImgUrl: command.contactModel!.profileImgUrl);
          RoomManager().updateTargetRoomMember(command.contactModel!, command.contactModel!.name, profileImgUrl: command.contactModel!.profileImgUrl);
        } else {

          LogWidget.debug("GetFriendProfileCommand failed");
        }
        emit(PlayerProfileLoaded(player: command.contactModel!));
      } catch (e) {
        LogWidget.debug("FriendOfFriendError $e");
        emit(PlayerProfileError());
      }
    });

    on<ReloadPlayerProfileEvent>((event, emit) async {
      final currentState = state;

      if(currentState is PlayerProfileLoaded) {
        emit(currentState.copyWith(player: event.player, reload: true));
      }
    });
  }

  @override
  void onEvent(PlayerProfileBlocEvent event) {
    super.onEvent(event);
    LogWidget.debug("PlayerOfFriendListBloc event:$event state:$state");
  }
}