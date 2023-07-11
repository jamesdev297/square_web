import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/contact/recent_search_contact_bloc.dart';
import 'package:square_web/bloc/contact/search_contacts_bloc.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/profile_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/chat/twin_chat_button.dart';
import 'package:square_web/widget/contacts/add_contact_button.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/contacts/unblock_blocked_contact_button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';

class SearchContact extends StatefulWidget {
  final int pageIndex;
  final TabController? tabController;
  final bool isChatPage;
  const SearchContact({Key? key, this.isChatPage = false, required this.pageIndex, this.tabController}) : super(key: key);

  @override
  _SearchContactState createState() => _SearchContactState();
}

class _SearchContactState extends State<SearchContact> {
  final TextEditingDefault _textEditDefault = TextEditingDefault();
  final ScrollController _controller = ScrollController();
  late RecentSearchContactBloc _recentSearchContactBloc;
  late SearchContactsBloc _searchContactsBloc;
  FocusNode _focusNode = FocusNode();
  bool _isSearched = false;
  Timer? _searchTimer;
  String? lastLoggedKeyword;

  @override
  void initState() {
    super.initState();

    _recentSearchContactBloc = BlocManager.getBloc()!;
    _searchContactsBloc = BlocManager.getBloc()!;

    if(!MeModel().showTransition) {
      _recentSearchContactBloc.add(LoadEvent());
    }

    widget.tabController?.addListener(() {
      if(widget.tabController?.index == 0) {
        _recentSearchContactBloc.add(LoadEvent());
      }
    });

    _textEditDefault.init(
      "searchContacts",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text.trim();

        if(_textEditDefault.resultText.isEmpty) {
          _isSearched = false;
        }

        _searchTimer?.cancel();
        if(_textEditDefault.isComposing) {
          _recentSearchContactBloc.add(LoadingEvent());
          _searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
            _isSearched = true;
            _searchContactsBloc.add(SearchEvent(_textEditDefault.resultText));

            setState(() {});
          });
        } else {
          _recentSearchContactBloc.add(LoadEvent());
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant SearchContact oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.pageIndex != oldWidget.pageIndex) {
      if(widget.pageIndex != 1) {
        _recentSearchContactBloc.add(InitEvent());
      } else {
        Future.delayed(Duration(milliseconds: SquareTransition.defaultDuration + 100)).then((value) {
          _recentSearchContactBloc.add(LoadEvent());
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _recentSearchContactBloc.add(InitEvent());
    _searchContactsBloc.add(InitSearchContactsEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        HomeNavigator.tapOutSideOfTwoDepthPopUp();

        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(32), vertical: Zeplin.size(25)),
              child: SearchTextField(
                focusNode: _focusNode,
                textEditingDefault:  _textEditDefault,
                hintText: L10n.search_hint_01_add_new_address,
                onSubmitted: (text) => _searchContactsBloc.add(SearchEvent(_textEditDefault.resultText)),
                hasSuffixIcon: true,
              ),
            ),
            SizedBox(height: Zeplin.size(20)),
            Expanded(child: _isSearched == true ? _buildSearchedContact() : _buildRecentSearchContacts())
          ],
        )),
    );
  }

  void updateProfilePage(ContactModel contactModel) {
    PlayerProfileBloc? playerProfileBloc = ProfileManager().currentPlayerProfileBloc;
    if(playerProfileBloc?.playerId == contactModel.playerId) {
      playerProfileBloc?.add(ReloadPlayerProfileEvent(contactModel));
    }
  }

  Widget _buildTrailing(ContactModel contactModel, String? keyword) {
    if(contactModel.playerId == MeModel().playerId)
      return Container();
    else if(widget.isChatPage)
      return TwinChatButton(contactModel: contactModel, onTap: () {
        // sendAnalytics(contactModel.playerId, keyword);
        // HomeNavigator.pop(targetPage: widget.rootPage);
      },);
    else if(contactModel.friendTime != null)
      return SizedBox(
        width: Zeplin.size(65, isPcSize: true),
        height: Zeplin.size(30, isPcSize: true),
        child: PebbleRectButton(
          onPressed: () {
            // sendAnalytics(contactModel.playerId, keyword);
            SquareRoomDialog.showRemoveContactOverlay(contactModel, successFunc: () {
              contactModel.friendTime = null;
              updateProfilePage(contactModel);
            });
          },
          backgroundColor: CustomColor.grey3,
          borderColor: CustomColor.grey3,
          child: Text(L10n.profile_01_07_delete_contact, style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true),
              fontWeight: FontWeight.w500, color: Colors.black)),
        ),
      );
    else if(contactModel.relationshipStatus == RelationshipStatus.blocked)
      return UnblockBlockedContactButton(
          contactModel: contactModel, playerProfileBloc: PlayerProfileBloc(contactModel.playerId), successFunc: () {
        contactModel.relationshipStatus = RelationshipStatus.removed;
        updateProfilePage(contactModel);
      }, hasRounded: false);
    else
      return AddContactButton(
        contactModel: contactModel, successFunc: (_) {
        updateProfilePage(contactModel);
        }, hasRounded: false);
    return Container();
  }

  Widget _buildSearchedContact() {

    return BlocBuilder<SearchContactsBloc, SearchContactsBlocState>(
      bloc: BlocManager.getBloc(),
      builder: (context, state) {
        if(state is SearchContactsLoaded) {
          List<ContactModel>? searchContacts = state.contactMap.values.toList();

          if(state.hasReachedMax == false && searchContacts.isEmpty) {
            _searchContactsBloc.add(SearchEvent(_textEditDefault.resultText));

            return buildCircularProgressIndicator();
          }

          if(searchContacts != null && searchContacts.isNotEmpty)
            return BlocBuilder<SelectedContactBloc,UpdateState>(
              bloc: ContactManager().selectedContactBloc,
              builder: (context, selectedContactState) {

                if(selectedContactState is UpdateInitial) {

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Zeplin.size(32)),
                        child: Row(
                          children: [
                            Text(L10n.chat_open_05_01_search_result, style: TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchContacts.length,
                          itemBuilder: (BuildContext context, int index) {

                            ContactModel contactModel = searchContacts[index];

                            if(state.hasReachedMax == false && index == searchContacts.length-1) {
                              _searchContactsBloc.add(SearchEvent(_textEditDefault.resultText));
                            }

                            return ContactItem(
                              isSelected: selectedContactState.param == contactModel.playerId,
                              contactModel: contactModel,
                              onTap: () {
                                if(selectedContactState.param == contactModel.playerId) {
                                  return ;
                                }

                                ContactManager().selectedContactBloc.add(Update(param: contactModel.playerId));

                                if(searchContacts != null) {
                                  _recentSearchContactBloc.add(AddEvent(contactModel));
                                }

                                sendAnalytics(contactModel.playerId, state.keyword);
                                HomeNavigator.push(RoutePaths.profile.player, arguments: contactModel.playerId);
                              },
                              trailingWidget: _buildTrailing(contactModel, state.keyword),
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
                return Container();
              }
            );
          else
            return Column(
              children: [
                SizedBox(height: Zeplin.size(84)),
                Text(L10n.chat_open_04_01_no_result_title, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(30), fontWeight: FontWeight.w500)),
                SizedBox(height: Zeplin.size(20)),
                Text(L10n.chat_open_04_02_no_result_content, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500)),
              ],
            );
        } else if(state is SearchContactsError) {
          return Center(child: Text(L10n.common_01_error_content));
        }

        return buildCircularProgressIndicator();
      }
    );
  }

  void sendAnalytics(String playerId, String? keyword) {
    if(keyword?.isNotEmpty ?? false) {
      if(lastLoggedKeyword != keyword) {
        lastLoggedKeyword = keyword;
      }
    }
  }

  Widget _buildRecentSearchContacts() {
    return Column(
      children: [
        BlocBuilder<RecentSearchContactBloc, RecentSearchContactBlocState>(
          bloc: _recentSearchContactBloc,
          builder: (context, state) {
            if(state is RecentSearchContactInitial || state is RecentSearchContactLoading) {
              return buildCircularProgressIndicator();
            }

            if(state is RecentSearchContactLoaded) {

              if(state.recentSearchPlayerList == null || state.recentSearchPlayerList!.isEmpty)
                return Container();

              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  controller: _controller,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                      child: Row(
                        children: [
                          Text(L10n.chat_open_02_04_recent_search, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: Colors.black)),
                          Spacer(),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                SquareDefaultDialog.showSquareDialog(
                                  barrierColor: Colors.black.withOpacity(0.4),
                                  barrierDismissible: false,
                                  title: L10n.common_37_delete_history_title,
                                  content: Text(L10n.common_38_delete_history_content, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                                  button1Action: () => Navigator.of(context).pop(),
                                  button1Text: L10n.common_03_cancel,
                                  button2Action: () {
                                    Navigator.of(context).pop();
                                    _recentSearchContactBloc.add(RemoveAllEvent());
                                  },
                                  button2Text: L10n.common_02_confirm,
                                );
                              },
                              child: Text(L10n.chat_open_02_05_delete_all, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: CustomColor.taupeGray))
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: Zeplin.size(20)),
                    BlocBuilder<SelectedContactBloc, UpdateState>(
                      bloc: ContactManager().selectedContactBloc,
                      builder: (context, selectedContactState) {
                        if(selectedContactState is UpdateInitial)
                          return Column(
                            children: state.recentSearchPlayerList!.map((e) => ContactItem(
                              isSelected: selectedContactState.param == e.playerId,
                              contactModel: e,
                              onTap: () {
                                if(selectedContactState.param == e.playerId) {
                                  return ;
                                }

                                ContactManager().selectedContactBloc.add(Update(param: e.playerId));
                                HomeNavigator.push(RoutePaths.profile.player, arguments: e.playerId);
                              },
                              trailingWidget: Row(
                                children: [
                                  _buildTrailing(e, null),
                                  SizedBox(width: Zeplin.size(28)),
                                  InkWell(
                                    customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    onTap: () => _recentSearchContactBloc.add(RemoveEvent(e.playerId)),
                                    child: Icon24(Assets.img.ico_26_close_gy),
                                  ),
                                ],
                              ),
                              forceShowTrailing: true,
                            )).toList(),
                          );

                        return Container();
                      }
                    )
                  ],
                ),
              );
            }

            return Container();
          },
        ),
      ],
    );
  }

  Widget buildCircularProgressIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: Zeplin.size(55, isPcSize: true)),
      child: SquareCircularProgressIndicator());
  }

}
