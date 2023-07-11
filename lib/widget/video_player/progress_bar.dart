// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class BetterPlayerMaterialVideoProgressBar extends StatefulWidget {
//   BetterPlayerMaterialVideoProgressBar(
//       this.controller, {
//         this.onDragEnd,
//         this.onDragStart,
//         this.onDragUpdate,
//         Key? key,
//       }) : super(key: key);
//
//   final VideoPlayerController? controller;
//   final Function()? onDragStart;
//   final Function()? onDragEnd;
//   final Function()? onDragUpdate;
//
//   @override
//   _VideoProgressBarState createState() {
//     return _VideoProgressBarState();
//   }
// }
//
// class _VideoProgressBarState
//     extends State<BetterPlayerMaterialVideoProgressBar> {
//   _VideoProgressBarState() {
//     listener = () {
//       setState(() {});
//     };
//   }
//
//   late VoidCallback listener;
//   bool _controllerWasPlaying = false;
//
//   VideoPlayerController? get controller => widget.controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller!.addListener(listener);
//   }
//
//   @override
//   void deactivate() {
//     controller!.removeListener(listener);
//     super.deactivate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     void seekToRelativePosition(Offset globalPosition) {
//       final box = context.findRenderObject() as RenderBox;
//       final Offset tapPos = box.globalToLocal(globalPosition);
//       final double relative = tapPos.dx / box.size.width;
//       if (relative > 0) {
//         final Duration position = controller!.value.duration * relative;
//         controller!.seekTo(position);
//       }
//     }
//
//     final bool enableProgressBarDrag = true;
//     final Size size = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);
//
//     return GestureDetector(
//       onHorizontalDragStart: (DragStartDetails details) {
//         if (!controller!.value.isInitialized || !enableProgressBarDrag) {
//           return;
//         }
//
//         _controllerWasPlaying = controller!.value.isPlaying;
//         if (_controllerWasPlaying) {
//           controller!.pause();
//         }
//
//         if (widget.onDragStart != null) {
//           widget.onDragStart!();
//         }
//       },
//       onHorizontalDragUpdate: (DragUpdateDetails details) {
//         if (!controller!.value.isInitialized || !enableProgressBarDrag) {
//           return;
//         }
//
//         seekToRelativePosition(details.globalPosition);
//
//         if (widget.onDragUpdate != null) {
//           widget.onDragUpdate!();
//         }
//       },
//       onHorizontalDragEnd: (DragEndDetails details) {
//         if (!enableProgressBarDrag) {
//           return;
//         }
//
//         if (_controllerWasPlaying) {
//           controller!.play();
//         }
//
//         if (widget.onDragEnd != null) {
//           widget.onDragEnd!();
//         }
//       },
//       onTapDown: (TapDownDetails details) {
//         if (!controller!.value.isInitialized || !enableProgressBarDrag) {
//           return;
//         }
//         seekToRelativePosition(details.globalPosition);
//       },
//       child: Center(
//         child: Container(
//           height: size.height,
//           width: size.width,
//           color: Colors.transparent,
//           child: CustomPaint(
//             size: size,
//             painter: _ProgressBarPainter(
//               controller!.value,
//               ProgressColors(
//                   playedColor: Colors.white,
//                   handleColor: Colors.white,
//                   bufferedColor: Colors.white70,
//                   backgroundColor: Colors.white60)
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ProgressBarPainter extends CustomPainter {
//   _ProgressBarPainter(this.value, this.colors);
//
//   VideoPlayerValue value;
//   ProgressColors colors;
//
//   @override
//   bool shouldRepaint(CustomPainter painter) {
//     return true;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     const height = 2.0;
//
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromPoints(
//           Offset(0.0, size.height / 2),
//           Offset(size.width, size.height / 2 + height),
//         ),
//         const Radius.circular(4.0),
//       ),
//       colors.backgroundPaint,
//     );
//     if (!value.isInitialized) {
//       return;
//     }
//     final double playedPartPercent = value.position.inMilliseconds / value.duration.inMilliseconds;
//     final double playedPart = playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
//     for (final DurationRange range in value.buffered) {
//       final double start = range.startFraction(value.duration) * size.width;
//       final double end = range.endFraction(value.duration) * size.width;
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromPoints(
//             Offset(start, size.height / 2),
//             Offset(end, size.height / 2 + height),
//           ),
//           const Radius.circular(4.0),
//         ),
//         colors.bufferedPaint,
//       );
//     }
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromPoints(
//           Offset(0.0, size.height / 2),
//           Offset(playedPart, size.height / 2 + height),
//         ),
//         const Radius.circular(4.0),
//       ),
//       colors.playedPaint,
//     );
//
//     canvas.drawCircle(
//       Offset(playedPart, size.height / 2 + height / 2),
//       height * 8,
//       colors.padPaint,
//     );
//
//     canvas.drawCircle(
//       Offset(playedPart, size.height / 2 + height / 2),
//       height * 3,
//       colors.handlePaint,
//     );
//   }
// }
//
// class ProgressColors {
//   ProgressColors({
//     Color playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
//     Color bufferedColor = const Color.fromRGBO(30, 30, 200, 0.2),
//     Color handleColor = const Color.fromRGBO(200, 200, 200, 1.0),
//     Color backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
//     Color padColor = const Color.fromRGBO(255, 255, 255, 0.15),
//   })  : playedPaint = Paint()..color = playedColor,
//         bufferedPaint = Paint()..color = bufferedColor,
//         handlePaint = Paint()..color = handleColor,
//         backgroundPaint = Paint()..color = backgroundColor,
//         padPaint = Paint()..color = padColor;
//
//   final Paint playedPaint;
//   final Paint bufferedPaint;
//   final Paint handlePaint;
//   final Paint backgroundPaint;
//   final Paint padPaint;
// }
