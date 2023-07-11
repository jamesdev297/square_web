import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/profile/square_profile_image.dart';

class EditSquareImage extends StatelessWidget {
  String? squareImgUrl;
  final Uint8List? tempImageData;
  final Function(dynamic) successFunc;
  final VoidCallback onRandomize;
  EditSquareImage({Key? key, required this.squareImgUrl,  this.tempImageData, required this.successFunc, required this.onRandomize}) : super(key: key);

  GlobalKey globalKey = GlobalKey();

  late List<SquarePopUpItem> squarePopUpItems = [
    SquarePopUpItem(
        assetPath: Assets.img.ico_36_edit_bk,
        name: L10n.my_04_01_select_from_album,
        onTap: _selectImage),
    SquarePopUpItem(
        assetPath: Assets.img.ico_36_sync,
        name: L10n.ai_01_randomize,
        onTap:  onRandomize.call),
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: globalKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          SquarePopUpMenu.show(buildContext: context,
              rootWidgetKey: globalKey,
              squarePopUpItems: squarePopUpItems,
              getPopUpOffset: (Offset offset, Size size, Size popUpSize) {
                return GetPopUpOffsetCallbackResponse(Offset(offset.dx , offset.dy + size.height + 10));
              },
              popUpSize: Size(Zeplin.size(198, isPcSize: true), Zeplin.size(82)));
        },
        child: SizedBox(
          width: Zeplin.size(143),
          height: Zeplin.size(143),
          child: Stack(
            children: [
              Center(child: SquareProfileImage(squareImgUrl: squareImgUrl, size: 140, tempImageData: tempImageData)),
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
        ),
      ),
    );
  }

  void _selectImage() async {
    LogWidget.debug("start upload image");
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    Uint8List? bytes = result?.files.single.bytes;
    if (bytes != null) {
      HomeNavigator.push(RoutePaths.common.crop, arguments: {
        "bytes": bytes, "cropType": CropType.profile
      }, popAction: (value) {
        successFunc.call(value);
      });
    }
  }
}
