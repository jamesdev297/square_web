import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/player_online_dot.dart';
import 'package:square_web/widget/profile/circle_profile_image.dart';
import 'package:square_web/widget/profile/hexagon_profile_image.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage(
      {Key? key, required this.contactModel, this.size = 140, this.tempImageData, this.tempNftId, this.isEdit = true, this.offset = Offset.zero, this.isShowBlueDot = false, this.color = Colors.white})
      : super(key: key);

  final double size;
  final ContactModel contactModel;
  final Uint8List? tempImageData;
  final String? tempNftId;
  final bool isEdit;
  final Offset offset;
  final bool isShowBlueDot;
  final Color color;

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Zeplin.size(widget.size + 3),
      height: Zeplin.size(widget.size + 3),
      child: Stack(
        children: [
          SizedBox(
            width: Zeplin.size(widget.size),
            height: Zeplin.size(widget.size),
            child: _buildProfileImage()
          ),
          if(widget.isShowBlueDot == true)
            Align(
              alignment: Alignment.topRight,
              child: widget.contactModel.playerId == MeModel().playerId ? Container(
                width: Zeplin.size(14),
                height: Zeplin.size(14),
                decoration: BoxDecoration(
                    color: CustomColor.dartMint,
                    shape: BoxShape.circle
                ),
              ): Transform.translate(offset : widget.offset, child: PlayerOnlineDot(widget.contactModel.playerId, size: Zeplin.size(14))),
            ),

          if(widget.isEdit == true && widget.contactModel.playerId == MeModel().playerId)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  height: Zeplin.size(49),
                  width: Zeplin.size(49),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      shape: BoxShape.circle,
                      color: CustomColor.paleGrey
                  ),
                  child: Center(child: Icon24(Assets.img.ico_26_plus_gray))),
            )
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (widget.tempImageData != null && widget.tempNftId != null)
      return HexagonProfileImage(tempProfileImgData: widget.tempImageData, size: widget.size);
    else if (widget.tempImageData != null)
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(widget.tempImageData!),
      );
    else if (widget.contactModel.isPfpProfile)
      return FutureBuilder(
          future: widget.contactModel.loadComplete.future,
          builder: (context, snapshot) {
            return HexagonProfileImage(profileImgUrl: widget.contactModel.profileImgUrl, size: widget.size);
          }
      );
    return FutureBuilder(
        future: widget.contactModel.loadComplete.future,
        builder: (context, snapshot) {
          return CircleProfileImage(profileImgUrl: widget.contactModel.profileImgUrl);
        });
  }
}
