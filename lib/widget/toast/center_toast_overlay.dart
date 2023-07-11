import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';


// ignore: must_be_immutable
class CenterToastOverlay extends StatefulWidget {

  static CenterToastOverlay _instance = CenterToastOverlay._internal();
  OverlayEntry? overlayEntry;
  Text? textWidget;
  LayerLink? layerLink;

  CenterToastOverlay._internal();

  static void show({required BuildContext buildContext, Text? textWidget, String? text, LayerLink? layerLink })
    => _instance._show(buildContext: buildContext, textWidget: textWidget, text: text, layerLink: layerLink);
  static void get hide => _instance._hide();

  void _show({required BuildContext buildContext, Text? textWidget, String? text, LayerLink? layerLink}) async {
    this.textWidget = textWidget ?? Text(text ?? L10n.common_18_copied, textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(14, isPcSize: true)));
    this.layerLink = layerLink;

    if(overlayEntry != null) {
      _hide();
    }

    if (overlayEntry == null) {


      bool isMobile = screenWidthNotifier.value < maxWidthMobile;
      if(isMobile) {
        overlayEntry = OverlayEntry(builder: (context) => this);
      } else {

        overlayEntry = OverlayEntry(builder: (context) => Positioned(
          width: Zeplin.size(163, isPcSize: true),
          height: Zeplin.size(47, isPcSize: true),
          child: CompositedTransformFollower(
            offset: Offset.zero,
            link: layerLink!, child: this)));
      }

      Overlay.of(buildContext).insert(overlayEntry!);
    }
  }

  void _hide() async {
    if(overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  @override
  _CenterToastOverlayState createState() => _CenterToastOverlayState();
}

class _CenterToastOverlayState extends State<CenterToastOverlay> with TickerProviderStateMixin {

  AnimationController? _copyController;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    _copyController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300)
    );

    _copyController!.forward();

    timer = Timer(Duration(milliseconds: 600), () {
      if(_copyController!.isCompleted) {
        _copyController?.reverse(from: 1.0).then((_) => CenterToastOverlay.hide);
      }
    });

  }


  @override
  void dispose() {
    timer?.cancel();
    _copyController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: _copyController!,
            builder: (context, child) {
              return Opacity(
                  opacity: _copyController!.value,
                  child: child
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                  color: CustomColor.paleGrey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset.zero
                    ),
                  ],
                ),
                width: Zeplin.size(163, isPcSize: true),
                height: Zeplin.size(47, isPcSize: true),
                child: Center(
                  child: widget.textWidget!,
                )
              ),
            )
          ),
        )
      ],
    );
  }
}
