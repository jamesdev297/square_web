import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';

class ContactPageTopMenu extends StatefulWidget {
  final ValueNotifier<ContactsFolder> selectedContactsFolder;
  final Function showPage;
  final int pageIndex;

  const ContactPageTopMenu({
    Key? key,
    required this.selectedContactsFolder,
    required this.showPage,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<ContactPageTopMenu> createState() => _ContactsPageTopMenuState();
}


class _ContactsPageTopMenuState extends State<ContactPageTopMenu> {
  bool isShown = false;
  GlobalKey globalKey = GlobalKey();
  late List<SquarePopUpItem> squarePopUpItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectedContactsFolder.addListener(() {
      setState(() {});
    });

    screenWidthNotifier.addListener(() {
      if (isShown) {
        isShown = false;
        SquarePopUpMenu.hide;
        setState(() {});
      }
    });
  }

  void onShowFunc(bool isShow) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isShown = isShow;
    });
  }
  

  void showToolTip() {

    onShowFunc(true);
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset startOffset, Size rootWidgetSize, Size popUpSize) {
      Offset offset = Offset(startOffset.dx, startOffset.dy +30);
      return GetPopUpOffsetCallbackResponse(offset);
    }, onCancel: () => onShowFunc(false));
  }

  void onSelected(ContactsFolder value) {
    widget.selectedContactsFolder.value = value;
    isShown = false;
    setState(() {});
  }

  Widget _buildSelectContacts() {

    squarePopUpItems = [
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_fre_bk,
          name: L10n.contacts_01_01_contacts,
          onTap: () => onSelected(ContactsFolder.contacts)),
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_block_bla,
          name: L10n.contacts_02_01_block_list,
          onTap: () => onSelected(ContactsFolder.blocked)),
    ];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: globalKey,
        onTap: showToolTip,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.selectedContactsFolder.value == ContactsFolder.contacts ? L10n.contacts_01_01_contacts : L10n.contacts_02_01_block_list, style: TextStyle(fontSize: Zeplin.size(34), color: CustomColor.darkGrey, fontWeight: FontWeight.w500)),
              SizedBox(width: Zeplin.size(10)),
              AnimatedRotation(
                turns: isShown ? 0.5 : 0,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInBack,
                child: Icon26(Assets.img.ico_h_26_ud_gy))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstMenu() {
    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: _buildSelectContacts()),
        Align(
          alignment: Alignment.topRight,
          child: Transform.translate(
            offset: Offset(0, 1),
            child: ValueListenableBuilder(
                valueListenable: widget.selectedContactsFolder,
                builder: (context, value, child) {
                  if(value == ContactsFolder.contacts) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          child: Image.asset(Assets.img.ico_36_plus_bla, width: Zeplin.size(36)),
                          onTap: () {
                            widget.showPage(1);
                          }
                      ),
                    );
                  }
                  return Container();
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondMenu() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                  },
                  child: Icon46(Assets.img.ico_46_arrow_bk)),
            )),
        Align(
            alignment: Alignment.topCenter,
            child: Text(L10n.contacts_05_01_add_new_contact,
                style: centerTitleTextStyle)),
      ],
    );
  }

  Widget _buildNoTransition() {
    return widget.pageIndex == 0 ? _buildFirstMenu() : _buildSecondMenu();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: Padding(
          padding: EdgeInsets.only(
              top: Zeplin.size(32),
              left: Zeplin.size(16),
              right: Zeplin.size(16)),
          child: MeModel().showTransition ? AnimatedCrossFade(
            duration: Duration(milliseconds: 100),
            crossFadeState: widget.pageIndex == 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _buildFirstMenu(),
            secondChild: _buildSecondMenu(),
          ) : _buildNoTransition()
      ),
    );
  }
}