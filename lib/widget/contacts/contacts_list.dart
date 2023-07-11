import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/chat/twin_chat_button.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/contacts/my_profile_item.dart';
import 'package:square_web/custom_dropdown/custom_divider.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/toggle_widget.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

class ContactsList extends StatefulWidget {
  final Function? showPage;
  final bool isContactsPage;

  ContactsList({Key? key, this.isContactsPage = false, this.showPage}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {

  final List<String> _toggleList = [L10n.contacts_01_04_abc, L10n.contacts_01_05_online];
  ScrollController _scrollController = ScrollController();
  TextEditingDefault _textEditDefault = TextEditingDefault();
  int _toggleSelectIndex = 0;
  FocusNode _focusNode = FocusNode();
  Timer? searchTimer;

  @override
  void initState() {
    super.initState();

    BlocManager.getBloc<ContactsBloc>()!.add(InitLoadContactsEvent(MeModel().playerId!));

    _textEditDefault.init(
      "contactsList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<ContactsBloc>()!.add(LoadContactsEvent(MeModel().playerId!, keyword: text.trim().toLowerCase()));
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
    ContactManager().selectedContactBloc.add(Update());
    _focusNode.dispose();
    _scrollController.dispose();
    _textEditDefault.controller.dispose();
    searchTimer?.cancel();
    searchTimer = null;
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
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<ContactsBloc, ContactsBlocState>(
                bloc: BlocManager.getBloc(),
                builder: (BuildContext context, friendState) {
                  if (friendState is ContactsInitial || friendState is ContactsLoading) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                      ],
                    );
                  }

                  if(friendState is ContactsError) {
                    return Center(child: Text(L10n.common_01_error_content));
                  }

                  if (friendState is ContactsLoaded) {
                    LogWidget.debug("CONTACT state is $friendState");

                    List<ContactModel> contacts = friendState.contactMap.values.toList();
                    int totalCount = friendState.totalCount ?? 0;
                    ContactModelPool().sortContacts(_toggleSelectIndex, contacts);

                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        if(totalCount > 0 || _textEditDefault.isComposing)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: Zeplin.size(34), right: Zeplin.size(34), top: Zeplin.size(12), bottom: Zeplin.size(40)),
                              child: SearchTextField(
                                focusNode: _focusNode,
                                textEditingDefault:  _textEditDefault,
                                hintText: L10n.search_hint_01_contacts_list,
                                hasSuffixIcon: true,
                              ),
                            ),
                          ),
                        if(totalCount == 0)
                          SliverToBoxAdapter(child: SizedBox(height: Zeplin.size(60))),
                        if(widget.isContactsPage && !_textEditDefault.isComposing)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: Zeplin.size(34), bottom: Zeplin.size(10)),
                              child: Row(
                                children: [
                                  Text(L10n.contacts_01_03_my_profile, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)))
                                ],
                              ),
                            ),
                          ),
                        if(widget.isContactsPage && !_textEditDefault.isComposing)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                MyProfileItem(),
                                SizedBox(height: Zeplin.size(20)),
                                CustomDivider(),
                                SizedBox(height: Zeplin.size(20)),
                              ],
                            ),
                          ),
                        if(!_textEditDefault.isComposing)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                              child: Row(
                                children: [
                                  Text(L10n.contacts_01_06_contacts(friendState.totalCount ?? 0), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                                  Spacer(),
                                  if(totalCount > 0)
                                    ToggleWidget(
                                      initialLabel: _toggleSelectIndex,
                                      activeBgColor: CustomColor.azureBlue,
                                      activeTextColor: CustomColor.azureBlue,
                                      inactiveBgColor: CustomColor.paleGrey,
                                      inactiveTextColor: CustomColor.blueyGrey,
                                      labels: _toggleList,
                                      onToggle: (index) {
                                        _toggleSelectIndex = index;
                                        closeInputField();
                                        setState(() {});
                                      },
                                    )
                                ],
                              ),
                            ),
                          ),
                        if(totalCount > 0 || _textEditDefault.isComposing)
                          _buildContactsList(contacts, friendState)
                        else
                          _buildEmptyContactsList()
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


  Widget _buildEmptyContactsList() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: Zeplin.size(110)),
          Text(L10n.contacts_04_01_empty, style: TextStyle(fontSize: Zeplin.size(30), fontWeight: FontWeight.w500, color: Colors.black), textAlign: TextAlign.center),
          SizedBox(height: Zeplin.size(10)),
          Text(L10n.contacts_04_02_empty_content, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), textAlign: TextAlign.center),
          SizedBox(height: Zeplin.size(40)),

          if(HomeNavigator.currentTab.value != TabCode.chat)
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
                    Icon46(Assets.img.ico_46_fri_we),
                    SizedBox(width: Zeplin.size(10)),
                    Text(L10n.contacts_04_03_add_contact, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactsList(List<ContactModel> contacts, ContactsLoaded friendState) {

    if(contacts.isEmpty)
      return SliverToBoxAdapter(child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: DeviceUtil.screenHeight - Zeplin.size(93, isPcSize: true)),
          child: NoSearchResultColumn()));

    return BlocBuilder<SelectedContactBloc, UpdateState>(
        bloc: ContactManager().selectedContactBloc,
        builder: (context, state) {
          if (state is UpdateInitial) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {

                ContactModel contactModel = contacts[index];

                if(friendState.hasReachedMax == false && index == contacts.length-1) {
                  BlocManager.getBloc<ContactsBloc>()!.add(LoadContactsEvent(MeModel().playerId!));
                }

                return ContactItem(
                  isSelected: state.param == contactModel.playerId,
                  contactModel: contactModel,
                  onTap: () {
                    if(state.param == contactModel.playerId) {
                      return ;
                    }
                    HomeNavigator.push(RoutePaths.profile.player, arguments: contactModel.playerId);
                    setState(() {
                      ContactManager().selectedContactBloc.add(Update(param: contactModel.playerId));
                    });
                  },
                  trailingWidget: widget.isContactsPage == false ? TwinChatButton(contactModel: contactModel) : null,
                );
              },
              childCount: contacts.length)
            );
          };
          return Container();
        });
  }

  void closeInputField() {
    if (_focusNode.hasFocus) _focusNode.unfocus();
    _textEditDefault.resultText = "";
    _textEditDefault.resetOnSubmit("");
  }
}
