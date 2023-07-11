import 'package:flutter/material.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/profile/profile_image.dart';

class TwinChatPlayerProfile extends StatefulWidget {
  final String playerId;
  final bool? isKnown;
  const TwinChatPlayerProfile({Key? key, required this.playerId, this.isKnown}) : super(key: key);

  @override
  _TwinChatPlayerProfileState createState() => _TwinChatPlayerProfileState();
}

class _TwinChatPlayerProfileState extends State<TwinChatPlayerProfile> {

  ContactModel? player;

  @override
  void initState() {
    super.initState();

    loadPlayer();
  }

  void loadPlayer() async {
    player = ContactModelPool().getPlayerContact(widget.playerId);
    player!.loadComplete.future.then((_) {
      RoomManager().selectedRoomBloc.add(Update(param: {"roomId": RoomManager().getTwinRoomId(MeModel().playerId!, player!.playerId), "player": player }));
      if(mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ContactManager().goProfilePage(widget.playerId),
        child: Row(
          children: [
            // SizedBox(width: Zeplin.size(20)),
            Align(alignment: Alignment.center, child: ProfileImage(contactModel: player!, isEdit: false, size: 60, offset: Offset(0, -5), isShowBlueDot: player?.relationshipStatus == RelationshipStatus.blocked ? false : true)),
            SizedBox(width: Zeplin.size(12)),
            if(widget.isKnown == false)
              Icon36(Assets.img.ico_36_gy),
            if(widget.isKnown == false)
              SizedBox(width: Zeplin.size(6)),
            Text(player?.smallerName ?? "", style: TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
            SizedBox(width: Zeplin.size(20)),
          ],
        ),
      ),
    );
  }
}