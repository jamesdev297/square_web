import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/page/square/square_chat_page.dart';
import 'package:square_web/page/room/chat_page.dart';

// ignore: must_be_immutable
class ToastOverlay extends StatefulWidget {

  static ToastOverlay _instance = ToastOverlay._internal();
  OverlayEntry? overlayEntry;
  Text? textWidget;
  HomeWidget? homeWidget;
  Duration? duration;
  Color? backgroundColor;

  ToastOverlay._internal();

  static void show({required BuildContext buildContext, required HomeWidget rootWidget, Text? textWidget, String? text, Color? backgroundColor, Color? textColor, Duration? duration})
    => _instance._show(buildContext: buildContext, rootWidget: rootWidget, textWidget: textWidget, text: text, backgroundColor: backgroundColor, textColor: textColor, duration: duration);
  static void get hide => _instance._hide();

  void _show({required BuildContext buildContext, required HomeWidget rootWidget, Text? textWidget, String? text, Color? backgroundColor, Color? textColor, Duration? duration}) async {
      this.homeWidget = rootWidget;
      this.textWidget = textWidget ?? Text(text ?? L10n.common_18_copied, textAlign: TextAlign.center, style: TextStyle(color: textColor ?? CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(14, isPcSize: true)));
      this.duration = duration;
      this.backgroundColor = backgroundColor;

    if(overlayEntry != null) {
      _hide();
    }

    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (context) => this);
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
  _ToastOverlayState createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> with TickerProviderStateMixin {

  AnimationController? _copyController;
  Timer? timer;
  RenderBox? renderBox;
  Offset? startOffset;
  Size? bound;
  late Widget internalWidget;
  GlobalKey internalWidgetKey = GlobalKey();
  Completer<Size> internalSizeCompleter = Completer();

  @override
  void initState() {
    super.initState();

    bool isMobile = screenWidthNotifier.value < maxWidthMobile;
    if(!isMobile) {
      if(widget.homeWidget != null) {
        renderBox = HomeNavigator.getHomeWidgetRenderBox(widget.homeWidget!);
        if(renderBox != null) {
          startOffset = renderBox!.localToGlobal(Offset.zero);
          bound = renderBox!.size;
          if(bound!.width > maxWidthChatPage && (widget.homeWidget!.pageName() == SquareChatPage.name || widget.homeWidget!.pageName() == ChatPage.name)) {
             bound = Size(maxWidthChatPage, renderBox!.size.height);
          }
        }
      }
    }


    _copyController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300)
    );

    _copyController!.forward();

    timer = Timer(widget.duration ?? Duration(milliseconds: 600), () {
      if(_copyController!.isCompleted) {
        _copyController?.reverse(from: 1.0).then((_) => ToastOverlay.hide);
      }
    });

    internalWidget = AnimatedBuilder(
        key: internalWidgetKey,
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
                color: widget.backgroundColor ?? CustomColor.paleGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset.zero
                  ),
                ]
              ),
              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(20, isPcSize: true)),
              // width: Zeplin.size(163, isPcSize: true),
              height: Zeplin.size(47, isPcSize: true),
              child: Center(
                child: widget.textWidget!,
              )
          ),
        )
    );
  }


  @override
  void dispose() {
    timer?.cancel();
    _copyController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var interBox = internalWidgetKey.currentContext?.findRenderObject() as RenderBox?;
      if(interBox?.size != null) {
        internalSizeCompleter.complete(interBox!.size);
      }
    });

    bool isMobile = screenWidthNotifier.value < maxWidthMobile;
    if(isMobile) {
      return Stack(
        children: [
          Center(
            child: Row(
              children: [
                Spacer(),
                internalWidget,
                Spacer(),
              ],
            )
          )
        ],
      );
    }

    if(renderBox == null || startOffset == null || bound == null) return Container();

    return FutureBuilder<Size>(
      future: internalSizeCompleter.future,
        builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data != null) {
            Size data = snapshot.data!;
            return Stack(
              children: [
                Positioned(
                    left: startOffset!.dx + bound!.width/2 - data.width/2,
                    top: startOffset!.dy + bound!.height/2 - data.height/2,
                    child: internalWidget
                )
              ],
            );
          }
        }
        return Stack(
          children: [
            Positioned(
                left: startOffset!.dx + bound!.width/2,
                top: startOffset!.dy + bound!.height/2,
                child: internalWidget
            )
          ],
        );
    });
  }
}
