import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

class CustomDivider extends StatelessWidget {
  double? padding;
  double? thickness;
  CustomDivider({Key? key, this.padding, this.thickness}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? Zeplin.size(34)),
      child: Divider(color: CustomColor.dividerGrey, height: Zeplin.size(1), thickness: thickness),
    );
  }
}
