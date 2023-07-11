import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:square_web/bloc/square/trending_square_bloc.dart';
import 'package:square_web/command/command_square.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/square_manager.dart';

part 'square_event.dart';
part 'square_state.dart';

class SecretSquareBloc extends SquareBloc {
  SecretSquareBloc({required super.playerId, super.isPublic = false});
}

class PublicSquareBloc extends SquareBloc {
  PublicSquareBloc({required super.playerId, super.isPublic = true});
}

class SquareBloc extends Bloc<SquareEvent, SquareState> {
  final int limit = 20;
  String playerId;
  OrderType orderType = OrderType.memberCount;
  bool? isPublic;

  SquareBloc({required this.playerId, this.isPublic}) : super(SquareInitial()) {
    on<InitSquare>((event, emit) async {
      final currentState = state;
      if(currentState is SquareInitial) {
        emit(LoadingSquareState());
      }
      Map<String, dynamic> result = await loadPlayerSquareList(isPublic: isPublic);
      List<SquareModel> squareList = (result["squares"] ?? [])..sort(compared);
      SquareManager().setSquares(squareList);

      event.initCompleter?.complete();

      if(isPublic == true && playerId == MeModel().playerId && result["hasReachedMax"] == true) {
        BlocManager.getBloc<TrendingSquareBloc>()?.add(LoadTrendingSquareEvent());
      }

      return emit(LoadedSquareState(
          squareList: squareList,
          cursor: result["cursor"],
          hasReachedMax: result["hasReachedMax"],
          queueStatus: result["queueStatus"],
          errorCode: result["errorCode"],
          totalCount: result["totalCount"]
      ));
    });

    on<LoadSquare>((event, emit) async {
      final currentState = state;
      if(currentState is LoadedSquareState) {
        if(currentState.queueStatus == NftQueueStatus.done) {
          if(currentState.hasReachedMax) {
            if(isPublic == true && playerId == MeModel().playerId) {
              BlocManager.getBloc<TrendingSquareBloc>()?.add(LoadTrendingSquareEvent());
            }
            return ;
          }
        }

        Map<String, dynamic> result = await loadPlayerSquareList(cursor: currentState.cursor, isPublic: isPublic);
        List<SquareModel> tempList = result["squares"] ?? [];
        Set<String> oldIds = currentState.squareList.map((e) => e.squareId).toSet();
        tempList.removeWhere((element) => oldIds.contains(element.squareId));
        List<SquareModel> squareList = tempList..sort(compared);
        SquareManager().setSquares(squareList);

        if(isPublic == true && playerId == MeModel().playerId && result["hasReachedMax"] == true) {
          BlocManager.getBloc<TrendingSquareBloc>()?.add(LoadTrendingSquareEvent());
        }

        return emit(currentState.copyWith(
            squareList: (currentState.squareList + squareList),
            cursor: result["cursor"],
            hasReachedMax: result["hasReachedMax"],
            queueStatus: result["queueStatus"],
            errorCode: result["errorCode"],
            totalCount: result["totalCount"]));
      }
    });

    on<RefreshSquare>((event, emit) async {
      final currentState = state;
      if(currentState is LoadedSquareState) {
        if(NftQueueStatus.isRunning(currentState.queueStatus) && currentState.errorCode == null) {
          return ;
        }
        SquareManager().squareMap.clear();
        emit(currentState.copyWith(squareList: [], cursor: null, hasReachedMax: false, queueStatus: NftQueueStatus.running, errorCode: null, reload: true));
        DataService().request(RefreshNftListCommand(playerId));
      }
    });

    on<ChangeSquareSort>((event, emit) async {
      final currentState = state;
      orderType = event.orderType;
      if(currentState is LoadedSquareState) {
        return emit(currentState.copyWith(squareList: currentState.squareList..sort(compared)));
      }
    });
  }

  Future<Map<String, dynamic>> loadPlayerSquareList(
      {String? cursor, bool? isPublic}) async {
    GetPlayerSquareListCommand command = GetPlayerSquareListCommand(playerId: MeModel().playerId, isPublic: isPublic, targetPlayerId: playerId, cursor: cursor, limit: limit);
    if(await DataService().request(command)) {
      return {
        "squares" : command.squareModels,
        "queueStatus" : command.queueStatus,
        "hasReachedMax" : command.cursor == null,
        "cursor" : command.cursor,
        "totalCount" : command.totalCount
      };
    }
    return {
      "nftList" : null,
      "queueStatus" : null,
      "hasReachedMax" : true,
      "errorCode" : command.status,
      "cursor" : null,
      "totalCount" : 0
    };
  }

  @override
  void onEvent(SquareEvent event) {
    super.onEvent(event);
    LogWidget.debug("squarebloc event:$event state:$state");
  }

  int compared(SquareModel a, SquareModel b) {
    switch(orderType) {
      case OrderType.name:
        var aName = a.squareName ?? a.contractAddress;
        var bName = b.squareName ?? b.contractAddress;
        return aName.compareTo(bName);
      case OrderType.memberCount:
        return b.memberCount?.compareTo(a.memberCount ?? 0) ?? 1;
      default:
        return 1;
    }
  }
}


