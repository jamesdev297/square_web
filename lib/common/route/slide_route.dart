
import 'package:flutter/cupertino.dart';

enum SlideRouteDirection { left, right, up, down, none }
class SlideRoute<T> extends CupertinoPageRoute<T> {
  // final Widget page;
  // final RouteSettings settings;
  SlideRouteDirection direction;
  static const Map<SlideRouteDirection, Offset> _SlideRouteDirectionOffset = {
    SlideRouteDirection.left: Offset(1, 0),
    SlideRouteDirection.right: Offset(-1, 0),
    SlideRouteDirection.up: Offset(0, 1),
    SlideRouteDirection.down: Offset(0, -1),
    SlideRouteDirection.none: Offset(0, 0),
  };

  @override
  bool get barrierDismissible => false;

  SlideRoute({required WidgetBuilder builder, RouteSettings? settings, SlideRouteDirection? direction})
      : this.direction = direction ?? SlideRouteDirection.left,
        super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (direction == SlideRouteDirection.left || direction == SlideRouteDirection.right)
      return super.buildTransitions(context, animation, secondaryAnimation, child);

    return SlideTransition(
        position: Tween<Offset>(
          begin: _SlideRouteDirectionOffset[direction],
          end: Offset.zero,
        ).animate(animation),
        child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: _SlideRouteDirectionOffset[direction],
            ).animate(secondaryAnimation),
            child: child));
  }
}