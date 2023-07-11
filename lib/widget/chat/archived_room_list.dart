import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/room/archived_rooms_bloc.dart';
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

class ArchivedRoomList extends StatefulWidget {
  final FocusNode focusNode;
  const ArchivedRoomList({Key? key, required this.focusNode}) : super(key: key);

  @override
  _ArchivedRoomListState createState() => _ArchivedRoomListState();
}

class _ArchivedRoomListState extends State<ArchivedRoomList> {
  ScrollController _scrollController = ScrollController();
  TextEditingDefault _textEditDefault = TextEditingDefault();
  bool isSelectMode = false;
  Timer? searchTimer;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    LogWidget.debug("Archived Room List INIT");

    BlocManager.getBloc<ArchivedRoomsBloc>()!.add(InitLoadArchivedRoomsEvent(MeModel().playerId!));

    _textEditDefault.init(
      "archivedRoomList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<ArchivedRoomsBloc>()!.add(LoadArchivedRoomsEvent(MeModel().playerId!, keyword: text.trim().toLowerCase()));
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
            child: BlocBuilder<ArchivedRoomsBloc, ArchivedRoomsBlocState>(
                bloc: BlocManager.getBloc(),
                builder: (context, state) {
                  LogWidget.debug("ArchivedRoomsBloc state $state");
                  if (state is ArchivedRoomsLoading || state is ArchivedRoomsUninitialized) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                      ],
                    );
                  } else if (state is ArchivedRoomsError) {
                    return Center(child: Text(L10n.common_01_error_content));
                  } else if (state is ArchivedRoomsLoaded) {

                    if (state.totalCount! == 0 && !_textEditDefault.isComposing) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: Zeplin.size(200)),
                            Text(L10n.archive_02_02_empty_archived_room, style: TextStyle(fontSize: Zeplin.size(30), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }

                    List<RoomItem> list = _searchRooms(RoomManager().sortedRooms(state.roomMap.values.toList()));

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
                                  focusNode: _focusNode,
                                  textEditingDefault:  _textEditDefault,
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
                                    BlocManager.getBloc<ArchivedRoomsBloc>()!.add(LoadArchivedRoomsEvent(MeModel().playerId!));
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
                                      onTap: () => setState(() { isSelectMode = !isSelectMode; }),
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

  List<RoomItem> _searchRooms(List<RoomModel> rooms) {
    if (_textEditDefault.resultText.isEmpty) return rooms.map((e) => RoomItem(e, onTap, isSelectMode: isSelectMode, onPressed: (e) => SquareRoomDialog.showArchiveRoomOverlay(e))).toList();

    return rooms.where((e) => (e.searchName?.toLowerCase() ?? "").contains(_textEditDefault.resultText.toLowerCase()))
      .map((e) => RoomItem(e, onTap, isSelectMode: isSelectMode, onPressed: (e) => SquareRoomDialog.showArchiveRoomOverlay(e)))
      .toList();
  }

  void onTap(String roomId) {
    LogWidget.debug("clicked RoomItem roomId : ${roomId}");

    BlocManager.getBloc<ArchivedRoomsBloc>()?.add(OpenArchiveRoomEvent(roomId));
  }

}
