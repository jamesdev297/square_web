import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/square/square_chat_message_bloc.dart';
import 'package:square_web/bloc/message_bloc_state.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/square/square_popup.dart';

import 'square_item.dart';

class SquareChatHeader extends StatelessWidget {
  final bool isSideNavi;
  final SquareModel squareModel;
  final String channel;
  final HomeWidget parent;
  final VoidCallback leaveFunc;
  final SquareChatMessageBloc messageBloc;
  const SquareChatHeader({Key? key, required this.isSideNavi, required this.squareModel, required this.channel, required this.parent, required this.leaveFunc, required this.messageBloc}) : super(key: key);


  void onTapSquareHeader() {
    HomeWidget? oldTwoDepthPopUp = HomeNavigator.getPeekTwoDepthPopUp();

    if(oldTwoDepthPopUp == null || !PageType.isPlayerProfilePage(oldTwoDepthPopUp)) {
      HomeNavigator.push(RoutePaths.profile.aiSquare, arguments: {
        "square" : squareModel,
        "channel" : channel
      }, addedPadding: EdgeInsets.symmetric(vertical: Zeplin.size(84)));
    } else if (PageType.isPlayerProfilePage(oldTwoDepthPopUp)) {
      HomeNavigator.clearTwoDepthPopUp();
    }
  }

  static bool isCheckpointed(List<MessageModel> messageList) {
    List<MessageModel?> filterList = messageList.where((element) => element.messageType == MessageType.markdown || (element.messageType == MessageType.system && element.contentId == ConstMsgContentId.resetAiHistory)).toList();
    int value = filterList.length > limitCheckpoint ? limitCheckpoint : filterList.length;
    filterList = filterList.sublist(0, value);

    if(filterList.isEmpty || filterList.where((e) => e!.messageType == MessageType.system && e.contentId == ConstMsgContentId.resetAiHistory).length > 0) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(20)),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: CustomColor.paleGrey, width: 1))),
      height: Zeplin.size(54, isPcSize: true),
      child: Row(
          children: [
            if(!isSideNavi)
              Padding(
                padding: EdgeInsets.only(right: Zeplin.size(30)),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        HomeNavigator.pop();
                      },
                      child: Icon46(Assets.img.ico_46_arrow_bk)
                  ),
                ),
              ),
            if(SquareModel.isAiChatSquare(squareModel.squareId))
              _buildEtc()
            else if(squareModel.squareType == SquareType.token)
              _buildToken()
            else
              _buildSquare(),

            Spacer(),

            SquarePopup(squareModel: squareModel, rootWidget: parent, leaveFunc: leaveFunc),
          ]
      )
    );
  }

  Widget _buildToken() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SquareImage(
          squareModel,
          width: Zeplin.size(58),
          height: Zeplin.size(58),
          borderRadius: 10,
          hasBackground: false,
        ),
        SizedBox(width: Zeplin.size(12)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(squareModel.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28), color: CustomColor.darkGrey)),
            SizedBox(height: Zeplin.size(5)),
            squareModel.symbol != null ? Text(squareModel.symbol!, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28), color: CustomColor.taupeGray)) : Container(),
          ],
        )
      ],
    );
  }


  Widget _buildEtc() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapSquareHeader,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SquareImage(
              squareModel,
              width: Zeplin.size(58),
              height: Zeplin.size(58),
              borderRadius: 10,
              hasBackground: false,
            ),
            SizedBox(width: Zeplin.size(12)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(squareModel.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28), color: CustomColor.darkGrey)),
                SizedBox(height: Zeplin.size(5)),
                squareModel.subtitle != null ? Text(squareModel.subtitle!, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28), color: CustomColor.taupeGray)) : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSquare() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HomeWidget? oldTwoDepthPopUp = HomeNavigator.getPeekTwoDepthPopUp();

          if(oldTwoDepthPopUp == null || !PageType.isSquareMemberPage(oldTwoDepthPopUp)) {
            HomeNavigator.push(RoutePaths.square.squareMember, arguments: {'square': squareModel, 'channel': channel });
          } else if (PageType.isSquareMemberPage(oldTwoDepthPopUp)) {
            HomeNavigator.clearTwoDepthPopUp();
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SquareImage(
              squareModel,
              width: Zeplin.size(58),
              height: Zeplin.size(58),
              borderRadius: 10,
            ),
            SizedBox(width: Zeplin.size(12)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    squareModel.chainNetType != ChainNetType.user ? Container(
                      child: Icon28(squareModel.chainNetType.chainIcon),
                      decoration: BoxDecoration(color: CustomColor.paleGrey, shape: BoxShape.circle)) : Container(),
                    SizedBox(width: 5),
                    Text(squareModel.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28), color: CustomColor.darkGrey)),
                  ],
                ),
                SizedBox(height: Zeplin.size(5)),
                Row(
                  children: [
                    Icon26(Assets.img.ico_26_fre_gr),
                    SizedBox(width: 3),
                    Text(" ${StringUtil.numberWithComma(squareModel.memberCount ?? 0)}", style: TextStyle(fontWeight: FontWeight.w500, color: CustomColor.taupeGray, fontSize: Zeplin.size(24))),
                    SizedBox(width: 2),
                    Icon26(Assets.img.ico_26_h_26_ud_gy)
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
