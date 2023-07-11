import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

class NoSearchResultColumn extends StatelessWidget {
  const NoSearchResultColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              flex: 1,
              child: Container(),
            ),
          Text(L10n.square_04_01_no_search_result, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(15, isPcSize: true), fontWeight: FontWeight.w500)),
           Flexible(
              flex: 2,
              child: Container(),
            ),
        ]);
  }
}
