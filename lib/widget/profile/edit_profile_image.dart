import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/profile/profile_image.dart';

class EditProfileImage extends StatefulWidget {
  final ContactModel contactModel;
  final Uint8List? tempImageData;
  final String? tempNftId;
  final Function(dynamic)? successFunc;
  EditProfileImage({Key? key, required this.contactModel, this.tempImageData, this.tempNftId, this.successFunc}) : super(key: key);

  @override
  State<EditProfileImage> createState() => _EditProfileImageState();
}

class _EditProfileImageState extends State<EditProfileImage> {
  GlobalKey globalKey = GlobalKey();

  late List<SquarePopUpItem> squarePopUpItems = [
    SquarePopUpItem(
        assetPath: Assets.img.ico_36_edit_bk,
        name: L10n.my_04_01_select_from_album,
        onTap: () {
          _selectImage();
        }),
    SquarePopUpItem(
        assetPath: Assets.img.ico_36_imti_bk,
        name: L10n.my_04_03_select_default,
        onTap: () {
          widget.contactModel.profileImgUrl = null;
          widget.successFunc?.call(false);
        }),
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: globalKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
           SquarePopUpMenu.show(buildContext: context,
              rootWidgetKey: globalKey,
              squarePopUpItems: squarePopUpItems,
              getPopUpOffset: (Offset offset, Size size, Size popUpSize) {
                return GetPopUpOffsetCallbackResponse(Offset(offset.dx , offset.dy + size.height + 10));
              },
              popUpSize: Size(Zeplin.size(198, isPcSize: true), Zeplin.size(82)));
        },
        child: ProfileImage(contactModel: widget.contactModel, tempImageData: widget.tempImageData, tempNftId: widget.tempNftId, size: 140),
      ),
    );
  }

  void _selectImage() async {
    LogWidget.debug("start upload image3");
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    Uint8List? bytes = result?.files.single.bytes;
    if (bytes != null) {
      HomeNavigator.push(RoutePaths.common.crop, arguments: {
        "bytes": bytes, "cropType": CropType.profile
      }, popAction: (value) {
        widget.successFunc?.call(value);
      });
    }
  }
}
