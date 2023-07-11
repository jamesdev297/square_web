import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

class SquareNumberBadge extends StatelessWidget {
  final String text;

  const SquareNumberBadge({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: text.length > 2 ? Zeplin.size(65) : Zeplin.size(45),
        height: Zeplin.size(45),
        decoration: BoxDecoration(
          color: CustomColor.azureBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(text,
            style: TextStyle(
              fontSize: Zeplin.size(26),
              color: Colors.white,
              fontWeight: FontWeight.w500))));
  }
}
