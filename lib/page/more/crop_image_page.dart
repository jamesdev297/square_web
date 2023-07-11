import 'dart:async';
import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:image/image.dart' as img;
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class CropImagePage extends StatefulWidget with HomeWidget {
  Uint8List imageBytes;
  final PlayerNftModel? playerNftModel;
  final CropType cropType;
  final bool? isCameraBeforePage;
  final bool? isNftListBeforePage;
  final StreamController tapSubmitController = StreamController();

  CropImagePage({ Key? key, required this.imageBytes, this.playerNftModel, required this.cropType, this.isCameraBeforePage = false, this.isNftListBeforePage = false }) : super(key: key);

  @override
  _CropImagePageState createState() => _CropImagePageState();

  @override
  String pageName() => "CropImagePage";

  MenuPack get getMenuPack => MenuPack(
    leftMenu: isCameraBeforePage == true || isNftListBeforePage == true ? MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(child: Center(child: Icon46(Assets.img.ico_46_arrow_w)),
        onTap: () => HomeNavigator.pop(value: true),
      ),
    ) : null,
    centerMenu: Text(L10n.my_05_01_cut, style: TextStyle(fontSize: Zeplin.size(34), fontWeight: FontWeight.w500, color: Colors.white)),
    padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)),
    rightMenu: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: ()  {
          if(isNftListBeforePage == true)
            HomeNavigator.pop();
          HomeNavigator.pop();
        },
        child: Icon46(Assets.img.ico_46_close_we),
      ),
    ),
  );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.overlayPopUp;

  @override
  bool get dimmedBackground => true;

  // @override
  // EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;

  @override
  double? get maxWidth => PageSize.defaultOverlayMaxWidth;

  @override
  double? get maxHeight => PageSize.defaultOverlayMaxHeight;
}

class _CropImagePageState extends State<CropImagePage> {
  
  bool isLoaded = false;
  final controller = CropController(aspectRatio: 1, defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9));

  @override
  void initState() {
    super.initState();

    if(widget.imageBytes.length > 1048576) { // 1mb
      ImageUtil.resizeImageWeb(widget.imageBytes, 'image/png').then((value) {
        isLoaded = true;

        widget.imageBytes = value!;
        setState(() {});
      });
    } else {
      isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: Zeplin.size(100)),
          Expanded(
            child: Center(
              child: isLoaded ? CropImage(
                image: Image.memory(widget.imageBytes),
                controller: controller,
                cropType: widget.cropType,
              ) : SquareCircularProgressIndicator(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(Zeplin.size(34)),
        child: SizedBox(
          height: Zeplin.size(94),
          child: PebbleRectButton(
            onPressed:() async {
              FullScreenSpinner.show(context);
              await Future.delayed(Duration(milliseconds: 200));

              Rect croppedRect = controller.croppedRect();
              img.Image? src = img.decodeImage(widget.imageBytes);
              if(src != null) {
                img.Image cropped = img.copyCrop(src, (src.width*croppedRect.topLeft.dx).toInt(), (src.height*croppedRect.topLeft.dy).toInt(), (src.width*croppedRect.width).toInt(), (src.height*croppedRect.height).toInt());
                var png = img.encodePng(cropped);
                final uint8List = Uint8List.fromList(png);
                HomeNavigator.pop(value: { "bytes": uint8List, "nftId": widget.playerNftModel?.cursorId, "isNftListBeforePage" : widget.isNftListBeforePage });
              }
            },
            backgroundColor: CustomColor.azureBlue,
            borderColor: CustomColor.azureBlue,
            child: Center(child: Text(widget.cropType == CropType.message ? L10n.chat_room_10_01_send_image: L10n.my_05_02_save_profile_image, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: Colors.white)))),
        ),
      ),
    );
  }
}

