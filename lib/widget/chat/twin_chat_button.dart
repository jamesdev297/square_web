import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/button.dart';

class TwinChatButton extends StatelessWidget {
  final ContactModel contactModel;
  final VoidCallback? onTap;

  const TwinChatButton({Key? key, required this.contactModel, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: PebbleRectButton(
        borderColor: CustomColor.azureBlue,
        backgroundColor: CustomColor.azureBlue,
        onPressed: () {
          onTap?.call();
          RoomManager().openTwinRoom(contactModel);
        },
        child: Center(child: Text(L10n.chat_01_01_chat, style: TextStyle(color: Colors.white, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500))),
      ),
      width: Zeplin.size(104),
      height: Zeplin.size(60),
    );
  }
}
