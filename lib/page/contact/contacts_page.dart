import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/contacts/blocked_contacts_list.dart';
import 'package:square_web/widget/contacts/contacts_list.dart';

class ContactsPage extends StatefulWidget with HomeWidget {
  final ValueNotifier<ContactsFolder> selectedContactsFolder;
  final Function showPage;

  ContactsPage({
    Key? key,
    required this.selectedContactsFolder,
    required this.showPage,
  }) : super(key: key);

  @override
  State createState() => ContactsPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  String pageName() => "ContactsPage";

}

class ContactsPageState extends State<ContactsPage> {

  @override
  void initState() {
    super.initState();
    LogWidget.debug("Contacts Page INIT");
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
              child: ValueListenableBuilder<ContactsFolder>(
                valueListenable: widget.selectedContactsFolder,
                builder: (context, value, child) {
                  return value == ContactsFolder.contacts ? ContactsList(isContactsPage: true, showPage: widget.showPage)
                      : BlockedContactsList();
                }),
              )
          ],
        ),
      ),
    );
  }
}
