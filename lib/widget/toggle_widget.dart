import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

typedef OnToggle = void Function(int index);

class ToggleWidget extends StatefulWidget {
  final Color activeBgColor;
  final Color activeTextColor;
  final Color inactiveBgColor;
  final Color inactiveTextColor;
  final List<String> labels;
  final OnToggle? onToggle;
  final int initialLabel;
  final double minWidth;
  final double height;

  ToggleWidget({
    Key? key,
    required this.activeBgColor,
    required this.activeTextColor,
    required this.inactiveBgColor,
    required this.inactiveTextColor,
    required this.labels,
    this.onToggle,
    this.initialLabel = 0,
    this.minWidth = 65,
    this.height = 40,
  }) : super(key: key);

  @override
  _ToggleWidgetState createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<ToggleWidget> {
  late int current;

  @override
  void initState() {
    current = widget.initialLabel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _handleOnTap(0),
              child: Text(widget.labels[0], style: TextStyle(color: current == 0 ? widget.activeTextColor : widget.inactiveTextColor, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(width: Zeplin.size(20)),
          VerticalDivider(width: Zeplin.size(2), endIndent: Zeplin.size(25), indent: Zeplin.size(30)),
          SizedBox(width: Zeplin.size(20)),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _handleOnTap(1),
              child: Text(widget.labels[1], style: TextStyle(color: current == 1 ? widget.activeTextColor : widget.inactiveTextColor, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleOnTap(int index) async {
    setState(() => current = index);
    if (widget.onToggle != null) {
      widget.onToggle!(index);
    }
  }
}
