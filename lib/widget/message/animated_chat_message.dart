

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/chat_message_manager.dart';

class AnimatedChatMessage extends StatefulWidget {
  final Key? key;
  final MessageModel messageModel;
  final AnimationController colorAnim;
  final Color messageColor;

  AnimatedChatMessage({this.key, required this.messageModel, required this.colorAnim, required this.messageColor})
    : super(key : key);

  @override
  State<AnimatedChatMessage> createState() => _AnimatedChatMessageState();
}

class _AnimatedChatMessageState extends State<AnimatedChatMessage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox;
      final Offset pos = box.localToGlobal(Offset.zero);
      ChatMessageManager().registerChatSkill(widget.messageModel, pos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.colorAnim, builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(26), vertical: Zeplin.size(19)),
          constraints: BoxConstraints(minHeight: Zeplin.size(60)),
          decoration: BoxDecoration(
            color: Color.fromRGBO(widget.messageColor.red, -(100 - widget.colorAnim.value * 100).round() + widget.messageColor.green, widget.messageColor.blue, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child:  ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Zeplin.size(472)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(widget.messageModel.messageBody!, style: chatTextStyle),
            ),
          ),
        );
    });
  }
}