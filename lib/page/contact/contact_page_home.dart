import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/contact/contacts_page.dart';
import 'package:square_web/page/contact/contacts_page_top_menu.dart';
import 'package:square_web/page/contact/search_contact_page.dart';

class ContactPageHome extends StatefulWidget with HomeWidget {
  @override
  TabCode get targetNavigator => TabCode.contacts;

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "ContactPageHome";

  @override
  State<ContactPageHome> createState() => _ContactPageHomeState();
}

class _ContactPageHomeState extends State<ContactPageHome> {
  PreloadPageController pageController = PreloadPageController();
  ValueNotifier<ContactsFolder> selectedContactsFolder = ValueNotifier(ContactsFolder.contacts);
  int pageIndex = 0;

  late HomeWidget searchContactPage;
  late HomeWidget contactPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contactPage = ContactsPage(selectedContactsFolder: selectedContactsFolder, showPage: showPage);
    searchContactPage = SearchContactPage(pageIndex : pageIndex, showPage: showPage);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    selectedContactsFolder.dispose();
  }

  void showPage(int index) {
    pageIndex = index;
    if(MeModel().showTransition) {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut);
    }
    searchContactPage = SearchContactPage(pageIndex : pageIndex, showPage: showPage);
    if(index == 1) {
      HomeNavigator.pushHomeWidget(searchContactPage);
    }
    setState(() {

    });
  }

  Widget _buildNoTransition() {
    return Stack(
      children: [
        pageIndex == 0 ? contactPage : searchContactPage,
        Align(
          alignment: Alignment.topCenter,
          child: ContactPageTopMenu(
            pageIndex: pageIndex,
            showPage: showPage,
            selectedContactsFolder: selectedContactsFolder,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MeModel().showTransition ? Stack(
        children: [
          PreloadPageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              contactPage,
              searchContactPage,
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ContactPageTopMenu(
              pageIndex: pageIndex,
              showPage: showPage,
              selectedContactsFolder: selectedContactsFolder,
            ),
          )
        ],
      ) : _buildNoTransition(),
    );
  }
}