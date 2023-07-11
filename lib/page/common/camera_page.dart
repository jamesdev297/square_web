import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class CameraPage extends StatefulWidget with HomeWidget {
  CameraPage({Key? key}) : super(key: key);

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  State<StatefulWidget> createState() => _CameraPageState();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.overlayPopUp;

  @override
  bool get dimmedBackground => true;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;

  @override
  double? get maxWidth => PageSize.defaultOverlayMaxWidth;

  @override
  String pageName() => "CameraPage";
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> _cameras = [];
  CameraController? controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    try {
      _cameras = await availableCameras();
      controller = CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false);
      await controller?.initialize();
      isInitialized = true;

      if (mounted) {
        setState(() {});
        return;
      }
    } catch(e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            LogWidget.debug('User denied camera access.');
            showNoCameraPopup();
            break;
          default:
            LogWidget.debug('Handle other errors.');
            showNoCameraPopup();
            break;
        }
      } else {
        showNoCameraPopup();
      }

    }
  }

  void showNoCameraPopup() {
    SquareDefaultDialog.showSquareDialog(
      content: Text(L10n.popup_01_not_found_camera),
      button1Text: L10n.common_02_confirm,
      button1Action: () {
        SquareDefaultDialog.closeDialog().call();
        HomeNavigator.pop();
      }
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async {
        if(isInitialized == false || controller == null)
          return;

        XFile xFile = await controller!.takePicture();

        HomeNavigator.pop(value: await xFile.readAsBytes());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(
              height: Zeplin.size(110),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                child: Row(
                  children: [
                    SizedBox(width: Zeplin.size(46)),
                    Spacer(),
                    Text(L10n.chat_room_10_02_camera, textAlign: TextAlign.center, style: TextStyle(fontSize: Zeplin.size(17, isPcSize: true), color: Colors.white, fontWeight: FontWeight.w500)),
                    Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(child: Icon46(Assets.img.ico_46_x_bk, color: Colors.white), onTap: () => HomeNavigator.pop())),
                  ],
                ),
              ),
            ),
            Expanded(child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: PageSize.defaultOverlayMaxWidth,
                child: _buildCamera()))),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: Zeplin.size(110),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(L10n.chat_room_10_03_take_camera, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamera() {
    if (!isInitialized || controller == null) {
      return Center(child: SquareCircularProgressIndicator());
    }

    return IgnorePointer(child: CameraPreview(controller!));
  }
}
