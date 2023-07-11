
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';

class SquareLogoTopLeft extends StatelessWidget {
  const SquareLogoTopLeft({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        late double leftPadding;
        late Size buttonSize;
        bool isMobile = screenWidthNotifier.value < maxWidthMobile;

        if(!isMobile) {
          leftPadding = 120;
        } else {
          leftPadding = Zeplin.size(44);
        }

        return Container(
          height: 80,
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              SizedBox(width: leftPadding,),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      // AuthManager().goBrandPage();
                    },
                    child: Image.asset(Assets.img.square_logo, width: 67,)),
              ),
              Spacer(),
            ],
          )
        );
      },
    );
  }
}