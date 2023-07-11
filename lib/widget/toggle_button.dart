import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/widget/toggle/toggle_button.dart';


class ToggleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool? toggleSelect;

  ToggleButton({this.onPressed, this.toggleSelect});

  @override
  State<StatefulWidget> createState() => _ToggleButtonState();

}

class _ToggleButtonState extends State<ToggleButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LogWidget.debug("MyProfileToggleButtonState build ${widget.toggleSelect}");

    return FlutterSwitch(
      inactiveColor: CustomColor.grey,
      value: widget.toggleSelect == true,
      duration: Duration(milliseconds: 150),
      onToggle: (val) {
        widget.onPressed!();
      },
      width: Zeplin.size(47, isPcSize: true),
      height: Zeplin.size(29, isPcSize: true),
      padding: Zeplin.size(5),
    );
  }
}
