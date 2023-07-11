import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/page/square/public_square_list_page.dart';
import 'package:square_web/page/square/secret_square_list_page.dart';

class SquareListPage extends StatefulWidget with HomeWidget {
  final ValueNotifier<SquareFolder> selectedSquareFolder;
  SquareListPage({required this.selectedSquareFolder});

  @override
  TabCode get targetNavigator => TabCode.square;

  @override
  void resetWidget() {}

  @override
  State createState() => SquareListPageState();

  @override
  MenuPack get getMenuPack => MenuPack(padding: EdgeInsets.only(top: Zeplin.size(20)));

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "SquareListPage";
}

class SquareListPageState extends State<SquareListPage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Zeplin.size(83)),
            Expanded(
              child: ValueListenableBuilder<SquareFolder>(
                valueListenable: widget.selectedSquareFolder,
                builder: (context, value, child) {
                  return value == SquareFolder.public ? PublicSquareListPage() : SecretSquareListPage();
                }),
            )
          ],
        ),
      ),
    );
  }
}
