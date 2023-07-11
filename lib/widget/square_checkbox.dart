
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';

class SquareCheckbox extends StatefulWidget {
  final bool? value;
  final double? size;
  SquareCheckbox({this.size, this.value});

  @override
  State<StatefulWidget> createState() => _SquareCheckboxState();
}

class _SquareCheckboxState extends State<SquareCheckbox> {
  Image? _checkboxGray;
  Image? _checkboxBlue;

  @override
  void initState() {
    super.initState();
    _checkboxGray = Image.asset(Assets.img.ico_40_ch_gr, width: widget.size, height: widget.size);
    _checkboxBlue = Image.asset(Assets.img.ico_40_ch_blu, width: widget.size, height: widget.size);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: widget.value! ? _checkboxBlue : _checkboxGray
    );
  }
}
