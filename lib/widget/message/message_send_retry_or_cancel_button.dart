import 'package:flutter/material.dart';
import 'package:square_web/bloc/message_bloc.dart';
import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/chat/text_message.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class MessageSendRetryOrCancelButton extends StatefulWidget {
  final MessageModel messageModel;
  final MessageBloc messageBloc;
  MessageSendRetryOrCancelButton(this.messageModel, this.messageBloc);


  @override
  State<StatefulWidget> createState() => _MessageSendRetryOrCancelButtonState();

}

class _MessageSendRetryOrCancelButtonState extends State<MessageSendRetryOrCancelButton> {

  List<bool> _selections = List.generate(2, (_) => false);
  bool isLoading = false;
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;

  @override
  void initState() {
    super.initState();
  }

  void showToolTip(Offset pointerOffset) {
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset offset, Size size, Size popUpSize) {

      double dx = pointerOffset.dx;
      double dy = pointerOffset.dy;

      if(pointerOffset.dx + popUpSize.width > DeviceUtil.screenWidth) {
        dx = pointerOffset.dx - popUpSize.width;
      }

      if(pointerOffset.dy + popUpSize.height > DeviceUtil.screenHeight) {
        dy = pointerOffset.dy - popUpSize.height;
      }
      // final isMyMsg = widget.messageModel.messageSender == MessageSender.me;
      // double dx;
      // double dy;
      // bool isSlideInUp = false;
      //
      // if (offset.dy < (DeviceUtil.screenHeight / 2)) {
      //   dy = offset.dy + size.height + TextMessage.padding;
      // } else {
      //   dy = offset.dy - popUpSize.height - TextMessage.padding;
      //   isSlideInUp = true;
      // }
      //
      // if(isMyMsg) {
      //   if (size.width > TextMessage.popUpItemWidth)
      //     dx = offset.dx;
      //   else
      //     dx = offset.dx - TextMessage.popUpItemWidth + size.width;
      // } else {
      //   dx = offset.dx;
      // }

      return GetPopUpOffsetCallbackResponse(Offset(dx, dy), isSlideUp: false);
    }, popUpSize: Size(TextMessage.popUpItemWidth, TextMessage.popUpItemHeight));
  }

  @override
  Widget build(BuildContext context) {

    squarePopUpItems = [
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_refresh_bk,
          name: L10n.common_64_try_again,
          onTap: () => onSelected(0)),
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_del_bk,
          name: L10n.common_03_cancel,
          onTap: () => onSelected(1)),
    ];


    return MouseRegion(
      key: globalKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (event) => showToolTip(event.globalPosition),
        child: Container(
          width: Zeplin.size(110),
          height: Zeplin.size(50),
          key: ValueKey("${widget.messageModel.messageId}:retry"),
          child: isLoading == false ? Container(
            decoration: BoxDecoration(
              color: CustomColor.deleteRed,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon36(Assets.img.ico_36_refresh),
                VerticalDivider(color: Colors.white.withOpacity(0.5), thickness: 0.5, width: 0.5),
                Icon36(Assets.img.ico_36_x),
              ],
            ),
          ) : SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size20),
        ),
      ),
    );
  }

  void updateData() {
    if(mounted)
      setState(() {
        isLoading = false;
      });
  }

  void onSelected(int value) {
    switch (value) {
      case 0:
        isLoading = true;
        widget.messageBloc.add(RetrySendMessage(widget.messageModel, updateData));
        break;
      case 1:
        isLoading = true;
        widget.messageBloc.add(RemoveForMeMessage(messageModel: widget.messageModel));
        break;
      default:
    }
  }
}