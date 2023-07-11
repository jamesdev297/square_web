import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/square/square_search_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/square/square_item.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';

class SquareSearchPage extends StatefulWidget with HomeWidget {
  final Function? showPage;

  SquareSearchPage({this.showPage}) : super();

  @override
  TabCode get targetNavigator => TabCode.square;

  @override
  void resetWidget() {}

  @override
  State createState() => SquareSearchPageState();

  @override
  Future<void> onTopWidgetAction() async {}

  @override
  Future<void> beforePushAction() async {}

  @override
  String pageName() => "SquareSearchPage";

  @override
  MenuPack get getMenuPack => MenuPack(
      padding: EdgeInsets.only(top: Zeplin.size(30)),
      leftMenu: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () => HomeNavigator.pop(targetPage: this),
            child: Icon46(Assets.img.ico_46_arrow_bk)
        ),
      ),
      title: Text(L10n.square_01_14_square_search, style: centerTitleTextStyle),
      );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  bool get isInternalImplement => true;

}

class SquareSearchPageState extends State<SquareSearchPage> {
  TextEditingDefault _textEditDefault = TextEditingDefault();
  FocusNode _focusNode = FocusNode();
  ScrollDefault _scrollDefault = ScrollDefault();
  SquareSearchBloc squareSearchBloc = SquareSearchBloc()..add(InitSquareSearch());
  Timer? searchDelayer;

  @override
  void initState() {
    super.initState();
    _scrollDefault.init();
    _textEditDefault.init(
      "squareSearchList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;
        searchDelayer?.cancel();
        if (text.isEmpty) {
          squareSearchBloc.add(ResetSquareSearch());
        } else {
          searchDelayer = Timer(Duration(milliseconds: 500), () {
            if(_textEditDefault.resultText.isNotEmpty)
              squareSearchBloc.add(SearchSquare(text, fromAll: true));
          });
        }
      },
    );

    _scrollDefault.init(onLoadMore: () {
      squareSearchBloc.add(LoadMoreSquare());
    });

    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.showPage?.call(0);
      }
    });*/
  }

  @override
  void dispose() {
    _textEditDefault.controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildPadding(Widget sliver) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: sliver,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          HomeNavigator.tapOutSideOfTwoDepthPopUp();

          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: Zeplin.size(83)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(12)),
                  child: SearchTextField(
                    focusNode: _focusNode,
                    textEditingDefault:  _textEditDefault,
                    hintText: L10n.search_hint_01_square_search_all,
                    hasSuffixIcon: true,
                  ),
                ),
                Expanded(
                    child: BlocBuilder<SquareSearchBloc, SquareSearchState>(
                        bloc: squareSearchBloc,
                        builder: (context, state) {
                          // LogWidget.debug("square searchState : $state");
                          List<Widget> children = [];
                          int crossAxisCount = (constraints.maxWidth / 300).round();
                          if (state is SquareSearching) {
                            children.add(SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                              return Container(
                                  alignment: Alignment.center, height: 300, child: SquareCircularProgressIndicator());
                            }, childCount: 1)));
                          } else if (state is SquareSearchRecent) {
                            if (state.recentSearchedList.isEmpty) {
                              children.add(SliverList(
                                  delegate: SliverChildBuilderDelegate((context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Text(L10n.square_01_44_square_search_content, style: TextStyle(fontSize: Zeplin.size(26), color: CustomColor.taupeGray, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                );
                              }, childCount: 1)));
                            } else {
                              children.add(SliverList(
                                  delegate: SliverChildBuilderDelegate((context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Zeplin.size(25), vertical: Zeplin.size(8)),
                                  child: Row(
                                    children: [
                                      Text(L10n.square_01_17_recent_search,
                                          style: TextStyle(
                                              color: CustomColor.darkGrey,
                                              fontSize: Zeplin.size(26),
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      TextButton(
                                          onPressed: () {
                                            SquareDefaultDialog.showSquareDialog(
                                                showBarrierColor: true,
                                                barrierDismissible: false,
                                                title: L10n.square_01_18_remove_recent_search,
                                                description: L10n.square_01_19_remove_recent_search_context,
                                                button1Text: L10n.common_03_cancel,
                                                button1Action: SquareDefaultDialog.closeDialog(),
                                                button2Text: L10n.common_02_confirm,
                                                button2Action: () {
                                                  squareSearchBloc.add(RemoveRecentSearchedSquare(removeAll: true));
                                                  SquareDefaultDialog.closeDialog().call();
                                                });
                                          },
                                          child: Text(L10n.square_01_22_remove_all,
                                              style: TextStyle(
                                                  color: CustomColor.taupeGray,
                                                  fontSize: Zeplin.size(26),
                                                  fontWeight: FontWeight.w500)))
                                    ],
                                  ),
                                );
                              }, childCount: 1)));
                              children.add(_buildPadding(SliverGrid.count(
                                crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                                childAspectRatio: 0.8,
                                children: state.recentSearchedList.reversed.map((e) => SquareItem(e,
                                  onTap: () => _onClickSquareItem(e, null),
                                  remove: () => squareSearchBloc.add(RemoveRecentSearchedSquare(squareId: e.squareId)),
                                )).toList(),
                              )));
                            }
                          } else if (state is SquareSearched) {
                            if (state.searchedMap.isEmpty) {
                              children.add(SliverList(
                                  delegate: SliverChildBuilderDelegate((context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: Zeplin.size(110)),
                                    Text(
                                      L10n.square_01_15_no_matches_found,
                                      style: TextStyle(
                                          fontSize: Zeplin.size(30),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: Zeplin.size(20)),
                                    Text(L10n.square_01_16_no_matches_found_context,
                                        style: TextStyle(
                                            fontSize: Zeplin.size(26),
                                            fontWeight: FontWeight.w500,
                                            color: CustomColor.taupeGray), textAlign: TextAlign.center),
                                    SizedBox(height: Zeplin.size(38),),
                                    PebbleRectButton(
                                        borderColor: CustomColor.grey3,
                                        backgroundColor: CustomColor.grey3,
                                        onPressed: () {
                                          squareSearchBloc.add(SearchSquare(_textEditDefault.resultText, fromAll: true));
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(40), vertical: Zeplin.size(24)),
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Image.asset(Assets.img.ico_46_re_gy, width: Zeplin.size(46),),
                                              SizedBox(width: Zeplin.size(10),),
                                              Text(L10n.common_49_refresh, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: CustomColor.grey4),)
                                            ],
                                          ),
                                        )
                                    )
                                  ],
                                );
                              }, childCount: 1)));
                            } else {
                              List<SquareModel> joinedSquareList = state.searchedMap.values.where((e) => e.joined ?? false).toList();
                              List<SquareModel> notJoinedSquareList = state.searchedMap.values.where((e) => !(e.joined ?? false)).toList();

                              if (joinedSquareList.isNotEmpty) {
                                children.add(SliverList(
                                    delegate: SliverChildBuilderDelegate((context, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: Zeplin.size(36), vertical: Zeplin.size(20)),
                                    child: Text(L10n.square_01_20_accessible_square,
                                        style: TextStyle(
                                            color: CustomColor.darkGrey,
                                            fontSize: Zeplin.size(26),
                                            fontWeight: FontWeight.w500)),
                                  );
                                }, childCount: 1)));
                                children.add(_buildPadding(SliverGrid.count(
                                  crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                                  childAspectRatio: 0.8,
                                  children: joinedSquareList.map((e) => SquareItem(e,
                                    onTap: () => _onClickSquareItem(e, state.keyword),
                                  )).toList(),
                                )));
                              }

                              if (notJoinedSquareList.isNotEmpty) {
                                children.add(SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: Zeplin.size(36), vertical: Zeplin.size(20)),
                                    child: Text(L10n.square_01_41_global_search, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500)),
                                  );
                                }, childCount: 1)));
                                children.add(_buildPadding(SliverGrid.count(
                                  crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                                  childAspectRatio: 0.8,
                                  children: notJoinedSquareList.map((e) => SquareItem(e,
                                    onTap: () => _onClickSquareItem(e, state.keyword),
                                  )).toList(),
                                )));
                                if(state.hasReachedMax == false)
                                  children.add(SliverToBoxAdapter(child: Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80))));
                              }
                            }
                          } else if (state is SquareSearchFail) {
                            children.add(SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                              return Container(
                                  alignment: Alignment.center, height: 500, child: Text(L10n.common_58_service_error, textAlign: TextAlign.center));
                            }, childCount: 1)));
                          }
                          return CustomScrollView(
                              controller: _scrollDefault.controller,
                              slivers: children);
                        }))
              ],
            ),
          ),
        ),
      );
    });
  }

  void _onClickSquareItem(SquareModel square, String? keyword) {
    SquareManager().clickSquare(square, joined: square.joined ?? false);

    squareSearchBloc.add(ClickSearchedSquare(square));
  }
}
