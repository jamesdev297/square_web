import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/bool_container.dart';
import 'package:square_web/widget/button.dart';

class ChatGoLatestMessageButton extends StatefulWidget {
  final VoidCallback? onTap;
  final ScrollController? controller;
  ChatGoLatestMessageButton({this.onTap, this.controller});

  @override
  State<StatefulWidget> createState() => _StateChatGoLatestMessageButton();


}

class _StateChatGoLatestMessageButton extends State<ChatGoLatestMessageButton> {
  ScrollController? _controller;
  bool isShow = false;
  final double lowerBound = 20.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = widget.controller;
    _controller!.addListener(() {
      //LogWidget.debug("${_controller.offset}");
      if(!mounted)
        return ;
      if(isShow) {
        if(_controller!.offset < lowerBound) {
            setState(() {
              isShow = false;
            });
        }
      }else{
        if(_controller!.offset >= lowerBound) {
            setState(() {
              isShow = true;
            });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BoolContainer(
      child: Container(),
      container: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, Zeplin.size(16), Zeplin.size(16)),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
                ]
              ),
              width: Zeplin.size(64),
              height: Zeplin.size(64),
              child: Center(
                child: Icon36(Assets.img.ico_36_down_gy),
              ),
            ),
          ),
        ),
      ),
      showContainer: isShow,
    );
  }
}
