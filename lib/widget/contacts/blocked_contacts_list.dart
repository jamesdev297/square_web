import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

import 'unblock_blocked_contact_button.dart';

class BlockedContactsList extends StatefulWidget {
  BlockedContactsList({Key? key}) : super(key: key);

  @override
  _BlockedContactsListState createState() => _BlockedContactsListState();
}

class _BlockedContactsListState extends State<BlockedContactsList> {
  ScrollController _scrollController = ScrollController();
  TextEditingDefault _textEditDefault = TextEditingDefault();
  FocusNode _focusNode = FocusNode();
  Timer? searchTimer;

  @override
  void initState() {
    super.initState();

    BlocManager.getBloc<BlockedContactsBloc>()!.add(LoadBlockedContactsEvent(MeModel().playerId!));

    _textEditDefault.init(
      "blockContact",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<BlockedContactsBloc>()!.add(LoadBlockedContactsEvent(MeModel().playerId!, keyword: text.trim().toLowerCase()));
        });
      },
    );

    _scrollController.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditDefault.controller.dispose();
    BlocManager.getBloc<BlockedContactsBloc>()!.add(InitBlockedContactsEvent());
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
          child: BlocBuilder<BlockedContactsBloc, BlockContactsBlocState>(
            bloc: BlocManager.getBloc(),
            builder: (context, state) {

              if (state is BlockContactsInitial || state is BlockContactsLoading) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                  ],
                );
              }

              if(state is BlockContactsError) {
                return Center(child: Text(L10n.common_01_error_content));
              }

              if(state is BlockContactsLoaded) {

                List<ContactModel> blockFriendList = state.blockedPlayerMap.values.toList();

                if(state.totalCount! == 0 && blockFriendList.isEmpty)
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: Zeplin.size(130)),
                        Text(L10n.contacts_02_03_block_empty, style: TextStyle(fontSize: Zeplin.size(30), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), textAlign: TextAlign.center),
                      ],
                    ),
                  );

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(12)),
                        child: SearchTextField(
                          focusNode: _focusNode,
                          textEditingDefault:  _textEditDefault,
                          hintText: L10n.chat_open_02_03_search_nickname_wallet,
                          onSubmitted: (text) {},
                          hasSuffixIcon: true,
                        ),
                      ),
                    ),

                    if(blockFriendList.isEmpty)
                      SliverToBoxAdapter(child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: DeviceUtil.screenHeight - Zeplin.size(93, isPcSize: true)),
                          child: NoSearchResultColumn()))
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {

                          ContactModel contactModel = blockFriendList[index];

                          if(state.hasReachedMax == false && index == blockFriendList.length-1) {
                            BlocManager.getBloc<BlockedContactsBloc>()!.add(LoadBlockedContactsEvent(MeModel().playerId!));
                          }

                          return ContactItem(
                            contactModel: contactModel,
                            onTap: () => HomeNavigator.push(RoutePaths.profile.player, arguments: contactModel.playerId),
                            trailingWidget: UnblockBlockedContactButton(contactModel: contactModel, hasRounded: false),
                          );
                        },
                        childCount: blockFriendList.length)
                      ),
                  ],
                );
              }

              return Container();
            }
          ),
        )
      ],
    ));
  }
}
