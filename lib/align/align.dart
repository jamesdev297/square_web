import 'package:flutter/widgets.dart';

class ColumnBottom extends StatelessWidget {
  final List<Widget> children = <Widget>[];
  ColumnBottom({Widget? child, List<Widget>? children}) {
    if (child != null) {
      this.children.add(child);
    }
    if (children != null) {
      this.children.addAll(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }
}


class ColumnLeft extends StatelessWidget {
  final List<Widget> children = <Widget>[];
  ColumnLeft({Widget? child, List<Widget>? children}) {
    if (child != null) {
      this.children.add(child);
    }
    if (children != null) {
      this.children.addAll(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class ColumnRight extends StatelessWidget {
  final List<Widget> children = <Widget>[];
  ColumnRight({Widget? child, List<Widget>? children}) {
    if (child != null) {
      this.children.add(child);
    }
    if (children != null) {
      this.children.addAll(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}

