import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/player_model.dart';


class PebbleRectWithSuffix extends StatelessWidget {
  final CustomPainter? painter;
  final double? height;
  final double? width;
  final Widget? child;
  final Widget? icon;
  final EdgeInsets? padding;
  final Alignment? iconAlignment;

  PebbleRectWithSuffix(
      {this.painter, this.height, this.width, this.child, this.icon, this.iconAlignment, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        child: CustomPaint(
            painter: painter,
            child: Row(
              children: <Widget>[
                Expanded(child: child != null ? child! : Container()),
                icon != null
                    ? Align(
                        alignment: iconAlignment ?? Alignment.centerRight,
                        child: Padding(
                            padding: padding ?? EdgeInsets.fromLTRB(0, 0, Zeplin.size(20), 0),
                            child: icon))
                    : Container()
              ],
            )));
  }
}

// class PebbleRectWithShadowAnimator extends StatefulWidget {
//   final Color? color;
//   final bool? stroke;
//   final double? curveSize;
//   final Widget? child;
//
//   PebbleRectWithShadowAnimator(
//       {this.color, this.stroke, this.curveSize, this.child});
//
//   @override
//   State<StatefulWidget> createState() => _PebbleRectWithShadowAnimatorState();
// }
//
// class _PebbleRectWithShadowAnimatorState
//     extends State<PebbleRectWithShadowAnimator>
//     with SingleTickerProviderStateMixin {
//   AnimationController? controller;
//   late Widget child;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 300));
//     child = CustomPaint(
//         painter: PebbleRectFillPainterWithAnimatableShadow(
//             color: widget.color,
//             stroke: widget.stroke,
//             curveSize: widget.curveSize,
//             controller: controller),
//         child: widget.child);
//   }
//
//   @override
//   void dispose() {
//     controller!.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ButtonShadowBloc, SwitchBlocState>(
//       bloc: BlocManager.getBloc()!,
//       builder: (context, state) {
//       LogWidget.debug("_PebbleRectWithShadowAnimatorState state is $state");
//       if (state is SwitchBlocOnState) {
//         controller!.reset();
//         controller!.forward();
//         return child;
//       }
//       if (state is SwitchBlocOffState) {
//         controller!.reverse();
//       }
//       return child;
//     });
//   }
// }

class PebbleRectFillPainterWithAnimatableShadow extends CustomPainter {
  PebbleRectSvg pebbleRectSvg = PebbleRectSvg();
  Color? color;
  Paint? strokePaint;
  Paint? fillPaint;
  bool? stroke;
  Paint shadowPaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
    ..color = Colors.black26
    ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
    ..style = PaintingStyle.fill
    ..strokeWidth = 2.0;
  AnimationController? controller;

  double? curveSize;

  PebbleRectFillPainterWithAnimatableShadow(
      {this.color,
      this.stroke,
      this.strokePaint,
      this.curveSize,
      this.controller}) {
    if (curveSize == null) curveSize = 0.2;
    if (fillPaint == null)
      fillPaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
        ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
    if (stroke == true && strokePaint == null) {
      strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
        ..color = Colors.black
        ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
    }
    if (color != null) fillPaint!.color = color!;

    assert(controller != null);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Matrix4 matrix4 = Matrix4.identity();
    final width = size.width;
    final height = size.height;
    final inverseRatio = 1 / curveSize!;
    matrix4.scale(curveSize, curveSize);

    /// shadow
    canvas.save();
    canvas.translate(0, 40 * curveSize!);
    canvas.drawPath(
        pebbleRectSvg
            .getPath(width, height, inverseRatio)
            .transform(matrix4.storage),
        shadowPaint
          ..color = Colors.black26.withOpacity(controller!.value * 0.26));
    canvas.restore();

    if (strokePaint != null)
      canvas.drawPath(
          pebbleRectSvg
              .getPath(width, height, inverseRatio)
              .transform(matrix4.storage),
          strokePaint!);
    canvas.drawPath(
        pebbleRectSvg
            .getPath(width, height, inverseRatio)
            .transform(matrix4.storage),
        fillPaint!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PebbleRectFillPainter extends CustomPainter {
  PebbleRectSvg pebbleRectSvg = PebbleRectSvg();
  Color? color;
  Paint? strokePaint;
  Paint? fillPaint;
  bool? shadow;
  bool? stroke;
  Paint shadowPaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
    ..color = Colors.black26
    ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
    ..style = PaintingStyle.fill
    ..strokeWidth = 2.0;

  double? curveSize;

  PebbleRectFillPainter(
      {this.color,
      this.stroke,
      this.strokePaint,
      this.curveSize,
      this.shadow}) {
    if (shadow == null) shadow = false;
    if (curveSize == null) curveSize = 0.2;
    if (fillPaint == null)
      fillPaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
        ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
    if (stroke == true && strokePaint == null) {
      strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
        ..color = Colors.black
        ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
    }
    if (color != null) fillPaint!.color = color!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Matrix4 matrix4 = Matrix4.identity();
    final width = size.width;
    final height = size.height;
    final inverseRatio = 1 / curveSize!;
    matrix4.scale(curveSize, curveSize);
    if (shadow == true) {
      canvas.save();
      canvas.translate(0, 45 * curveSize!);
      canvas.drawPath(
          pebbleRectSvg
              .getPath(width, height, inverseRatio)
              .transform(matrix4.storage),
          shadowPaint);
      canvas.restore();
    }
    if (strokePaint != null)
      canvas.drawPath(
          pebbleRectSvg
              .getPath(width, height, inverseRatio)
              .transform(matrix4.storage),
          strokePaint!);
    canvas.drawPath(
        pebbleRectSvg
            .getPath(width, height, inverseRatio)
            .transform(matrix4.storage),
        fillPaint!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PebbleRectPainter extends CustomPainter {
  PebbleRectSvg pebbleRectSvg = PebbleRectSvg();
  Color color;
  double strokeWidth;
  double? curveSize;
  Paint? strokePaint;

  PebbleRectPainter(
      {this.color = Colors.black, this.strokeWidth = 6.0, this.curveSize}) {
    if (curveSize == null) curveSize = 0.2;
    strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = color
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Matrix4 matrix4 = Matrix4.identity();
    final width = size.width;
    final height = size.height;
    final inverseRatio = 1 / curveSize!;
    matrix4.scale(curveSize, curveSize);
    if (strokePaint != null)
      canvas.drawPath(
          pebbleRectSvg
              .getPath(width, height, inverseRatio)
              .transform(matrix4.storage),
          strokePaint!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PebbleRectSvg {
  double topW = -140.1;
  double bottomW = -5.0;
  double topH = -273.68;
  double bottomH = 0.0;

  String getPathString(double width, double height, double weight) {
    return "M5.27,89.29c5.6-23.2,5.6-35.02,18.84-51.39C38.65,19.92,57.21,10.96,79.27,6.48" +
        "c15.85-3.23,34.31-5.62,53.28-6.36L135.9,0H" +
        (topW + width * weight).toString() +
        "v0.07c20.82-0.44,42.02,1.25,60.94,6.29c13.06,3.47,33.79,10.1,42.96,19.79" +
        "c7.63,8.06,17.64,21.45,21.91,33.59c7.53,21.45,10.25,48.65,10.08,74.44l-0.03,2.66H" +
        (bottomW + width * weight).toString() +
        "v" +
        (topH + height * weight).toString() +
        "c-0.65,22.99-3.48,44.27-7.15,58.52" +
        "c-4.96,19.24-11.95,38.55-27.89,51.02c-20.25,15.86-45.82,23.89-71.14,26.21c-8.96,0.82-17.49,0.92-26.05,1.04L264.1," +
        (bottomH + height * weight).toString() +
        "H135.9" +
        "l-3.64-0.21c-21.8-1.42-43.28-5.65-64.36-11.52c-29.11-8.11-38.72-16.52-51.94-32.94c-18.75-23.27-15.78-55.38-15.65-71.04" +
        "c0.04-5.16-0.43-11.87-0.29-19.38l0.04-1.75H0V136.84C0.47,121.96,1.66,104.25,5.27,89.29z";
  }

  Path getPath(double width, double height, double weight) {
    return parseSvgPathData(getPathString(width, height, weight));
  }
}

class PebbleAvatar extends StatelessWidget {
  final Widget? child;
  final bool drawBorder;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? strokeWidth;
  final Color? strokeColor;
  final bool noCliping;

  PebbleAvatar({this.child, this.drawBorder = false, this.size = 30.0, this.onTap, this.onLongPress, this.strokeWidth, this.strokeColor, this.noCliping = false});

  factory PebbleAvatar.player(Player player){

    Widget image;

    if (player.imgIsAsset) {
      return PebbleAvatar(
        strokeWidth: 2.0,
        child: Image.asset(player.profileImgUrl!));
    }

    final imgBuilder = FutureBuilder(
      future: player.loadComplete!.future,
      builder: (context, snapshot) {
        if(player.profileImgUrl == null) {
          return Image.asset(Assets.img.profile_image_default);
        } else {
          return ExtendedImage.network(player.profileImgUrl!,
            loadStateChanged: (ExtendedImageState state) {
              // ignore: missing_enum_constant_in_switch
              switch(state.extendedImageLoadState) {
                case LoadState.loading:
                  return Container(
                    color: CustomColor.paleGrey,
                  );
                default:
                  return Image.asset(Assets.img.profile_image_default);
              }
            },
           );
        }
      },
    );

    return PebbleAvatar(
        strokeWidth: 2.0,
        child:imgBuilder);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        child: CustomPaint(
          child: noCliping ? child : ClipPebble(child: child),
          foregroundPainter: drawBorder ? PebblePainter(strokeColor: strokeColor, strokeWidth: strokeWidth) : null,
        ),
      ),
    );
  }
}

class PebbleFillPainter extends CustomPainter {
  PebbleSvg pebbleSvg = PebbleSvg();
  Color? color;
  Paint? stroke;

  PebbleFillPainter({this.color, this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = color! // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    final Matrix4 matrix4 = Matrix4.identity();
    final ratioW = size.width / pebbleSvg.width;
    final ratioH = size.height / pebbleSvg.height;
    final ratio = min(ratioW, ratioH);
    // LogWidget.debug("PebbleClipper scale ${ratio} ${ratioW} ${ratioH}");
    matrix4.translate(-16.04 * ratio, -16.03 * ratio);
    matrix4.scale(ratio, ratio);
    canvas.drawPath(pebbleSvg.path.transform(matrix4.storage), paint);
    if (stroke != null) {
      canvas.drawPath(pebbleSvg.path.transform(matrix4.storage), stroke!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PebblePainter extends CustomPainter {
  PebbleSvg pebbleSvg = PebbleSvg();
  Color? strokeColor;
  double? strokeWidth;

  PebblePainter({this.strokeColor, this.strokeWidth}){
    if(strokeColor == null)
      strokeColor = Color.fromARGB(255, 214, 214, 214);
    if(strokeWidth == null)
      strokeWidth = 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = strokeColor!// 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!;
    final Matrix4 matrix4 = Matrix4.identity();
    final ratioW = size.width / pebbleSvg.width;
    final ratioH = size.height / pebbleSvg.height;
    final ratio = min(ratioW, ratioH);
    // LogWidget.debug("PebbleClipper scale ${ratio} ${ratioW} ${ratioH}");

    matrix4.translate(-16.04 * ratio, -16.03 * ratio);
    matrix4.scale(ratio, ratio);
    canvas.drawPath(pebbleSvg.path.transform(matrix4.storage), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PebbleGaugePainter extends CustomPainter {
  double percent;
  double? strokeWidth;
  Color? color;

  PebbleGaugePainter(this.percent, {this.strokeWidth, this.color});

  PebbleSvg pebbleSvg = PebbleSvg();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = color!
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!;
    final Matrix4 matrix4 = Matrix4.identity();
    final ratioW = size.width / pebbleSvg.width;
    final ratioH = size.height / pebbleSvg.height;
    final ratio = min(ratioW, ratioH);
    // LogWidget.debug("PebbleClipper scale ${ratio} ${ratioW} ${ratioH}");

    matrix4.translate(-16.04 * ratio, -16.03 * ratio);
    matrix4.scale(ratio, ratio);
    canvas.drawPath(trimPath(pebbleSvg.path.transform(matrix4.storage), 1-percent, origin: PathTrimOrigin.end), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ClipPebble extends SingleChildRenderObjectWidget {
  final Widget? child;

  ClipPebble({this.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipPath(clipper: PebbleClipper());
  }

  @override
  bool shouldReclip(PebbleClipper oldClipper) => false;
}

class PebbleClipper extends CustomClipper<Path> {
  PebbleSvg pebbleSvg = PebbleSvg();

  @override
  Path getClip(Size size) {
    final Matrix4 matrix4 = Matrix4.identity();
    final ratioW = size.width / pebbleSvg.width;
    final ratioH = size.height / pebbleSvg.height;
    final ratio = min(ratioW, ratioH);
    //LogWidget.debug("PebbleClipper scale ${ratio} ${ratioW} ${ratioH}");
    matrix4.translate(-16.04 * ratio, -16.03 * ratio);
    matrix4.scale(ratio, ratio);
    return pebbleSvg.path.transform(matrix4.storage);
  }

  @override
  bool shouldReclip(PebbleClipper oldClipper) => false;
}

class PebbleSvg {
  final width = 333.68;
  final height = 333.69;
  final pathString =
      "M288.56,53.41c-27.85-21.84-61.34-35.2-96.36-37.12-35.95-2-73.49,7.57-103.07,29.1A170.71,170.71,0,0,0,68.58,63.1c-46.34,48-65.89,123.36-42.86,187.65,10.51,29.32,28.58,55.37,53.33,73.65,28,20.65,63.33,28.31,97.24,24.29,35.35-4.19,69-18.64,98.74-38.52,28.74-19.23,54.84-43.89,66.56-77.94,10.65-30.93,10.42-66.42,1.77-97.81C334.25,101.34,315,74.14,288.56,53.41Z";
  late Path path;

  PebbleSvg() {
    path = parseSvgPathData(pathString);
  }
}

class ClipPebbleRect extends StatelessWidget {
  final Widget? child;
  final bool drawBorder;
  final double? width;
  final double? height;

  ClipPebbleRect({this.child, this.drawBorder = true, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        child: ClipPebbleRectRenderObject(child: child),
        foregroundPainter: drawBorder == true ? PebbleRectPainter(
            strokeWidth: 1.00,
            color: CustomColor.chatImageBorderGrey,
            curveSize: curveSizeM) : null,
      ),
    );
  }
}

class ClipPebbleRectRenderObject extends SingleChildRenderObjectWidget {
  final Widget? child;

  ClipPebbleRectRenderObject({this.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipPath(clipper: PebbleRectClipper());
  }
}

class PebbleRectClipper extends CustomClipper<Path> {
  PebbleRectSvg pebbleRectSvg = PebbleRectSvg();

  double curveSize = curveSizeM;

  @override
  Path getClip(Size size) {
    Matrix4 matrix4 = Matrix4.identity();
    final width = size.width;
    final height = size.height;
    final inverseRatio = 1 / curveSize;
    matrix4.scale(curveSize, curveSize);
    return pebbleRectSvg
        .getPath(width, height, inverseRatio)
        .transform(matrix4.storage);
  }

  @override
  bool shouldReclip(PebbleClipper oldClipper) => false;
}


class RectClipper extends CustomClipper<Path> {
  double scale;
  bool isFromLeft;
  RectClipper(this.scale, {this.isFromLeft = true});

  @override
  Path getClip(Size size) {
    final path = Path();
    if(isFromLeft){
      path.moveTo(0.0, 0.0);
      path.lineTo(0.0, size.height);
      path.lineTo(size.width * scale, size.height);
      path.lineTo(size.width * scale, 0.0);
    }else{
      path.moveTo(size.width, 0.0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * scale, size.height);
      path.lineTo(size.width * scale, 0.0);
    }

    path.close();
    return path;
  }
  @override
  bool shouldReclip(RectClipper oldClipper) => true;
}

