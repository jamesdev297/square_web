import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/util/string_util.dart';

class CircleProfileImage extends StatefulWidget {
  final String? profileImgUrl;
  final int? modTime;
  const CircleProfileImage({Key? key, required this.profileImgUrl, this.modTime}) : super(key: key);

  @override
  _CircleProfileImageState createState() => _CircleProfileImageState();
}

class _CircleProfileImageState extends State<CircleProfileImage> {

  bool isErrorOccured = false;

  @override
  Widget build(BuildContext context) {
    if(widget.profileImgUrl == null || widget.profileImgUrl == "" || isErrorOccured) {
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: SquareDefaultProfileImage.assetImage);
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(StringUtil.getProfileImgUrlWithModTime(widget.profileImgUrl!, widget.modTime)),
        onBackgroundImageError: (_, __) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              isErrorOccured = true;
            });
          });
        },
      );
    }
  }
}
