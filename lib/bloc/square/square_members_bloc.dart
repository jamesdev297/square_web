import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_member_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/service/square_manager.dart';

part 'square_members_bloc_event.dart';
part 'square_members_bloc_state.dart';

class SquareMembersBloc extends Bloc<SquareMembersBlocEvent, SquareMembersBlocState> {
  final SquareModel _model;

  // final String channelId;
  OrderType _orderType;

  void _sort(List<ContactModel> members, OrderType order) {
    switch (order) {
      case OrderType.name:
        members.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case OrderType.online:
        members.sort((a, b) => b.online
            ? 1
            : a.online
                ? -1
                : a.name.compareTo(b.name));
        break;
      default:
        return;
    }
  }

  SquareMembersBloc(this._model, this._orderType) : super(SquareMembersUninitialized()) {
    on<FetchSquareMembersEvent>((event, emit) async {
      String? nextCursor = null;
      if (state is SquareMembersLoaded) {
        nextCursor = (state as SquareMembersLoaded).nextCursor;
        if(nextCursor == null && event.isScroll) {
          LogWidget.debug("no more members");
          return;
        }
      }

      // ai스퀘어의 경우 ai멤버만 가져오기
      var entry = await SquareManager().getSquareMembers(_model, _orderType, cursor: nextCursor,
          memberType: _model.chainNetType == ChainNetType.ai ? SquareMemberType.ai : null);
      if (entry == null) {
        return emit(SquareMembersError());
      }

      List<SquareMember> members = entry.key;
      members.removeWhere((element) => element.isMe);
      if (state is SquareMembersLoaded) {
        final currentState = state as SquareMembersLoaded;
        members.removeWhere((e) => currentState.playerIds.contains(e.playerId));
        members = (state as SquareMembersLoaded).members..addAll(members);
      }
      _sort(members, _orderType);
      return emit(SquareMembersLoaded(members: members, nextCursor: entry.value));
    });

    on<ChangeSquareMembersOrderTypeEvent>((event, emit) async {
      if (_orderType == event.orderType || !(state is SquareMembersLoaded)) return emit(state);

      final currentState = state as SquareMembersLoaded;
      List<SquareMember> members = currentState.members;

      _sort(members, event.orderType);

      _orderType = event.orderType;
      return emit(SquareMembersLoaded(members: members, nextCursor: currentState.nextCursor));
    });

    on<SearchStart>((event, emit) {
      return emit(OnSearchingSquareMembers());
    });

    on<SearchSquareMembersEvent>((event, emit) async {
      if (event.keyword == null || event.keyword.trim().isEmpty) return;

      String? nextCursor = null;
      if (state is SquareMembersSearched) {
        nextCursor = (state as SquareMembersSearched).nextCursor;
        if(nextCursor == null && event.isScroll) {
          LogWidget.debug("no more members");
          return;
        }
      }

      /// 멤버검색
      // MapEntry<List<SquareMember>, String?>? result = await SquareManager().searchSquareMembers(_model, event.keyword, cursor: nextCursor);
      // if (result == null) return;

      List<SquareMember> members = (SquareManager().globalSquareMap[_model.squareId]!["members"] as List<SquareMember>).where((element) => element.nickname!.contains(event.keyword)).toList();
      if (state is SquareMembersSearched) {
        final currentState = state as SquareMembersSearched;
        members.removeWhere((e) => currentState.playerIds.contains(e.playerId));
        currentState.members.addAll(members);
      }
      return emit(SquareMembersSearched(members: members, nextCursor: null));
    });
  }
}
