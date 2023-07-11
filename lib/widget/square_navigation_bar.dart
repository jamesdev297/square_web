import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/common/navi_blue_dot_builder.dart';

class SquareNavigationBar extends StatefulWidget {
  final TabController tabController;
  final int? selectedIndex;
  final ValueChanged<int> indexChanged;

  SquareNavigationBar(this.tabController, this.selectedIndex, this.indexChanged);

  @override
  State<SquareNavigationBar> createState() => _SquareNavigationBarState();
}

class _SquareNavigationBarState extends State<SquareNavigationBar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.tabController.index = widget.selectedIndex ?? 0;
  }

  @override
  void didChangeDependencies() {
    tabIconManager.precache(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /* Container(
            padding: EdgeInsets.symmetric(vertical: Zeplin.size(37)),
            child: SizedBox(
              height: Zeplin.size(34),
              child: Image.asset(Assets.img.square_black_logo),
            ),
          ),*/
        Container(
          color: Colors.white,
          height: Zeplin.size(90),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, -1),
                  child: Container(
                    color: CustomColor.paleLilac.withOpacity(0.7),
                    height: Zeplin.size(1.8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TabBar(
                  controller: widget.tabController,
                  onTap: (index) {
                    widget.indexChanged(index);
                  },
                  tabs : <Widget>[
                    Tab(icon: Stack(
                      children: [
                        tabIconManager.call(widget.selectedIndex!, TabCode.chat),
                        NaviBlueDotBuilder(tabCode: TabCode.chat)
                      ],
                    ), ),
                    Tab(icon: tabIconManager.call(widget.selectedIndex!, TabCode.square),),
                    Tab(icon: tabIconManager.call(widget.selectedIndex!, TabCode.contacts),),
                    Tab(icon: tabIconManager.call(widget.selectedIndex!, TabCode.more),),
                  ],
                  indicatorColor: Colors.black,
                ),
              ),

            ],
          ),
        ),

      ],
    );
  }
}
