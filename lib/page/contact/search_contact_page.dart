import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/contacts/search_contact.dart';

class SearchContactPage extends StatefulWidget with HomeWidget {
  final int pageIndex;
  final Function? showPage;

  SearchContactPage({Key? key, this.showPage, required this.pageIndex}) : super(key: key);

  @override
  _SearchContactPageState createState() => _SearchContactPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  bool get isInternalImplement => true;

  @override
  String pageName() => "SearchContactPage";
}

class _SearchContactPageState extends State<SearchContactPage> {


  @override
  void initState() {
    super.initState();
    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.showPage?.call(0);
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Zeplin.size(75)),
            Expanded(child: SearchContact(pageIndex: widget.pageIndex))
          ],
        ),
      )
    );
  }
}
