import 'package:flutter/material.dart';

class CustomEllipsisText extends StatelessWidget {
  const CustomEllipsisText({
    Key? key,
    required this.text,
    this.style,
    required this.ellipsis,
    this.maxWidth = double.infinity,
    this.minWidth = 0,
    this.maxLines = 1,
    this.textDirection,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final String ellipsis;
  final int maxLines;
  final double maxWidth, minWidth;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: textDirection ?? TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);

    return CustomPaint(
        size: textPainter.size,
        painter: _CustomEllipsisTextPainter(
          text: TextSpan(text: text, style: style),
          ellipsis: ellipsis,
          maxLines: maxLines,
        ));
  }
}

class _CustomEllipsisTextPainter extends CustomPainter {
  final TextSpan text;
  final int maxLines;
  final String ellipsis;

  _CustomEllipsisTextPainter({
    required this.text,
    required this.ellipsis,
    required this.maxLines,
  }) : super();

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter painter = TextPainter(
      text: text,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..ellipsis = ellipsis;
    painter.layout(maxWidth: size.width);
    painter.paint(canvas, const Offset(0, 0));
  }
}