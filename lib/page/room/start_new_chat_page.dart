import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/contacts/contacts_list.dart';
import 'package:square_web/widget/contacts/search_contact.dart';

class StartNewChatPage extends StatefulWidget with HomeWidget {
  final Function? showPage;
  final int pageIndex;
  StartNewChatPage({Key? key, this.showPage, required this.pageIndex}) : super(key: key);

  @override
  _StartNewChatPageState createState() => _StartNewChatPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  String pageName() => "StartNewChatPage";

  @override
  bool get isInternalImplement => true;
}

class _StartNewChatPageState extends State<StartNewChatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Zeplin.size(120)),
         /* TabBar(
            overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              return Colors.transparent;
            }),
            splashFactory: NoSplash.splashFactory,
            onTap: (index) {
              selectedIndex = index;
              setState(() {});
            },
            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(44))
            indicatorColor: Colors.black,
            indicatorWeight: Zeplin.size(2, isPcSize: true),
            controller: _tabController,
            tabs: [
              Container(
                padding: EdgeInsets.only(bottom: Zeplin.size(17)),
                height: Zeplin.size(80),
                alignment: Alignment.bottomCenter,
                child: Text(L10n.chat_open_02_01_search_user, style: TextStyle(color: selectedIndex == 0 ? Colors.black : CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30))),
              ),
              Container(
                padding: EdgeInsets.only(bottom: Zeplin.size(17)),
                height: Zeplin.size(80),
                alignment: Alignment.bottomCenter,
                child: Text(L10n.chat_open_02_02_contacts, style: TextStyle(color:selectedIndex == 1 ? Colors.black : CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30))),
              ),
            ]
          ),*/
          Expanded(
            child: ContactsList(),
          ),
        ],
      )
    );
  }
}
