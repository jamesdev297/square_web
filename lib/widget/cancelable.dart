import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';

import 'button.dart';

class Cancelable extends StatelessWidget {
  final Widget child;
  Widget? child1;
  final VoidCallback? onPressed;

  Cancelable({required this.child, this.child1, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            this.child,
            if(child1 != null)
              child1!,
            Positioned(
                right: -15,
                top: -15,
                child: IconButton(
                  onPressed: onPressed,
                  icon: Icon46(Assets.img.ico_46_check_x_bla),
                  splashRadius: 18,
                )
            )
          ],
        )
    );
  }
}