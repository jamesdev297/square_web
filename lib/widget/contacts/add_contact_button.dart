import 'package:flutter/material.dart';
import 'package:square_web/bloc/contact/contacts_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/widget/button.dart';

class AddContactButton extends StatelessWidget {
  final ContactModel contactModel;
  final Function(ContactModel)? successFunc;
  final bool hasRounded;
  final bool onProfilePage;
  final VoidCallback? onTap;
  const AddContactButton({Key? key, required this.contactModel, this.onTap, this.onProfilePage = false, this.successFunc, this.hasRounded = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!onProfilePage) {
      return SizedBox(
        width: Zeplin.size(65, isPcSize: true),
        height: Zeplin.size(30, isPcSize: true),
        child: PebbleRectButton(
          onPressed: () {
            onTap?.call();
            BlocManager.getBloc<ContactsBloc>()!.add(AddContactEvent(MeModel().playerId!, contactModel.playerId,
                successFunc: (contact) {
                  contactModel.update(contact);
                  successFunc?.call(contact);
                }));
          },
          backgroundColor: CustomColor.azureBlue,
          borderColor: CustomColor.azureBlue,
          child: Text(L10n.chat_05_04_add_contact, style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true),
              fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      );
    }


    Widget child = Center(child: Icon46(Assets.img.ico_46_fri_be));

    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)),
      onTap: () => BlocManager.getBloc<ContactsBloc>()!.add(AddContactEvent(MeModel().playerId!, contactModel.playerId, successFunc: (contact) {
        contactModel.update(contact);
        successFunc?.call(contact);
      })),
      child: hasRounded == true ? Container(
        decoration: BoxDecoration(color: CustomColor.linkWater, shape: BoxShape.circle),
        width: Zeplin.size(94),
        height: Zeplin.size(94),
        child: child) : child
    );
  }
}
