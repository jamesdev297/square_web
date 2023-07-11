// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:crop/crop.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/home/navigator/home_navigator.dart';
// import 'package:square_web/model/player_nft_model.dart';
// import 'package:square_web/util/device_util.dart';
// import 'package:square_web/widget/button.dart';
// import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
//
// import 'package:image/image.dart' as im;
//
// class CropProfileImagePage extends StatefulWidget with HomeWidget {
//   final Uint8List imageBytes;
//   final PlayerNftModel? playerNftModel;
//   final bool? isEditPage;
//   final StreamController tapSubmitController = StreamController();
//
//   CropProfileImagePage({required this.imageBytes, this.playerNftModel, this.isEditPage = false});
//
//   @override
//   State<StatefulWidget> createState() => _CropProfileImagePageState();
//
//   @override
//   MenuPack get getMenuPack => MenuPack(
//     leftMenu: GestureDetector(child: SizedBox(height: Zeplin.size(46), width: Zeplin.size(46),
//         child: Center(child: Icon46(Assets.img.ico_46_arrow_bk, color: Colors.black))),
//         onTap: () => HomeNavigator.pop(),
//       ),
//     centerMenu: Text(L10n.my_05_01_cut, style: TextStyle(fontSize: Zeplin.size(34), fontWeight: FontWeight.w500, color: Colors.black)),
//     padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)),
//   rightMenu: InkWell(
//     onTap: () async {
//       tapSubmitController.add(true);
//     },
//     child: Text(L10n.my_05_02_save_profile_image, style: TextStyle(color: CustomColor.azureBlue),)),
//   );
//
//   @override
//   HomeWidgetType get widgetType => HomeWidgetType.overlay;
//
//   @override
//   bool get dimmedBackground => true;
//
//   @override
//   EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;
//
//   @override
//   double? get maxWidth => PageSize.defaultOverlayMaxWidth;
// }
//
// class _CropProfileImagePageState extends State<CropProfileImagePage> {
//   final controller = CropController(aspectRatio: 1);
//   BoxShape shape = BoxShape.circle;
//
//   double widthOffset = 1;
//   double heightOffset = 1;
//   late Size sourceSize;
//   late Size inputSize;
//   double ratio = 1.0;
//
//   Offset? bottomLeft;
//   Offset? topRight;
//
//   bool isSubmitting = false;
//
//   late double rectSize;
//   late bool isDesktopWidth;
//
//   double lastScale = 1;
//   late double tempLastScale = lastScale;
//
//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//     widget.tapSubmitController.close();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     MemoryImage image = MemoryImage(widget.imageBytes);
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       image.resolve(ImageConfiguration.empty).completer?.addListener(ImageStreamListener((img, sync) {
//
//         inputSize = Size(img.image.width * 1.0, img.image.height * 1.0);
//         Size outputSize = Size(rectSize, rectSize);
//
//         if (outputSize.width / outputSize.height > inputSize.width / inputSize.height) {
//           ratio = outputSize.width / inputSize.width;
//           sourceSize = Size(inputSize.width, inputSize.width * outputSize.height / outputSize.width);
//         } else {
//           ratio = outputSize.height / inputSize.height;
//           sourceSize = Size(inputSize.height * outputSize.width / outputSize.height, inputSize.height);
//         }
//
//         widthOffset = (inputSize.width - sourceSize.width)/2*ratio;
//         heightOffset = (inputSize.height - sourceSize.height)/2*ratio;
//         controller.marginOffset = Offset(widthOffset, heightOffset);
//
//         updateCrop();
//
//       }));
//     });
//
//     widget.tapSubmitController.stream.listen((event) async {
//       if(isSubmitting) {
//         return ;
//       }
//       FullScreenSpinner.show(context);
//
//       isSubmitting = true;
//       setState(() {
//
//       });
//
//
//       im.Image? src = im.decodeImage(widget.imageBytes);
//       if(src != null) {
//         im.Image cropped = im.copyCrop(src, bottomLeft!.dx.floor(), bottomLeft!.dy.floor(),
//             (topRight!.dx-bottomLeft!.dx).floor(), (topRight!.dy-bottomLeft!.dy).floor());
//         im.Image resized = im.copyResize(cropped, width: 170, height: 170);
//         var png = im.encodePng(resized);
//         final uint8List = Uint8List.fromList(png);
//         FullScreenSpinner.hide();
//         HomeNavigator.pop(value: { "bytes": uint8List, "nftId": widget.playerNftModel?.cursorId });
//       }
//
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     isDesktopWidth = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;
//     rectSize = isDesktopWidth ? 500 : 200;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           SizedBox(height: Zeplin.size(100)),
//           Expanded(
//             child: Stack(
//               children: [
//                 Center(
//                   child: SizedBox(
//                     width: rectSize,
//                     height: rectSize,
//                     // TODO 원형 dim 해야함 (ux 나오면 적용 예정)
//                     child: Crop(
//                       onChanged: (decomposition) {
//
//                       },
//                       shape: shape,
//                       controller: controller,
//                       foreground: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white, width: 2),
//                           shape: BoxShape.rectangle,
//                         ),
//                       ),
//                       child: Image.memory(
//                         widget.imageBytes,
//                         fit: BoxFit.cover,
//                         filterQuality: FilterQuality.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IgnorePointer(
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: ColorFiltered(
//                       colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.srcOut),
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Align(
//                             alignment: Alignment.topCenter,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 Center(
//                   child: Listener(
//                     onPointerSignal: (PointerEvent details) {
//                       if(!DeviceUtil.isMobileWeb) {
//                         if(details is PointerScrollEvent) {
//                           controller.scale = min(4, controller.scale - details.scrollDelta.dy / 30);
//                           updateCrop();
//                         }
//                       }
//                     },
//                     child: GestureDetector(
//                       onScaleUpdate: (evt) {
//                         if(isSubmitting)
//                           return ;
//                         if(DeviceUtil.isMobileWeb) {
//                           controller.scale = min(4, lastScale * (evt.scale));
//                           tempLastScale = controller.scale;
//                           updateCrop();
//                         }
//                         controller.offset += evt.focalPointDelta;
//                       },
//                       onScaleEnd: (evt) {
//                         lastScale = tempLastScale;
//                         updateCrop();
//                         setState(() {
//                         });
//                       },
//                       child: Container(
//                         width: rectSize,
//                         height: rectSize,
//                         color: Colors.orangeAccent.withOpacity(0.0)
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void updateCrop() {
//     if(sourceSize == null || inputSize == null) {
//       return ;
//     }
//     final width = sourceSize.width/2.0;
//     final height = sourceSize.height/2.0;
//     final centerX = -(controller.offset.dx / controller.scale) / ratio;
//     final centerY = (controller.offset.dy / controller.scale) / ratio;
//
//     final rightX = centerX + width/controller.scale + inputSize.width/2;
//     final leftX = centerX - width/controller.scale + inputSize.width/2;
//
//     final topY = centerY + height/controller.scale + inputSize.height/2;
//     final bottomY = centerY - height/controller.scale + inputSize.height/2;
//
//     bottomLeft = Offset(leftX, bottomY);
//     topRight = Offset(rightX, topY);
//   }
// }