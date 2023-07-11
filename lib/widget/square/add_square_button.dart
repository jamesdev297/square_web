import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/square/square_item.dart';

class AddSquareButton extends StatelessWidget {
  const AddSquareButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(SquareItem.squareItemPadding),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  SquareListPageHome.isIconView = false;
                  HomeNavigator.expandOneDepth(SquareListPageHome.isIconView);
                  HomeNavigator.push(RoutePaths.square.add);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Zeplin.size(26)),
                    border: Border.all(
                      width: 1,
                      color: CustomColor.borderGrey2,
                    ),
                  ),
                  width: constraints.minWidth - SquareItem.squareItemPadding * 2,
                  height: constraints.minWidth - SquareItem.squareItemPadding * 2,
                  padding: EdgeInsets.only(top: SquareItem.squareItemPadding),
                  child: Center(child: Icon46(Assets.img.ico_46_plus_gy)),
                ),
              ),
              SizedBox(height: Zeplin.size(14)),
              Row(
                children: [
                  Text(L10n.ai_01_create_ai_square, overflow: TextOverflow.ellipsis, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
