import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/widget/text_field/search_text_field.dart';

class SliverListWithSearchBar extends StatefulWidget {
  final List<Widget> slivers;
  final EdgeInsets? sliverPadding;
  final double headerSize;
  final double searchBarSize;
  final String? searchBarHintText;
  final ValueChanged<String>? searchAction;
  final VoidCallback? onTapSearchAction;
  final TextEditingDefault? textEditDefault;
  final VoidCallback? onScroll;
  final FocusNode? focusNode;
  final VoidCallback? onLoadMore;
  final VoidCallback? onBottom;

  SliverListWithSearchBar(
      {Key? key,
      required this.slivers,
      required this.headerSize,
      required this.searchBarSize,
      this.searchBarHintText,
      this.searchAction,
      this.onTapSearchAction,
      this.textEditDefault,
      this.onScroll,
      this.onLoadMore,
      this.onBottom,
      this.focusNode,
      this.sliverPadding})
      : super(key: key);

  @override
  _SliverListWithSearchBarState createState() =>
      _SliverListWithSearchBarState();
}

class _SliverListWithSearchBarState extends State<SliverListWithSearchBar> {
  late ScrollDefault _scrollDefault = ScrollDefault();

  @override
  void initState() {
    super.initState();
    _scrollDefault.init(initialScrollOffset: widget.headerSize, onScroll: widget.onScroll, onLoadMore: widget.onLoadMore, onBottom: widget.onBottom);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.depth == 1) //easing에 의한 노티 제거
          return false;

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (notification.metrics.pixels <= widget.headerSize / 3 &&
              notification.metrics.pixels > 0.01) {
            _scrollDefault.controller.animateTo(0,
                duration: Duration(milliseconds: 100), curve: Curves.ease);
          } else if (notification.metrics.pixels > widget.headerSize / 3 &&
              notification.metrics.pixels < widget.headerSize) {
            _scrollDefault.controller.animateTo(widget.headerSize,
                duration: Duration(milliseconds: 100), curve: Curves.ease);
          }
        });
        return true;
      },
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              primary: false,
              toolbarHeight: widget.searchBarSize,
              expandedHeight: widget.headerSize,
              centerTitle: true,
              title: Column(
                children: [
                  SizedBox(
                    height: Zeplin.size(100),
                    child: Padding(
                      padding: EdgeInsets.only(left: Zeplin.size(34), right: Zeplin.size(34)),
                      child: SearchTextField(
                        focusNode: widget.focusNode,
                        textEditingDefault:  widget.textEditDefault,
                        onTap: widget.onTapSearchAction,
                        hintText: widget.searchBarHintText,
                        hasSuffixIcon: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Padding(
          padding: widget.sliverPadding ?? EdgeInsets.zero,
          child: Builder(builder: (BuildContext context) {
            List<Widget> _slivers = [
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context))
            ]..addAll(widget.slivers);
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollDefault.controller,
              slivers: _slivers);
          }),
        ),
      ),
    );
  }
}
