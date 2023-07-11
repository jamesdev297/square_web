import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/widget/player_online_dot.dart';
import 'package:square_web/widget/profile/circle_profile_image.dart';
import 'package:square_web/widget/profile/hexagon_profile_image.dart';

class RoomProfileImage extends StatelessWidget {
  final RoomModel roomModel;
  const RoomProfileImage({Key? key, required this.roomModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Zeplin.size(52, isPcSize: true),
      height: Zeplin.size(52, isPcSize: true),
      child: Stack(
        children: [
          SizedBox(
            width: Zeplin.size(49, isPcSize: true),
            height: Zeplin.size(49, isPcSize: true),
            child: _buildProfileImage()
          ),

          if(roomModel.contact != null && roomModel.isBlocked != null)
            Align(alignment: Alignment.topRight, child: PlayerOnlineDot(roomModel.contact!.playerId, size: Zeplin.size(14)))
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if(roomModel.isNftTargetProfileImg == true)
      return HexagonProfileImage(profileImgUrl: roomModel.targetProfileImgUrl, size: 93);

    return CircleProfileImage(profileImgUrl: roomModel.targetProfileImgUrl);
  }
}
