import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/button.dart';

class SquareSimpleDialog extends StatelessWidget {
  final Widget content;
  final VoidCallback onTapButton;

  const SquareSimpleDialog({required this.content, required this.onTapButton});

  @override
  Widget build(BuildContext context) {
    return ButtonBarTheme(
      data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        contentPadding: EdgeInsets.only(top: Zeplin.size(48), left: Zeplin.size(38), right: Zeplin.size(38)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        content: content,
        actionsPadding: EdgeInsets.only(bottom: spaceL, top: spaceL, right: 5, left: 5),
        actions: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  child: PebbleRectButton(
                    backgroundColor: CustomColor.lemon,
                    onPressed: () {
                      onTapButton();
                    },
                    child: Center(child: Text(L10n.common_02_confirm, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(32), fontWeight: FontWeight.w500))),
                  ),
                  height: Zeplin.size(100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
