
import 'package:flutter/widgets.dart';

class BoolContainer extends StatelessWidget {
  final bool? showContainer;
  final Widget? child;
  final Widget? container;
  BoolContainer({this.showContainer = false, this.child, this.container});

  @override
  Widget build(BuildContext context) {
    if (showContainer!) {
      if(this.container == null)
        return Container();
      return this.container!;
    }
    return child!;
  }
}
