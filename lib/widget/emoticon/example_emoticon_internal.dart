import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/emoticon/emoticon_model.dart';
import 'package:square_web/model/emoticon/network_sprite.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class ExampleEmotionInternal extends StatefulWidget {
  final String emoticonId;
  ExampleEmotionInternal(this.emoticonId);

  @override
  State<ExampleEmotionInternal> createState() => _ExampleEmotionInternalState();
}

class _ExampleEmotionInternalState extends State<ExampleEmotionInternal> {
  Timer? emotionTimer;
  late EmoticonModel emoticonModel;
  Future<Sprite?>? spriteFuture;

  @override
  void initState() {
    super.initState();

    emoticonModel = EmoticonModel(emoticonId: widget.emoticonId);
    spriteFuture = NetworkSprite.load(emoticonModel);
  }

  @override
  void didUpdateWidget(covariant ExampleEmotionInternal oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(oldWidget.emoticonId != widget.emoticonId) {

      emoticonModel = EmoticonModel(emoticonId: widget.emoticonId);
      spriteFuture = NetworkSprite.load(emoticonModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenWidthNotifier.value < maxWidthMobile;
    final double emoticonSize = isMobile ? EmoticonConfig.exampleEmoticonSizeForMobile : EmoticonConfig.exampleEmoticonSizeForDesktop;
    return FutureBuilder<Sprite?>(
      future: spriteFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return SquareCircularProgressIndicator();
        }
        if(snapshot.hasData) {
          if(snapshot.data != null) {
            LogWidget.debug("KATTTTT333 ${snapshot.data!.frames.length}");
            return SizedBox(
              width: emoticonSize,
              height: emoticonSize,
              child: SpriteWidget(snapshot.data!, onReady: (controller) {
                emotionTimer?.cancel();
                emotionTimer = Timer(Duration(milliseconds: EmoticonConfig.defaultEmoticonInterval.round() * snapshot.data!.frames.length * EmoticonConfig.defaultEmoticonRepeatCnt), () {
                  controller.pause();
                });
              }),
            );
          }
        }
        return Container();
      },
    );
  }
}