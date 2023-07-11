import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/ai/search_ai_player_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/contacts/contact_item.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class SelectAiPlayerPage extends StatefulWidget with HomeWidget {
  final Function(int) onPrevious;
  final Function(ContactModel) onSelectAiPlayer;
  String aiPlayerId;
  SelectAiPlayerPage({Key? key, required this.onPrevious, required this.onSelectAiPlayer, required this.aiPlayerId}) : super(key: key);

  @override
  _SelectAiPlayerPageState createState() => _SelectAiPlayerPageState();

  @override
  MenuPack get getMenuPack => MenuPack(centerMenu: Text(L10n.ai_01_choose_ai, style: centerTitleTextStyle));

  @override
  String pageName() => "SelectAiPlayerPage";

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;
}

class _SelectAiPlayerPageState extends State<SelectAiPlayerPage> {

  SearchAiPlayerBloc searchAiPlayerBloc = SearchAiPlayerBloc();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    searchAiPlayerBloc.add(SearchAiPlayerEvent(""));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: Zeplin.size(34), horizontal: Zeplin.size(25)),
            child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => widget.onPrevious(0),
                      child: Icon46(Assets.img.ico_46_arrow_bk),
                    ),
                  ),
                  Spacer(),
                ]
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchAiPlayerBloc, SearchAiPlayerBlocState>(
                bloc: searchAiPlayerBloc,
                builder: (BuildContext context, state) {
                  if (state is SearchAiPlayerInitial) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80)),
                      ],
                    );
                  }

                  if(state is SearchAiPlayerError) {
                    return Center(child: Text(L10n.common_01_error_content));
                  }

                  if (state is SearchAiPlayerLoaded) {
                    LogWidget.debug("SearchAiPlayerBloc state is $state");

                    ContactModel selectedPlayer = state.contactMap[widget.aiPlayerId]!;

                    List<ContactModel> contacts = state.contactMap.values.where((ContactModel value) => selectedPlayer.playerId != value.playerId).toList();
                    ContactModelPool().sortContacts(0, contacts);

                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        _buildContactsList([selectedPlayer] + contacts)
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


  Widget _buildContactsList(List<ContactModel> contacts) {

    if(contacts.isEmpty)
      return SliverToBoxAdapter(child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: DeviceUtil.screenHeight - Zeplin.size(93, isPcSize: true)),
        child: NoSearchResultColumn()));

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        ContactModel contact = contacts[index];
        return ContactItem(
          contactModel: contact,
          onTap: ()  {
            widget.aiPlayerId = contact.playerId;
            widget.onSelectAiPlayer(contact);

            setState(() {});
          },
        );
      }, childCount: contacts.length)
    );
  }
}
