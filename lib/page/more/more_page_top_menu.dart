import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/share_link_chat.dart';
import 'package:square_web/widget/profile/qr_sign_in_button.dart';



class MorePageTopMenu extends StatefulWidget {
  final Function showPage;
  final int pageIndex;
  final HomeWidget rootWidget;

  const MorePageTopMenu({
    Key? key,
    required this.showPage,
    required this.pageIndex,
    required this.rootWidget,
  }) : super(key: key);

  @override
  State<MorePageTopMenu> createState() => _MorePageTopMenuState();
}


class _MorePageTopMenuState extends State<MorePageTopMenu> {
  int lastSecondPageIndex = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  Widget _buildFirstMenu() {
    return Container(
      color: Colors.white,
      height: Zeplin.size(78),
      padding: EdgeInsets.only(
          top: Zeplin.size(32),
          left: Zeplin.size(34),
          right: Zeplin.size(34)),
      child: Stack(
        children: [
          Align(alignment: Alignment.topLeft,
              child: Text(L10n.my_01_01_more, style: TextStyle(color: CustomColor.darkGrey,
                  fontWeight: FontWeight.w500, fontSize: Zeplin.size(34)))),
          Align(
            alignment: Alignment.topRight,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              children: [

                ShareLinkChat(walletAddress: MeModel().playerId!, rootWidget: widget.rootWidget, isSize36: true),
                SizedBox(width: Zeplin.size(30)),
                QRSignInButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondMenu() {
    if(lastSecondPageIndex == 2) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.only(
          top: Zeplin.size(32),
          left: Zeplin.size(34),
          right: Zeplin.size(34)),
      color: Colors.white,
      height: Zeplin.size(78),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(child: Icon46(Assets.img.ico_46_arrow_bk),
                  onTap: () {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                  },
                ),
              )),
          Align(
              alignment: Alignment.topCenter,
              child: Text(L10n.my_01_11_select_allow_message,
                  style: TextStyle(color: CustomColor.darkGrey,
                      fontSize: Zeplin.size(34),
                      fontWeight: FontWeight.w500))
          ),
        ],
      ),
    );
  }

  Widget _buildNoTransition() {
    if(widget.pageIndex == 0) {
      return _buildFirstMenu();
    }else if(widget.pageIndex == 1) {
      return _buildSecondMenu();
    }else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.pageIndex == 1 || widget.pageIndex == 2) {
      lastSecondPageIndex = widget.pageIndex;
    }

    return SafeArea(
      // minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: MeModel().showTransition ? AnimatedCrossFade(
        duration: Duration(milliseconds: 100),
        crossFadeState: widget.pageIndex >= 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildFirstMenu(),
        secondChild: _buildSecondMenu(),
      ) : _buildNoTransition()
    );
  }
}