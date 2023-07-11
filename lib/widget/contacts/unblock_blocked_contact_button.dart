import 'package:flutter/material.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';

class UnblockBlockedContactButton extends StatelessWidget {
  final ContactModel contactModel;
  final PlayerProfileBloc? playerProfileBloc;
  final VoidCallback? successFunc;
  final bool hasRounded;
  final bool onProfilePage;
  final VoidCallback? onTap;
  const UnblockBlockedContactButton({Key? key, required this.contactModel, this.onTap, this.onProfilePage = false, this.playerProfileBloc, this.successFunc, this.hasRounded = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!onProfilePage) {
      return SizedBox(
        width: Zeplin.size(65, isPcSize: true),
        height: Zeplin.size(30, isPcSize: true),
        child: PebbleRectButton(
          onPressed: () {
            onTap?.call();
            BlocManager.getBloc<BlockedContactsBloc>()!.add(UnblockContactEvent(MeModel().playerId!, contactModel.playerId, successFunc: () {
              successFunc?.call();
              SquareRoomDialog.showAddContactOverlay(contactModel.playerId, contactModel.name, successFunc: (contact) {
                playerProfileBloc?.add(ReloadPlayerProfileEvent(contact));
                RoomManager().updateChatPage(contactModel: contact);
              });
            }));
          },
          backgroundColor: CustomColor.azureBlue,
          borderColor: CustomColor.azureBlue,
          child: Text(L10n.profile_01_06_unblock, style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true),
              fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      );
    }

    Widget child = Center(child: Icon46(Assets.img.ico_46_block_off_gy));

    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      onTap: () {

        BlocManager.getBloc<BlockedContactsBloc>()!.add(UnblockContactEvent(MeModel().playerId!, contactModel.playerId, successFunc: () {
          successFunc?.call();
          SquareRoomDialog.showAddContactOverlay(contactModel.playerId, contactModel.name, successFunc: (contact) {
            playerProfileBloc?.add(ReloadPlayerProfileEvent(contact));
            RoomManager().updateChatPage(contactModel: contact);
          });
        }));

      },
      child: hasRounded == true ? Container(
        decoration: BoxDecoration(
          color: CustomColor.paleGrey,
          shape: BoxShape.circle
        ),
        height: Zeplin.size(94),
        width: Zeplin.size(94),
        child: child) : child
    );
  }
}
