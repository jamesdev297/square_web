import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/my_nft_list_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/no_search_result_culum.dart';
import 'package:square_web/widget/nft/nft_item.dart';
import 'package:square_web/widget/sliver_list_with_searchbar.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class MyNftListPage extends StatefulWidget with HomeWidget {
  final Function(dynamic)? successFunc;
  MyNftListPage({this.successFunc});
  late MyNftListBloc myNftListBloc;

  @override
  String pageName() => "MyNftListPage";

  @override
  _MyNftListPageState createState() => _MyNftListPageState();

  @override
  MenuPack get getMenuPack => MenuPack(
      centerMenu: Text(L10n.my_07_01_select_profile_image, style: centerTitleTextStyle),
      padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)),
      rightMenu: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            myNftListBloc.add(InitMyNftList());
            HomeNavigator.pop();
          },
          child: Icon46(Assets.img.ico_46_x_bk),
        ),
      ));

  @override
  HomeWidgetType get widgetType => HomeWidgetType.overlayPopUp;

  @override
  bool get dimmedBackground => true;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;

  @override
  double? get maxWidth => Zeplin.size(696, isPcSize: true);
}

class _MyNftListPageState extends State<MyNftListPage> {
  TextEditingDefault _textEditDefault = TextEditingDefault();
  FocusNode _focusNode = FocusNode();
  late int crossCount;
  late double itemWidth;
  Timer? retryTimer;
  Timer? searchTimer;

  @override
  void initState() {
    super.initState();
    widget.myNftListBloc = BlocManager.getBloc()!..add(LoadMyNftList());

    _textEditDefault.init(
      "myNftList",
      this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        _textEditDefault.resultText = text;
        BlocManager.getBloc<MyNftListBloc>()!.add(LoadingMyNftList());

        searchTimer?.cancel();
        searchTimer = Timer(Duration(milliseconds: searchLoadingMilliseconds), () {
          BlocManager.getBloc<MyNftListBloc>()!.add(LoadMyNftList(keyword: text.trim()));
        });

      },
    );

    widget.myNftListBloc.stream.listen((state) {
      if(state is LoadedMyNftListState) {
        if(NftQueueStatus.isRunning(state.queueStatus) || state.queueStatus == null) {
          retryTimer?.cancel();
          retryTimer = Timer(Duration(seconds: Chain.loadNftRetryDelaySeconds), () {
            widget.myNftListBloc.add(LoadMyNftList());
          });
        }
      }
    });
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    _textEditDefault.controller.dispose();
    _focusNode.dispose();
    searchTimer?.cancel();
    searchTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LogWidget.info("my nft list rebuild!");
    return LayoutBuilder(builder: (context, constraints) {
      final double pageWidth = constraints.maxWidth;
      crossCount = (pageWidth / 200).round();
      itemWidth = pageWidth / crossCount;
      return GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.only(top: Zeplin.size(110)),
            child: BlocBuilder(
             bloc: widget.myNftListBloc,
             builder: (context, state) {
               if(state is LoadedMyNftListState || (state is LoadingMyNftListState && _textEditDefault.resultText.isNotEmpty)) {
                 if((state is LoadedMyNftListState && state.nftList.isEmpty && (state.keyword?.isEmpty ?? true))) {
                   return Center(child: Text(L10n.my_08_01_no_has_nft, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30))));
                 }
                 return SliverListWithSearchBar(
                     sliverPadding: EdgeInsets.only(top: Zeplin.size(12, isPcSize: true),
                         left: Zeplin.size(14, isPcSize: true),
                         right: Zeplin.size(14, isPcSize: true)),
                     onLoadMore: () {
                       widget.myNftListBloc.add(LoadMyNftList());
                     },
                     onBottom: () {
                       widget.myNftListBloc.add(LoadMyNftList());
                     },
                     headerSize: 0,
                     searchBarSize: Zeplin.size(110),
                     focusNode: _focusNode,
                     textEditDefault: _textEditDefault,
                     searchBarHintText: L10n.square_01_06_search_address_collection,
                     slivers: [
                       BlocBuilder<MyNftListBloc, MyNftListState>(
                           bloc: widget.myNftListBloc,
                           builder: (context, state) {
                             LogWidget.debug("SquareBloc state $state ${DeviceUtil.screenWidth}");
                             List<Widget> children = [];

                             if (state is LoadedMyNftListState) {
                               List<PlayerNftModel> nftModels = state.nftList;
                               if(nftModels.isEmpty && _textEditDefault.isComposing == true)
                                 return SliverFillRemaining(
                                   child: NoSearchResultColumn(),
                                 );
                               children.addAll(_processSearch(nftModels));
                             }
                             return SliverGrid.count(
                                 crossAxisCount: (pageWidth / 158).round(),
                                 childAspectRatio: 0.7,
                                 children: children);
                           }),
                       BlocBuilder<MyNftListBloc, MyNftListState>(
                           bloc: widget.myNftListBloc,
                           builder: (context, state) {
                             Widget child = Container();
                             Widget loadingChild = Padding(
                               padding: const EdgeInsets.only(top: 50),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   SizedBox(
                                     width: 50,
                                     height: 50,
                                     child: SquareCircularProgressIndicator(),
                                   ),
                                 ],
                               ),
                             );

                             if (state is LoadingMyNftListState) {
                               child = loadingChild;
                             }else if (state is LoadedMyNftListState) {
                               LogWidget.debug("LoadedMyNftListState bottom ${state.queueStatus} ${state.hasReachedMax}");
                               if (NftQueueStatus.isRunning(state.queueStatus) || !state.hasReachedMax) {
                                 child = loadingChild;
                               }
                             }
                             return SliverList(delegate: SliverChildBuilderDelegate((context, index) => child, childCount: 1));
                           })
                     ]);
               } else if (state is LoadingMyNftListState) {
                 return Center(
                   child: SizedBox(width: 50, height: 50, child: SquareCircularProgressIndicator()),
                 );
               }
               return Container();
             },
            ),
          ),
        ),
      );
    });
  }

  List<NftItem> _processSearch(List<PlayerNftModel> nftList) {

    if (_textEditDefault.resultText.isEmpty)
      return nftList.map((e) => NftItem(e, itemWidth, successFunc: widget.successFunc)).toList();

    return nftList.where((e) => (e.nftName != null && e.nftName!.toLowerCase().contains(_textEditDefault.resultText.trim().toLowerCase())))
      .map((e) => NftItem(e, itemWidth, successFunc: widget.successFunc)).toList();
  }
}
