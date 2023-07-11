

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
typedef GetPopUpOffsetCallbackResponse GetPopUpOffsetCallback(Offset startOffset, Size rootWidgetSize, Size popUpSize);

class GetPopUpOffsetCallbackResponse {
  Offset startOffset;
  bool isSlideUp;
  GetPopUpOffsetCallbackResponse(this.startOffset, {this.isSlideUp = false});
}

class SquarePopUpItem {
  String assetPath;
  String name;
  Widget? nameWidget;
  VoidCallback onTap;

  SquarePopUpItem({required this.assetPath, required this.name, this.nameWidget, required this.onTap});
}

class SquarePopUpMenu extends StatefulWidget {
  static SquarePopUpMenu _instance = SquarePopUpMenu._internal();


  late List<SquarePopUpItem> squarePopUpItems;
  OverlayEntry? overlayEntry;
  late GlobalKey rootWidgetKey;
  GetPopUpOffsetCallback? getPopUpOffset;
  late Size popUpSize;
  VoidCallback? onCancel;

  SquarePopUpMenu._internal();


  static void show({required BuildContext buildContext, required GlobalKey rootWidgetKey, required List<SquarePopUpItem> squarePopUpItems, GetPopUpOffsetCallback? getPopUpOffset, Size? popUpSize, VoidCallback? onCancel})
  => _instance._show(buildContext: buildContext, rootWidgetKey: rootWidgetKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: getPopUpOffset, popUpSize: popUpSize, onCancel: onCancel);
  static void get hide => _instance._hide();

  void _show({required BuildContext buildContext, required GlobalKey rootWidgetKey, required List<SquarePopUpItem> squarePopUpItems, GetPopUpOffsetCallback? getPopUpOffset, Size? popUpSize, VoidCallback? onCancel}) async {
    this.squarePopUpItems = squarePopUpItems;
    this.rootWidgetKey = rootWidgetKey;
    this.getPopUpOffset = getPopUpOffset;
    this.popUpSize = popUpSize ?? Size(160, 50);
    this.onCancel = onCancel;

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
  State<SquarePopUpMenu> createState() => _SquarePopUpMenuState();
}

class _SquarePopUpMenuState extends State<SquarePopUpMenu> with SingleTickerProviderStateMixin {
  RenderBox? renderBox;
  Offset? startOffset;
  Size? bound;
  late Widget internalWidget;
  final double circularValue = 13.0;
  late final Radius radius = Radius.circular(circularValue);
  late AnimationController animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200))..forward();
  late CurvedAnimation curvedAnim = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
  bool isSlideUp = false;
  double animOffset = 10;


  BorderRadius? getRadius(int index) {
    if(index == 0) {
      if(widget.squarePopUpItems.length == 1) {
        return BorderRadius.circular(circularValue);
      }
      return BorderRadius.only(topLeft: radius, topRight: radius);
    } else if(index == widget.squarePopUpItems.length - 1) {
      return BorderRadius.only(bottomLeft: radius, bottomRight: radius);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.rootWidgetKey != null) {
      renderBox = widget.rootWidgetKey.currentContext?.findRenderObject() as RenderBox?;
      if(renderBox != null) {
        startOffset = renderBox!.localToGlobal(Offset.zero);
        bound = renderBox!.size;
      }

      GetPopUpOffsetCallbackResponse? response = widget.getPopUpOffset?.call(startOffset!, bound!,
                  Size(widget.popUpSize.width, widget.popUpSize.height * widget.squarePopUpItems.length + 1 * (widget.squarePopUpItems.length - 1)));
      startOffset = response?.startOffset ?? startOffset;
      isSlideUp = response?.isSlideUp ?? false;
      if(isSlideUp) {
        animOffset *= -1;
      }
    }

    if(mounted)
      animationController.addStatusListener((status) {
        if(status == AnimationStatus.dismissed) {
          widget.onCancel?.call();
          widget._hide();
        }
      });

    internalWidget = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(circularValue),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(1.4, 2.4),
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1.3,
              blurRadius: 3.7,
            )
          ]
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          // direction: Axis.vertical,
          children: List.generate(widget.squarePopUpItems.length * 2 - 1,
                  (index) {
                if(index % 2 == 1) {
                  return Container(
                    width: widget.popUpSize.width,
                    height: 1,
                    color: CustomColor.paleGrey,
                  );
                }
                int idx = (index ~/ 2);
                final item = widget.squarePopUpItems[idx];
                return InkWell(
                  borderRadius: getRadius(idx),
                  onTap: () {
                    hide();

                    item.onTap();
                    // widget._hide();

                    // Navigator.pop(context);
                  },
                  child: Container(
                    width: widget.popUpSize.width,
                    height: widget.popUpSize.height,
                    padding: EdgeInsets.symmetric(
                        horizontal: Zeplin.size(15, isPcSize: true),
                        vertical: Zeplin.size(14, isPcSize: true)),
                    // color: Colors.white,
                    child: item.nameWidget ?? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(item.assetPath, width: Zeplin.size(18, isPcSize: true),),
                        SizedBox(width: Zeplin.size(16)),
                        Text(item.name, style: TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }


  void hide() {
    animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if(renderBox == null || startOffset == null || bound == null) return Container();

    return Stack(
      children: [
        GestureDetector(
          onPanStart: (evt) {
            hide();
            // widget._hide();
          },
          onTap: () {
            hide();
            // widget._hide();
          },
          child: Container(
            color: Colors.white.withOpacity(0),
          ),
        ),
        Positioned(
            left: startOffset!.dx,
            top: startOffset!.dy,
            child: AnimatedBuilder(
                animation: animationController,
                child:  internalWidget,
                builder: (context, child) {
                  return Transform.translate(offset: Offset(0, -animOffset + curvedAnim.value * animOffset),
                    child: Opacity(
                      opacity: min(1, curvedAnim.value * 1.5),
                      child: child,
                    ),);
                })
        )
      ],
    );
  }

}