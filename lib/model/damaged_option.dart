import 'package:flutter/material.dart';

class VibratedOption {
  double? xAxisPower;
  double? yAxisPower;
  VibratedOption({this.yAxisPower, this.xAxisPower});
}
class ResizedOption {
  double? resizeValue;
  ResizedOption({this.resizeValue});
}
class FlickedOption {
  Color? color;
  double? bound;
  FlickedOption({this.color, this.bound});
}