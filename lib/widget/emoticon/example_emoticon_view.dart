import 'package:flutter/material.dart';
import 'package:square_web/bloc/switch_bloc.dart';
import 'package:square_web/bloc/switch_bloc_event.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/emoticon/example_emoticon_internal.dart';

class ExampleEmotionView extends StatefulWidget {
  final dynamic param;
  ExampleEmotionView(this.param);

  @override
  State<ExampleEmotionView> createState() => _ExampleEmotionViewState();
}

class _ExampleEmotionViewState extends State<ExampleEmotionView> {

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenWidthNotifier.value < maxWidthMobile;

    Widget child = Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: Zeplin.size(322),
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ExampleEmotionInternal(widget.param),
        ),
        GestureDetector(
            onTap: () => BlocManager.getBloc<ShowEmoticonExampleBloc>()!.add(OffEvent()),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: Zeplin.size(24), right: Zeplin.size(24)),
                child: Icon46(Assets.img.ico_46_close_we),
              ),
            ))
      ],
    );

    return Container(
      height: isMobile ? Zeplin.size(322) : Zeplin.size(250),
      padding: isMobile ? null : EdgeInsets.only(left: Zeplin.size(184), right: Zeplin.size(116), bottom: Zeplin.size(19)),
      child: isMobile ? child : ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: child,
      ),
    );
  }
}