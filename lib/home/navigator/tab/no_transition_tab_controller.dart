import 'package:flutter/material.dart';

class NoTransitionTabController extends TabController {
  NoTransitionTabController(
      {int initialIndex = 0,
        required int length,
        required TickerProvider vsync})
      : super(initialIndex: initialIndex, length: length, vsync: vsync);

  @override
  void animateTo(int value, { Duration? duration, Curve curve = Curves.ease }) {
    super.animateTo(value, duration: const Duration(milliseconds: 0), curve: curve);
  }
}