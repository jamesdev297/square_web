// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/home/navigator/home_navigator.dart';
// import 'package:square_web/model/message/message_model.dart';
// import 'package:square_web/util/device_util.dart';
// import 'package:square_web/widget/button.dart';
// import 'package:video_player/video_player.dart';
// import 'package:square_web/widget/panel/image_option_panel.dart';
// import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
// import 'package:square_web/widget/video_player/progress_bar.dart';
// import 'package:square_web/debug/overlay_logger_widget.dart';
//
// class ViewFullVideoPage extends StatefulWidget with HomeWidget {
//   final MessageModel? messageModel;
//
//   ViewFullVideoPage(this.messageModel);
//
//   @override
//   State<StatefulWidget> createState() => _ViewFullVideoPageState();
//
//   @override
//   MenuPack get getMenuPack => MenuPack();
//
//   @override
//   HomeWidgetType get widgetType => HomeWidgetType.allDepthPopUp;
//
//   @override
//   bool get dimmedBackground => true;
//
//   @override
//   EdgeInsetsGeometry? get padding => PageSize.defaultAllDepthPopUpPadding;
//
//   @override
//   double? get maxWidth => PageSize.defaultAllDepthPopUpMaxWidth;
// }
//
//
// class _ViewFullVideoPageState extends State<ViewFullVideoPage> with TickerProviderStateMixin {
//
//   AnimationController? copyController;
//   Timer? timer;
//   VideoPlayerController? _controller;
//   bool isVisibleTopMenu = true;
//   bool waiting = true;
//   bool isExpired = false;
//   final StreamController<bool> streamController = StreamController.broadcast();
//
//   @override
//   void initState() {
//     init();
//
//     copyController = AnimationController(
//         vsync: this,
//         duration: Duration(milliseconds: 600)
//     );
//
//     super.initState();
//   }
//
//   Future<void> init() async {
//
//     try {
//
//       _controller = VideoPlayerController.network(widget.messageModel!.fullContentUrl!);
//
//       _controller!.initialize().then((_) {
//         waiting = false;
//         setState(() {});
//       });
//
//     } catch(e) {
//       LogWidget.debug("Error : $e");
//       isExpired = true;
//       setState(() {});
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     copyController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//         color: Colors.black,
//           child: isExpired == true ? Stack(
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Image.asset(Assets.img.ico_100_expired_mov, height: Zeplin.size(95), width: Zeplin.size(95)),
//                   SizedBox(height: Zeplin.size(19)),
//                   Text(L10n.fileExpired, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(30), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
//                 ],
//               ),
//
//               _buildTopMenu(),
//             ],
//           ) :
//           waiting == false ? Stack(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   isVisibleTopMenu = !isVisibleTopMenu;
//                   streamController.add(isVisibleTopMenu);
//                 },
//                 child: Center(
//                   child: AspectRatio(
//                     aspectRatio: _controller!.value.aspectRatio,
//                     child: VideoPlayer(_controller!),
//                   ),
//                 ),
//               ),
//
//               _buildTopMenu(),
//               _buildBottomMenu(),
//               IgnorePointer(
//                 child: Center(
//                   child: AnimatedBuilder(
//                     animation: copyController!,
//                     builder: (context, child) {
//                       return Opacity(
//                           opacity: copyController!.value,
//                           child: child
//                       );
//                     },
//                     child: Container(
//                         decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: AssetImage(Assets.img.dim), fit: BoxFit.fill)),
//                         width: Zeplin.size(284),
//                         height: Zeplin.size(284),
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(Assets.img.ico_ch_70, width: Zeplin.size(95)),
//                               Text(L10n.saved, style: TextStyle(color: Colors.white)),
//                             ],
//                           ),
//                         )
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ) : Center(child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80))
//
//       );
//   }
//
//   Widget _buildTopMenu() {
//
//     return StreamBuilder<bool>(
//         stream: streamController.stream,
//         initialData: true,
//         builder: (_,  AsyncSnapshot<bool> snapshot) {
//           return AnimatedSwitcher(
//             duration: Duration(milliseconds: 200),
//             child: snapshot.data! ? Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   height: Zeplin.size(246),
//                   color: Colors.black,
//                   child: SafeArea(
//                     minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(23)),
//                     bottom: false,
//                     child: Column(
//                       children: [
//                         SizedBox(height: spaceM),
//                         Row(
//                           children: [
//                             Expanded(flex: 2, child: Align(child: GestureDetector(child: SizedBox(height: Zeplin.size(95), width: Zeplin.size(95), child: Center(child: Icon46(Assets.img.ico_46_arrow_w, ratio: 0.5,),),), onTap: () => HomeNavigator.pop()), alignment: Alignment.centerLeft)),
//                             Expanded(flex: 10, child: Align(child: Container(
//                                 height: Zeplin.size(95),
//                                 child: Center(
//                                     child: Text(L10n.videos, textAlign: TextAlign.center, style: TextStyle(fontSize: titleFontSize, color: Colors.white, fontFamily: Zeplin.robotoBold)
//                                     )
//                                 ), alignment: Alignment.center))),
//                             Expanded(
//                                 flex: 2,
//                                 child: Align(
//                                     child: isExpired == false ?
//                                     GestureDetector(child: SizedBox(height: Zeplin.size(95), width: Zeplin.size(95), child: Center(child: Icon46(Assets.img.ico_46_more_w, ratio: 0.5,),),), onTap: () => showModalBottomSheet(
//                                         useRootNavigator: true,
//                                         barrierColor: CustomColor.backgroundYellow,
//                                         backgroundColor: Colors.transparent,
//                                         context: context,
//                                         builder: (context) {
//                                           return ImageOptionPanel(widget.messageModel, copyController, timer);
//                                         }))
//                                         : Container(), alignment: Alignment.centerRight)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//             ) : Container(),
//           );
//         }
//     );
//   }
//
//   Widget _buildBottomMenu() {
//
//     return StreamBuilder<bool>(
//         stream: streamController.stream,
//         initialData: true,
//         builder: (_, AsyncSnapshot<bool> snapshot) {
//           return AnimatedSwitcher(
//             duration: Duration(milliseconds: 200),
//             child: snapshot.data! ? Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: Zeplin.size(284),
//                 color: Colors.grey.withOpacity(0.5),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(height: spaceML),
//                     Container(
//                         width: DeviceUtil.screenWidth*0.9,
//                         height: Zeplin.size(19),
//                         child: BetterPlayerMaterialVideoProgressBar(_controller)),
//                     SizedBox(height: spaceM),
//                     ValueListenableBuilder(
//                       valueListenable: _controller!,
//                       builder: (context, VideoPlayerValue value, child) {
//
//                         String nowTime = "00:00";
//                         String endTime = "00:00";
//
//                         Duration nowDuration = Duration(milliseconds: value.position.inMilliseconds.round());
//
//                         nowTime = [nowDuration.inMinutes, nowDuration.inSeconds]
//                             .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
//                             .join(':');
//
//
//                         Duration endDuration = Duration(milliseconds: value.duration.inMilliseconds.round());
//
//                         endTime = [endDuration.inMinutes, endDuration.inSeconds]
//                             .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
//                             .join(':');
//
//                         return Row(
//                           children: [
//                             SizedBox(width: DeviceUtil.screenWidth*0.05),
//                             Text("$nowTime", style: TextStyle(color: Colors.white, fontSize: Zeplin.size(22), fontWeight: FontWeight.w500)),
//                             Spacer(),
//                             Text("$endTime", style: TextStyle(color: Colors.white, fontSize: Zeplin.size(22), fontWeight: FontWeight.w500)),
//                             SizedBox(width: DeviceUtil.screenWidth*0.05),
//                           ],
//                         );
//                       },
//                       child: null,
//                     ),
//                     SizedBox(height: Zeplin.size(25)),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         SizedBox(width: spaceL),
//                         GestureDetector(
//                             onTap: () {
//                               _controller!.value.volume != 0.0 ?
//                               _controller!.setVolume(0) : _controller!.setVolume(1);
//                               setState(() {});
//                             },
//                             child: Icon60(_controller!.value.volume != 0.0 ? Assets.img.ico_60_sound_on : Assets.img.ico_60_sound_off)
//                         ),
//                         Spacer(),
//                         GestureDetector(
//                           onTap: () {
//
//
//                             setState(() {
//                               _controller!.value.isPlaying
//                                   ? _controller!.pause()
//                                   : _controller!.play();
//                             });
//                           },
//                           child: Image.asset( _controller!.value.isPlaying ? Assets.img.ico_100_play_off : Assets.img.ico_100_play_on, width: Zeplin.size(95), height: Zeplin.size(95),),
//                         ),
//                         Spacer(),
//                         Container(width: Zeplin.size(57)),
//                         SizedBox(width: spaceL),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ) : Container(),
//           );
//         }
//     );
//   }
//
// }
