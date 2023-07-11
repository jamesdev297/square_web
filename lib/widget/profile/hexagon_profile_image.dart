import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:square_web/constants/constants.dart';

class HexagonProfileImage extends StatefulWidget {
  final String? profileImgUrl;
  final Uint8List? tempProfileImgData;
  final double size;
  const HexagonProfileImage({Key? key, this.profileImgUrl, this.tempProfileImgData, required this.size}) : super(key: key);

  @override
  _HexagonProfileImageState createState() => _HexagonProfileImageState();
}

class _HexagonProfileImageState extends State<HexagonProfileImage> {

  bool isErrorOccured = false;

  @override
  Widget build(BuildContext context) {
    Widget child = _buildImage();

    if(isErrorOccured) {
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: SquareDefaultProfileImage.assetImage);
    } else {

      return Container(
        decoration: ShapeDecoration(
          shape:PolygonShapeBorder(
            sides:6,
            cornerRadius: 20.toPercentLength,
            cornerStyle: CornerStyle.rounded,
          )
        ),
        clipBehavior: Clip.antiAlias,
        child: child
      );
    }
  }

  Widget _buildImage() {
    if(widget.tempProfileImgData != null) {
      return Image.memory(widget.tempProfileImgData!,
        fit: BoxFit.fill,
        errorBuilder: (context, _, __) {
          setState(() {
            isErrorOccured = true;
          });
          return Container();
        }
      );
    }

    return Image.network(widget.profileImgUrl!,
      fit: BoxFit.fill,
      errorBuilder: (context, _, __) {
        setState(() {
          isErrorOccured = true;
        });
        return Container();
      }
    );
  }
}