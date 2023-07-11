import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class FullScreenSpinner extends StatelessWidget {
  static OverlayEntry? overlayEntry;
  final Stream<MapEntry<String, double>>? progressRatioStream;

  const FullScreenSpinner({Key? key, this.progressRatioStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
          body: Center(
            child:
            progressRatioStream == null
                ? SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80,color: Colors.white)
                : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    StreamBuilder(
                        stream: progressRatioStream,
                        builder: (context, snapshot) {
                          if(!snapshot.hasData)
                            return Container();

                          MapEntry<String, double> data = snapshot.data as MapEntry<String, double>;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              LinearProgressIndicator(
                              value: (data.value),
                              // semanticsLabel: data?.key ?? "",
                              minHeight: Zeplin.size(38),
                            ),
                              Text(data.key)
                            ],
                          );
                        }
                          // Text("${((snapshot.data ?? 0) * 100).toStringAsFixed(2)}%"),
                    ),
                    SizedBox(height: Zeplin.size(38))
                ],
              ),
          )
      ),
    );
  }

  static bool get isShow => overlayEntry == null || overlayEntry?.mounted == true;
  static void show(BuildContext context, {Stream<MapEntry<String, double>>? progressRatioStream}) {
    overlayEntry?.remove();
    overlayEntry = OverlayEntry(builder: (context) => FullScreenSpinner(progressRatioStream: progressRatioStream));
    Overlay.of(context).insert(overlayEntry!);
  }

  static void hide() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}