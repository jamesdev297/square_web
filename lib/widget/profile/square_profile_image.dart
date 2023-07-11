import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/profile/circle_profile_image.dart';

class SquareProfileImage extends StatelessWidget {
  const SquareProfileImage(
      {Key? key, required this.squareImgUrl, this.size = 140, this.offset = Offset.zero, this.color = Colors.white, this.tempImageData})
      : super(key: key);

  final Uint8List? tempImageData;
  final double size;
  final String? squareImgUrl;
  final Offset offset;
  final Color color;

  @override
  Widget build(BuildContext context) {

    late Widget child;
    if (tempImageData != null)
      child = CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(tempImageData!),
      );
    else
      child = CircleProfileImage(profileImgUrl: squareImgUrl);

    return SizedBox(
      width: Zeplin.size(size + 3),
      height: Zeplin.size(size + 3),
      child: SizedBox(
          width: Zeplin.size(size),
          height: Zeplin.size(size),
          child: child
      ),
    );
  }
}
