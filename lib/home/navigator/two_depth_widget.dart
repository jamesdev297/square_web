import 'package:flutter/material.dart';


class TwoDepthWidget extends StatefulWidget {
  const TwoDepthWidget({
    Key? key,
    this.transitionController,
    this.curvedAnimation,
    required this.child,
  }) : super(key: key);

  final AnimationController? transitionController;
  final CurvedAnimation? curvedAnimation;
  final Widget child;

  @override
  State<TwoDepthWidget> createState() => _TwoDepthWidgetState();
}

class _TwoDepthWidgetState extends State<TwoDepthWidget> {

  @override
  Widget build(BuildContext context) {
    if(widget.transitionController != null && widget.curvedAnimation != null) {
      return AnimatedBuilder(animation: widget.transitionController!, builder: (context, child) {
        return Positioned(
            left: 50 - 50 * widget.curvedAnimation!.value,
            child: Opacity(
                opacity: widget.curvedAnimation!.value,
                child: child)
        );
      }, child : widget.child,);
    } else {
      return widget.child;
    }
  }
}
