import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/util/device_util.dart';

class PebbleRectSvg {
  Path getPath(Rect size) {
    final scaleRatio = size.height / 106;

    Path path = Path();
    path.moveTo(55, 2.5);
    path.relativeLineTo(size.width * (1 / scaleRatio) - 110, 0);
    path.relativeCubicTo(7.895, -0.142, 15.933, 0.483, 23.107, 2.378);
    path.relativeCubicTo(4.705, 1.243, 12.266, 3.49, 15.585, 6.972);
    path.relativeCubicTo(2.774, 2.91, 6.444, 7.729, 7.996, 12.12);
    path.relativeCubicTo(2.867, 8.108, 3.865, 18.41, 3.786, 28.143);
    path.relativeCubicTo(-0.233, 8.676, -1.298, 16.705, -2.694, 22.086);
    path.relativeCubicTo(-1.79, 6.903, -4.21, 13.92, -9.992, 18.414);
    path.relativeCubicTo(-7.524, 5.851, -17.034, 8.78, -26.435, 9.635);
    path.relativeCubicTo(-3.372, 0.306, -6.583, 0.347, -9.804, 0.39);
    path.relativeLineTo(-1.579, 0.022);
    path.relativeLineTo(-size.width * (1 / scaleRatio) + 110, 0);
    path.relativeLineTo(-1.046, -0.059);
    path.relativeCubicTo(-8.43, -0.52, -16.73, -2.142, -24.875, -4.395);
    path.relativeCubicTo(-10.625, -2.94, -14.151, -5.967, -18.981, -11.925);
    path.relativeCubicTo(-6.145, -7.575, -5.733, -17.76, -5.586, -23.834);
    path.relativeCubicTo(0.019, -0.756, 0.035, -1.454, 0.04, -2.086);
    path.relativeCubicTo(0.008, -0.874, -0.021, -1.86, -0.054, -2.934);
    path.relativeCubicTo(-0.042, -1.399, -0.09, -2.957, -0.057, -4.617);
    path.relativeCubicTo(0.153, -5.6, 0.59, -12.264, 1.958, -17.894);
    path.relativeCubicTo(0.454, -1.87, 0.815, -3.55, 1.147, -5.097);
    path.relativeCubicTo(1.175, -5.474, 1.9, -9.141, 5.707, -13.817);
    path.relativeCubicTo(5.292, -6.496, 12.063, -9.683, 20.072, -11.301);
    path.relativeCubicTo(6.14, -1.242, 13.3, -2.158, 20.654, -2.427);
    path.relativeLineTo(0.978, -0.032);
    path.close();

    Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scaleRatio);
    return path.transform(matrix4.storage).shift(size.topLeft);
  }
}

class PebbleRect4DividedSvg {
  double topW = -140.1;
  double bottomW = -5.0;
  double topH = -273.68;
  double bottomH = 0.0;

  String getPathString(Rect size, double weight) {
    return "M5.27,89.29c5.6-23.2,5.6-35.02,18.84-51.39C38.65,19.92,57.21,10.96,79.27,6.48" +
        "c15.85-3.23,34.31-5.62,53.28-6.36L135.9,0H" +
        (topW + size.width * weight).toString() +
        "v0.07c20.82-0.44,42.02,1.25,60.94,6.29c13.06,3.47,33.79,10.1,42.96,19.79" +
        "c7.63,8.06,17.64,21.45,21.91,33.59c7.53,21.45,10.25,48.65,10.08,74.44l-0.03,2.66H" +
        (bottomW + size.width * weight).toString() +
        "v" +
        (topH + size.height * weight).toString() +
        "c-0.65,22.99-3.48,44.27-7.15,58.52" +
        "c-4.96,19.24-11.95,38.55-27.89,51.02c-20.25,15.86-45.82,23.89-71.14,26.21c-8.96,0.82-17.49,0.92-26.05,1.04L264.1," +
        (bottomH + size.height * weight).toString() +
        "H135.9" +
        "l-3.64-0.21c-21.8-1.42-43.28-5.65-64.36-11.52c-29.11-8.11-38.72-16.52-51.94-32.94c-18.75-23.27-15.78-55.38-15.65-71.04" +
        "c0.04-5.16-0.43-11.87-0.29-19.38l0.04-1.75H0V136.84C0.47,121.96,1.66,104.25,5.27,89.29z";
  }

  Path getPath(Rect size, double curveSize) {
    final inverseRatio = 1 / curveSize;
    Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(curveSize, curveSize);
    return parseSvgPathData(getPathString(size, inverseRatio)).transform(matrix4.storage).shift(size.topLeft);
  }
}

class Pebble4DividedBorder extends OutlinedBorder {
  final PebbleRect4DividedSvg pebbleRectSvg = PebbleRect4DividedSvg();
  final Color color;
  final double strokeWidth;
  final Paint strokePaint;
  final double? curveSize;

  Pebble4DividedBorder({required this.color, required this.strokeWidth, double? curveSize})
      : this.curveSize = curveSize ?? curveSizeS,
        strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
          ..color = color
          ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect, curveSize!);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect, curveSize!);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (strokePaint != null) canvas.drawPath(pebbleRectSvg.getPath(rect, curveSize!), strokePaint);
  }

  @override
  ShapeBorder scale(double t) {
    return Pebble4DividedBorder(color: this.color, strokeWidth: strokeWidth * t);
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return Pebble4DividedBorder(color: color, strokeWidth: strokeWidth);
  }
}

class PebbleBorder extends OutlinedBorder {
  final PebbleRectSvg pebbleRectSvg = PebbleRectSvg();
  final Color color;
  final double strokeWidth;
  final Paint strokePaint;

  PebbleBorder({required this.color, required this.strokeWidth})
      : strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
          ..color = color
          ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (strokePaint != null && strokeWidth != 0) canvas.drawPath(pebbleRectSvg.getPath(rect), strokePaint);
  }

  @override
  ShapeBorder scale(double t) {
    return PebbleBorder(color: this.color, strokeWidth: strokeWidth * t);
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return PebbleBorder(color: color, strokeWidth: strokeWidth);
  }
}

class PebbleInputBorder extends InputBorder {
  final PebbleRectSvg pebbleRectSvg = PebbleRectSvg();
  final Color color;
  final double strokeWidth;
  final Paint strokePaint;

  PebbleInputBorder({required this.color, required this.strokeWidth})
      : strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
          ..color = color
          ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart, double gapExtent = 0.0, double gapPercentage = 0.0, TextDirection? textDirection}) {
    if (strokePaint != null) canvas.drawPath(pebbleRectSvg.getPath(rect), strokePaint);
  }

  @override
  InputBorder scale(double t) {
    return PebbleInputBorder(color: this.color, strokeWidth: strokeWidth * t);
  }

  @override
  InputBorder copyWith({BorderSide? borderSide}) {
    return PebbleInputBorder(color: this.color, strokeWidth: strokeWidth);
  }

  @override
  bool get isOutline => true;
}

class Pebble4DividedInputBorder extends InputBorder {
  final PebbleRect4DividedSvg pebbleRectSvg = PebbleRect4DividedSvg();
  final Color color;
  final double strokeWidth;
  final Paint strokePaint;
  final double curveSize;

  Pebble4DividedInputBorder({required this.color, required this.strokeWidth, this.curveSize = 0.2})
      : strokePaint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
          ..color = color
          ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect, curveSize);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return pebbleRectSvg.getPath(rect, curveSize);
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart, double gapExtent = 0.0, double gapPercentage = 0.0, TextDirection? textDirection}) {
    if (strokePaint != null) canvas.drawPath(pebbleRectSvg.getPath(rect, curveSize), strokePaint);
  }

  @override
  InputBorder scale(double t) {
    return PebbleInputBorder(color: this.color, strokeWidth: strokeWidth * t);
  }

  @override
  InputBorder copyWith({BorderSide? borderSide}) {
    return PebbleInputBorder(color: this.color, strokeWidth: strokeWidth);
  }

  @override
  bool get isOutline => true;
}

class TopWaveBoxSvg {
  Path getPath(Rect size) {
    Path path = Path();
    path.moveTo(0, 2.686);
    path.cubicTo(30.696, 1.602, 62.872, 0.907, 89.573, 1.883);
    path.relativeCubicTo(40.133, 1.467, 99.637, 1.93, 139.243, 0.226);
    path.cubicTo(247.399, 1.31, 266.003, 0.662, 284.705, 0.632);
    path.relativeCubicTo(41.671, -0.067, 83.355, 0.435, 125.028, 1.064);
    path.relativeCubicTo(71.783, 1.082, 82.68, 2.615, 154.458, 3.898);
    path.relativeCubicTo(11.707, 0.21, 52.15, 0.478, 81.66, 0.492);
    path.relativeLineTo(5.015, 0);
    path.relativeCubicTo(11, -0.006, 19.974, -0.054, 24.546, -0.163);
    path.relativeCubicTo(7.463, -0.177, 27.238, -1.897, 44.589, -2.256);
    Matrix4 matrix = Matrix4.identity();
    matrix.scale(DeviceUtil.screenWidth / 720);
    path = path.transform(matrix.storage);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 2.686);
    path.close();
    return path.shift(size.topLeft);
  }
}

class TopWaveBoxBorder extends ShapeBorder {
  final TopWaveBoxSvg topWaveBoxSvg = TopWaveBoxSvg();

  TopWaveBoxBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return topWaveBoxSvg.getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return topWaveBoxSvg.getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return TopWaveBoxBorder();
  }
}

class TopWaveBoxDecoration extends ShapeDecoration {
  TopWaveBoxDecoration()
      : super(
            shape: TopWaveBoxBorder(),
            color: Colors.white,
            shadows: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]);
}
