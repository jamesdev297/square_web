import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';

class RemoveContactButton extends StatelessWidget {
  final ContactModel contactModel;
  final VoidCallback? successFunc;
  const RemoveContactButton({Key? key, required this.contactModel, this.successFunc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      onTap: () => SquareRoomDialog.showRemoveContactOverlay(contactModel, successFunc: successFunc),
      child: Container(
        decoration: BoxDecoration(color: CustomColor.linkWater, shape: BoxShape.circle),
        width: Zeplin.size(94),
        height: Zeplin.size(94),
        child: Center(child: Icon46(Assets.img.ico_46_fri_2_be)))
    );
  }
}
