import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';

class NoChatBar extends StatelessWidget {
  const NoChatBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
            height: Zeplin.size(80),
            decoration: BoxDecoration(
              color: CustomColor.paleGrey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(child: Text(L10n.chat_room_08_01_not_send_message, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28)))),
          ),
        ),
      ],
    );
  }
}
