import 'package:flutter/widgets.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

class ScrollDefault {
  late ScrollController _controller;

  ScrollController get controller => _controller;

  double _initialLoadedSize = 0;
  int _lastLoadTime = 0;
  double initialScrollOffset = 0;

  VoidCallback? onLoadMore;
  VoidCallback? onTop;
  VoidCallback? onBottom;

  Function? onScroll;

  void init({VoidCallback? onLoadMore, VoidCallback? onTop, VoidCallback? onBottom, Function? onScroll, double initialScrollOffset = 0}) {
    _controller = ScrollController(initialScrollOffset: initialScrollOffset);
    _controller.addListener(_scrollListener);
    this.onLoadMore = onLoadMore;
    this.onTop = onTop;
    this.onBottom = onBottom;
    this.onScroll = onScroll;
  }

  void dispose() {
    _controller.dispose();
  }

  void _scrollListener() async {
    double _listGap = _controller.position.maxScrollExtent - _controller.offset;
    double topPer = _controller.offset / _controller.position.maxScrollExtent;

    onScroll?.call();

    if (_initialLoadedSize == 0) {
      _initialLoadedSize = _listGap;
    }
    //LogWidget.debug("_listPixelSize : ${_listGap}, ${_initialLoadedSize/3}, ${_initialLoadedSize}");
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {

      LogWidget.debug("reach the bottom");
      onBottom?.call();
    } else if (_listGap < _initialLoadedSize/3) {
      if (_lastLoadTime + 50 > DateTime.now().millisecondsSinceEpoch) {
        return;
      }

      LogWidget.debug("onLoadMore");
      onLoadMore?.call();

      _lastLoadTime = DateTime.now().millisecondsSinceEpoch;
    }

    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {

      LogWidget.debug("reach the top");
      onTop?.call();
    }
  }
}
