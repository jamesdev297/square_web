import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/room/blocked_rooms_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/chat/room_item.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class BlockedRoomList extends StatefulWidget {
  final FocusNode focusNode;
  const BlockedRoomList({Key? key, required this.focusNode}) : super(key: key);

  @override
  _BlockedRoomListState createState() => _BlockedRoomListState();
}

class _BlockedRoomListState extends State<BlockedRoomList> with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  TextEditingDefault _textEditDefault = TextEditingDefault();
  bool isSelectMode = false;
  Timer? searchTimer;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    LogWidget.debug("Blocked Room List INIT");

    BlocManager.getBloc<BlockedRoomsBloc>()!.add(InitLoadBlockedRoomsEvent(MeModel().playerId!));

    _textEditDefault.init(
      "blockedRoomList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<BlockedRoomsBloc>()!.add(LoadBlockedRoomsEvent(MeModel().playerId!, keyword: text.trim().toLowerCase()));
        });
      },
    );

    _scrollController.addListener(() {
      if (widget.focusNode.hasFocus) {
        widget.focusNode.unfocus();
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditDefault.controller.dispose();
    _focusNode.dispose();
    searchTimer?.cancel();
    searchTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<BlockedRoomsBloc, BlockedRoomsBlocState>(
              bloc: BlocManager.getBloc(),
              builder: (context, state) {
                LogWidget.debug("Blocked RoomsBloc state $state");
                if (state is BlockedRoomsLoading || state is BlockedRoomsUninitialized) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                    ],
                  );
                } else if (state is BlockedRoomsError) {
                  return Center(child: Text(L10n.common_01_error_content));
                } else if (state is BlockedRoomsLoaded) {


                  if (state.totalCount! == 0 && !_textEditDefault.isComposing) {
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(height: Zeplin.size(200)),
                          Text(L10n.chat_04_01_empty, style: TextStyle(fontSize: Zeplin.size(30), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  List<RoomItem> list = _searchBlockedRooms(RoomManager().sortedRooms(state.roomMap.values.toList()));

                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: Zeplin.size(85),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(10)),
                              child: SearchTextField(
                                textEditingDefault: _textEditDefault,
                                focusNode: _focusNode,
                                hintText: L10n.chat_01_02_search_chat_room,
                                hasSuffixIcon: true,
                              ),
                            ),
                          ),
                          if(state.roomMap.isEmpty)
                            SliverToBoxAdapter(child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: DeviceUtil.screenHeight - Zeplin.size(93, isPcSize: true)),
                              child: NoSearchResultColumn()))
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate((context, index) {

                                RoomItem contactModel = list[index];

                                if(state.hasReachedMax == false && index == list.length-1) {
                                  BlocManager.getBloc<BlockedRoomsBloc>()!.add(LoadBlockedRoomsEvent(MeModel().playerId!));
                                }

                                return list[index];
                              },
                              childCount: list.length)
                            ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(Zeplin.size(34)),
                          child: Row(
                            children: [
                              Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onTap: () {

                                      isSelectMode = !isSelectMode;
                                      setState(() {});
                                    },
                                    child: Text(isSelectMode == false ? L10n.common_35_edit : L10n.common_36_complete, style: TextStyle(color: CustomColor.azureBlue, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500))),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }
                return Container();
              }
            ),
          ),
        ],
      ),
    );
  }

  List<RoomItem> _searchBlockedRooms(List<RoomModel> rooms) {
    if (_textEditDefault.resultText.isEmpty)
      return rooms.map((e) => RoomItem(e, onTap, isSelectMode: isSelectMode, onPressed: onPressed)).toList();

    return rooms.where((e) => (e.searchName?.toLowerCase() ?? "").contains(_textEditDefault.resultText.toLowerCase()))
      .map((e) => RoomItem(e, onTap, isSelectMode: isSelectMode, onPressed: onPressed))
      .toList();
  }

  void onPressed(RoomModel roomModel) {

    BlocManager.getBloc<BlockedRoomsBloc>()!.add(UnblockRoom(roomModel.roomId!, successFunc: () {
      roomModel.blockedTime = null;
      RoomManager().updateChatPage(roomModel: roomModel);
      SquareRoomDialog.showAddContactOverlay(roomModel.contact!.playerId, roomModel.searchName!);
    }));
  }

  void onTap(String roomId) {
    LogWidget.debug("clicked RoomItem roomId : ${roomId}");

    BlocManager.getBloc<BlockedRoomsBloc>()?.add(OpenBlockedRoomEvent(roomId));
  }

}

