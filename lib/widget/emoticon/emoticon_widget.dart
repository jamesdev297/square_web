import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/emoticon_manager.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class EmoticonWidget extends StatefulWidget {
  final MessageModel messageModel;

  EmoticonWidget(this.messageModel);

  @override
  State<EmoticonWidget> createState() => _EmoticonWidgetState();
}

class _EmoticonWidgetState extends State<EmoticonWidget> {
  Timer? emoticonTimer;
  SpriteController? emoticonController;
  late Future<Sprite?> futureSprite;

  @override
  void initState() {
    super.initState();
    futureSprite = EmoticonManager().initMessageSprite(widget.messageModel);
    //LogWidget.debug("EmoticonMessage initState : ${widget.messageModel.messageId}");
  }

  @override
  void dispose() {
    super.dispose();
    //LogWidget.debug("EmoticonMessage dispose : ${widget.messageModel.messageId}");
    EmoticonManager().disposeMessageSprite(widget.messageModel);
  }

  void emoticonPause(int frames) {
    emoticonTimer?.cancel();
    emoticonTimer = Timer(Duration(milliseconds: EmoticonConfig.defaultEmoticonInterval.round() * frames * EmoticonConfig.defaultEmoticonRepeatCnt), () {
      emoticonController!.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Sprite?>(
      future: futureSprite,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              width: EmoticonConfig.chatEmoticonSize,
              height: EmoticonConfig.chatEmoticonSize,
              child: Center(child: SizedBox(
                  width: EmoticonConfig.chatEmoticonSize/2,
                  height: EmoticonConfig.chatEmoticonSize/2,
                  child: SquareCircularProgressIndicator())));
        }
        if(snapshot.hasData) {
          if(snapshot.data != null) {
            return GestureDetector(
              onTap: () {
                if(emoticonController == null) return ;
                emoticonController!.play();
                emoticonPause(snapshot.data!.frames.length);
              },
              child: SizedBox(
                width: EmoticonConfig.chatEmoticonSize,
                height: EmoticonConfig.chatEmoticonSize,
                child: SpriteWidget(snapshot.data!, onReady: (controller) {
                  emoticonController = controller;
                  emoticonPause(snapshot.data!.frames.length);
                }),
              ),
            );
          }
        }
        return Container();
      },
    );
  }
}
