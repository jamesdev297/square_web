import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';

class CenterToast extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Widget? child;
  final AnimationController animationController;

  CenterToast({Key? key, required this.animationController, required this.text, Widget? icon, this.child})
      : this.icon = icon ?? Image.asset(Assets.img.ico_ch_70, width: Zeplin.size(95)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(child != null)
          child!,
        IgnorePointer(
          child: Center(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Opacity(opacity: animationController.value, child: child);
              },
              child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.img.dim), fit: BoxFit.fill)),
                  width: Zeplin.size(284),
                  height: Zeplin.size(284),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Assets.img.ico_ch_70, width: Zeplin.size(95)),
                        Text(text, style: TextStyle(
                            color: Colors.white, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

}
