import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc.dart';
import 'package:square_web/bloc/room/rooms_bloc_event.dart';
import 'package:square_web/bloc/room/rooms_bloc_state.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/chat/room_item.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';

class RoomList extends StatefulWidget {
  final Function? showPage;
  final FocusNode focusNode;

  const RoomList({Key? key, required this.focusNode, this.showPage}) : super(key: key);

  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  ScrollController _scrollController = ScrollController();
  TextEditingDefault _textEditDefault = TextEditingDefault();
  Timer? searchTimer;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    LogWidget.debug("Room List INIT");

    BlocManager.getBloc<RoomsBloc>()!.add(InitLoadRoomsEvent(MeModel().playerId!));

    _textEditDefault.init(
      "roomList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<RoomsBloc>()!.add(LoadRoomsEvent(MeModel().playerId!, keyword: text.trim().toLowerCase()));
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
          SizedBox(height: Zeplin.size(85)),
          Expanded(
            child: BlocBuilder<RoomsBloc, RoomsBlocState>(
              bloc: BlocManager.getBloc(),
              builder: (context, state) {
                LogWidget.debug("RoomsBloc state $state");
                if (state is RoomsLoading || state is RoomsUninitialized) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                    ],
                  );
                } else if (state is RoomsError) {
                  return Center(child: Text(L10n.common_01_error_content));
                } else if (state is RoomsLoaded) {

                  if (state.totalCount! == 0 && state.roomMap.isEmpty && !_textEditDefault.isComposing) {
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(height: Zeplin.size(50)),
                          Text(L10n.chat_open_01_01_empty, style: TextStyle(fontSize: Zeplin.size(30), fontWeight: FontWeight.w500, color: Colors.black), textAlign: TextAlign.center),
                          SizedBox(height: Zeplin.size(20)),
                          Text(L10n.chat_open_01_02_empty_content,
                              style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: CustomColor.outlineGrey), textAlign: TextAlign.center),
                          SizedBox(height: Zeplin.size(40)),
                          Container(
                            padding: EdgeInsets.only(left: Zeplin.size(34), right: Zeplin.size(34)),
                            constraints: BoxConstraints(maxWidth: Zeplin.size(400)),
                            height: Zeplin.size(84),
                            child: PebbleRectButton(
                              onPressed: () {
                                widget.showPage?.call(1);
                              },
                              backgroundColor: CustomColor.azureBlue,
                              borderColor: CustomColor.azureBlue,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon46(Assets.img.ico_46_talk_we),
                                  SizedBox(width: Zeplin.size(10)),
                                  Text(L10n.chat_open_01_03_start_new_chat, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  List<RoomItem> list = _searchRooms(RoomManager().sortedRooms(state.roomMap.values.toList()));

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
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
                              BlocManager.getBloc<RoomsBloc>()!.add(LoadRoomsEvent(MeModel().playerId!));
                            }

                            return list[index];
                          },
                          childCount: list.length)
                        ),
                    ]
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
    if (_textEditDefault.resultText.isEmpty) return rooms.map((e) => RoomItem(e, onTap)).toList();

    return rooms.where((e) => (e.searchName?.toLowerCase() ?? "").contains(_textEditDefault.resultText.toLowerCase()))
      .map((e) => RoomItem(e, onTap))
      .toList();
  }

  void onTap(String roomId) {
    LogWidget.debug("clicked RoomItem roomId : ${roomId}");

    BlocManager.getBloc<RoomsBloc>()?.add(OpenRoomEvent(roomId));
  }

}
