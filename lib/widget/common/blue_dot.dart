import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

class BlueDot extends StatelessWidget {
  const BlueDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.azureBlue,
        shape: BoxShape.circle
      ),
      width: Zeplin.size(16),
      height: Zeplin.size(16),
    );
  }
}
