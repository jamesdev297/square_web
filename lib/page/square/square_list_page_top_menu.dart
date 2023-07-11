import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';

class SquareListPageTopMenu extends StatefulWidget {
  final ValueNotifier<SquareFolder> selectedSquareFolder;
  final Function showPage;
  final int pageIndex;

  const SquareListPageTopMenu({
    Key? key,
    required this.selectedSquareFolder,
    required this.showPage,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<SquareListPageTopMenu> createState() => _SquarePageTopMenuState();
}


class _SquarePageTopMenuState extends State<SquareListPageTopMenu> {
  bool isShown = false;
  GlobalKey globalKey = GlobalKey();
  SquareFolder selectedIndex = SquareFolder.secret;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedSquareFolder.value;

    screenWidthNotifier.addListener(() {
      if (isShown) {
        isShown = false;
        SquarePopUpMenu.hide;
        setState(() {});
      }
    });
  }

  void onShowFunc(bool isShow) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isShown = isShow;
    });
  }

  void onSelected(SquareFolder value) {
    widget.selectedSquareFolder.value = value;
    isShown = false;
    setState(() {});
  }

  Widget _buildSelectSquare() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              selectedIndex = SquareFolder.public;
              onSelected(SquareFolder.public);
            },
            child: Container(
              padding: EdgeInsets.only(bottom: Zeplin.size(17)),
              height: Zeplin.size(80),
              alignment: Alignment.topLeft,
              child: Text(L10n.square_04_01_public_square, style: TextStyle(color:selectedIndex == SquareFolder.public ? CustomColor.darkGrey : CustomColor.chatImageBorderGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(34))),
            ),
          ),
        ),
        SizedBox(width: Zeplin.size(30),),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              selectedIndex = SquareFolder.secret;
              onSelected(SquareFolder.secret);
            },
            child: Container(
              padding: EdgeInsets.only(bottom: Zeplin.size(17)),
              height: Zeplin.size(80),
              alignment: Alignment.topLeft,
              child: Text(L10n.square_04_01_secret_square, style: TextStyle(color: selectedIndex == SquareFolder.secret ? CustomColor.darkGrey : CustomColor.chatImageBorderGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(34))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstMenu() {
    bool isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;

    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: Row(
          children: [
            _buildSelectSquare(),
          ],
        )),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: Icon36(Assets.img.ico_36_search_gy),
              splashRadius: Zeplin.size(46),
              onPressed: () {
                widget.showPage(1);
              }),
        ),
      ],
    );
  }

  Widget _buildSecondMenu() {
    bool isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;

    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                  },
                  child: Icon46(Assets.img.ico_46_arrow_bk)
              ),
            )),
        Align(
            alignment: Alignment.topCenter,
            child: Text(L10n.square_01_14_square_search, style: centerTitleTextStyle)),
      ],
    );
  }

  Widget _buildNoTransition() {
    return widget.pageIndex == 0 ? _buildFirstMenu() : _buildSecondMenu();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: Padding(
          padding: EdgeInsets.only(
              top: Zeplin.size(32),
              left: Zeplin.size(16),
              right: Zeplin.size(16)),
          child: MeModel().showTransition ? AnimatedCrossFade(
            duration: Duration(milliseconds: 100),
            crossFadeState: widget.pageIndex == 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _buildFirstMenu(),
            secondChild: _buildSecondMenu(),
          ) : _buildNoTransition()
      ),
    );
  }
}