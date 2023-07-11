import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/square/square_bloc.dart';
import 'package:square_web/bloc/square/trending_square_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/custom_dropdown/custom_divider.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/square/square_item.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class PublicSquareListPage extends StatefulWidget {
  const PublicSquareListPage({Key? key}) : super(key: key);

  @override
  _PublicSquareListPageState createState() => _PublicSquareListPageState();
}

class _PublicSquareListPageState extends State<PublicSquareListPage> {
  ScrollDefault _scrollDefault = ScrollDefault();
  late PublicSquareBloc publicSquareBloc;
  late TrendingSquareBloc trendingSquareBloc;

  Timer? retryTimer;
  int _toggleSelectIndex = 0;

  @override
  void initState() {
    super.initState();
    publicSquareBloc = PublicSquareBloc(playerId: MeModel().playerId!)..add(InitSquare());
    BlocManager.addBloc(publicSquareBloc);

    trendingSquareBloc = TrendingSquareBloc();
    BlocManager.addBloc(trendingSquareBloc);

    _scrollDefault.init(onLoadMore: () {
      publicSquareBloc.add(LoadSquare());
    });

    publicSquareBloc.stream.listen((state) {
      if (state is LoadedSquareState) {
        if (NftQueueStatus.isRunning(state.queueStatus) || state.queueStatus == null && state.errorCode != Chain.notSupportChainErrorCode) {
          retryTimer?.cancel();
          retryTimer = Timer(Duration(seconds: Chain.loadNftRetryDelaySeconds), () {
            publicSquareBloc.add(LoadSquare());
          });
        } else if (state.queueStatus == NftQueueStatus.done) {
          retryTimer?.cancel();
          retryTimer = null;

        }
      }
    });

  }

  @override
  void dispose() {
    retryTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    bool isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;

    LogWidget.info("square list rebuild!");
    return LayoutBuilder(builder: (context, constraints) {
      final double pageWidth = constraints.maxWidth;
      final int crossAxisCount = (pageWidth / 300).round();

      return GestureDetector(
        onTap: () => HomeNavigator.tapOutSideOfTwoDepthPopUp(),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Column(children: [
            Expanded(
                child: CustomScrollView(
                    controller: _scrollDefault.controller,
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<SquareBloc, SquareState>(
                          bloc: publicSquareBloc,
                          builder: (context, state) {

                            List<Widget> children = [];

                            if (state is LoadedSquareState) {
                              List<SquareModel> squares = state.squareList;
                              children.addAll(_processSearch(squares));
                            }

                            return Column(
                              children: [
                                if(state is LoadedSquareState)
                                  Container(
                                    height: Zeplin.size(70),
                                    padding: EdgeInsets.symmetric(horizontal: 18),
                                    child: Row(
                                      children: [
                                        Text(L10n.square_01_05_nft_collection_square),
                                        Text(" ${state.totalCount}", style: TextStyle(color: CustomColor.azureBlue, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                                        SizedBox(width: Zeplin.size(5, isPcSize: true)),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap:  () => publicSquareBloc.add(RefreshSquare()),
                                            child: Icon36(Assets.img.ico_36_re_gy),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (state is LoadedSquareState && children.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: children.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return children[index];
                                      },
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: 0,
                                        childAspectRatio: 0.78,
                                      ),
                                    ),
                                  )
                                else if(state is LoadingSquareState)
                                  SizedBox(
                                    height: 300,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SquareCircularProgressIndicator(),
                                      ],
                                    ),
                                  ),

                                if (state is LoadedSquareState && ((state.queueStatus == null && state.errorCode != Chain.notSupportChainErrorCode) || NftQueueStatus.isRunning(state.queueStatus) || !state.hasReachedMax))
                                  SizedBox(
                                    height: 300,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SquareCircularProgressIndicator(),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(L10n.common_09_loading, style: TextStyle(color: Colors.grey))
                                      ],
                                    ),
                                  )
                                else if(state is LoadedSquareState && children.isEmpty)
                                  Container(
                                      height: Zeplin.size(400),
                                      child: Center(child: Text(L10n.square_01_22_no_accessible_square, style: TextStyle(fontSize: Zeplin.size(26), color: CustomColor.taupeGray, fontWeight: FontWeight.w500), textAlign: TextAlign.center)))
                              ],
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: CustomDivider()),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: Zeplin.size(70),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              Text(L10n.square_01_45_trending_square_title)
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: BlocBuilder<TrendingSquareBloc, TrendingSquareBlocState>(
                          bloc: trendingSquareBloc,
                          builder: (context, state) {

                            List<Widget> children = [];

                            if (state is LoadedState) {

                              List<SquareModel> squares = state.squaredMap.values.toList();
                              children.addAll(_processSearch(squares));

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: children.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return children[index];
                                  },
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    childAspectRatio: 0.78,
                                  ),
                                ),
                              );
                            }
                            else if(state is LoadingSquareState)
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SquareCircularProgressIndicator(),
                                ],
                              );

                            return SizedBox(
                              height: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SquareCircularProgressIndicator(),
                                ],
                              ),
                            );

                          },
                        ),
                      ),
                    ]
                )
            )
          ]),
        ),
      );
    });
  }

  List<SquareItem> _processSearch(List<SquareModel> squares) {
    return squares.map((e) => SquareItem(e, onTap: () => pushSquareChat(e))).toList();
  }

  void pushSquareChat(SquareModel square) async {

    HomeNavigator.clearTwoDepthPopUp();
    RoomManager().popActionRoom();

    SquareListPageHome.isIconView = false;

   /* SquareModel? squareModel = await SquareManager().getSquare(square.squareId);

    if(SquareManager().squareMap.containsKey(square.squareId)) {
      square.squareName = squareModel?.squareName;
      square.modTime = squareModel?.modTime;

      SquareManager().squareMap[square.squareId] = squareModel ?? square;
    }
*/
    if(mounted)
      setState(() {});

    HomeNavigator.push(RoutePaths.square.squareChat, arguments: square);
  }

}
