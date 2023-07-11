

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/button.dart';

class ProfileMenuItem extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String text;

  ProfileMenuItem({
    required this.onTap,
    required this.icon,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: PebbleRectButton(
        strokeWidth: Zeplin.size(2),
        borderColor: CustomColor.lightGrey,
        onPressed: onTap,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: Zeplin.size(10)),
              Text(text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: Zeplin.size(24))),
            ],
          ),
        ),
      ),
    );
  }
}
