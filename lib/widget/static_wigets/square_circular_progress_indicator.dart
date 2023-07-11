import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

enum ProgressIndicatorSize {
  size20, size30, size50, size60, size80,
}

class SquareCircularProgressIndicator extends StatelessWidget {
  final ProgressIndicatorSize? progressIndicatorSize;
  final Color? color;
  final bool isCenter;
  const SquareCircularProgressIndicator({Key? key, this.progressIndicatorSize = ProgressIndicatorSize.size60, this.color = CustomColor.lightGreyBlue, this.isCenter = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? width;
    double? height;

    // ignore: missing_enum_constant_in_switch
    switch(progressIndicatorSize) {
      case ProgressIndicatorSize.size20:
        width = Zeplin.size(20);
        height = Zeplin.size(20);
        break;
      case ProgressIndicatorSize.size30:
        width = Zeplin.size(30);
        height = Zeplin.size(30);
        break;
      case ProgressIndicatorSize.size50:
        width = Zeplin.size(50);
        height = Zeplin.size(50);
        break;
      case ProgressIndicatorSize.size60:
        width = Zeplin.size(60);
        height = Zeplin.size(60);
        break;
      case ProgressIndicatorSize.size80:
        width = Zeplin.size(80);
        height = Zeplin.size(80);
        break;
    }

    Widget child = SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(color: color, strokeWidth: 4.0,)
    );

    if(isCenter == true)
      return Center(child: child);

    return child;
  }
}
