import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/profile_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/profile/edit_profile_image.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/text_field/edit_profile_text_field.dart';
import 'package:square_web/widget/text_field/edit_profile_text_form_field.dart';

class EditProfilePage extends StatefulWidget with HomeWidget {
  final Function? showEditPage;

  EditProfilePage({Key? key, this.showEditPage}) : super(key: key);

  @override
  String pageName() => "EditProfilePage";

  @override
  MenuPack get getMenuPack => MenuPack(
    centerMenu: Text(L10n.my_01_07_edit_profile, style: centerTitleTextStyle),
  );

  @override
  _EditProfilePageState createState() => _EditProfilePageState();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  // @override
  // bool get dimmedBackground => true;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingDefault _nameTextEditDefault = TextEditingDefault();
  TextEditingDefault _statusMessageTextEditDefault = TextEditingDefault();
  TextStyle _titleTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26));
  late ContactModel contactModel;
  bool isDuplicatedNickname = false;
  Uint8List? tempImageData;
  FocusNode nameFocusNode = FocusNode();
  FocusNode statusFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    contactModel = ContactModel(playerId: MeModel().playerId!, profileImgUrl: MeModel().contact!.profileImgUrl,
      profileImgNftId: MeModel().contact!.profileImgNftId, nickname: MeModel().contact!.nickname, statusMessage: MeModel().contact!.statusMessage);

    initTextEditDefault(_nameTextEditDefault, "name", contactModel.nickname ?? "");
    initTextEditDefault(_statusMessageTextEditDefault, "statusMessage", contactModel.statusMessage ?? "");


    nameFocusNode.addListener(() {
      setState(() {});
    });

    statusFocusNode.addListener(() {
      setState(() {});
    });

  }

  void initTextEditDefault(TextEditingDefault textEditingDefault, String name, String value) {
    textEditingDefault.init(name, this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        isDuplicatedNickname = false;
        textEditingDefault.resultText = text;
      },
    );
    textEditingDefault.controller.text = value;
    textEditingDefault.controller.selection = TextSelection.fromPosition(TextPosition(offset: textEditingDefault.controller.text.characters.length));
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isChanged() {
    ContactModel me = MeModel().contact!;

    return (me.nickname ?? "") != _nameTextEditDefault.controller.text || (me.statusMessage ?? "") != _statusMessageTextEditDefault.controller.text || contactModel.profileImgNftId != me.profileImgNftId
      || me.profileImgUrl != contactModel.profileImgUrl || tempImageData != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: Zeplin.size(34), horizontal: Zeplin.size(25)),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: cancelFunc,
                      child: Icon46(Assets.img.ico_46_arrow_bk),
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onPressed,
                      child: Center(child: Text(L10n.common_63_save, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: CustomColor.azureBlue)))),
                  )
                ]
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Center(child: EditProfileImage(contactModel: contactModel, tempImageData: tempImageData, tempNftId: contactModel.profileImgNftId, successFunc: (value) async {
                    if(value == null) {
                      FullScreenSpinner.hide();
                      return;
                    }

                    if(value == false) {
                      tempImageData = null;
                      contactModel.profileImgNftId = null;
                    } else {
                      tempImageData = value['bytes'];
                      contactModel.profileImgNftId = value['nftId'];
                    }
                    FullScreenSpinner.hide();
                    setState(() {});
                  })),
                  SizedBox(height: Zeplin.size(60)),
                  FocusTraversalGroup(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: Row(
                            children: [
                              Text(L10n.profile_04_04_name, style: _titleTextStyle),
                              Spacer(),
                              if(isDuplicatedNickname)
                                Text(L10n.my_02_01_exist_name, style: TextStyle(color: CustomColor.red, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                        SizedBox(height: Zeplin.size(20)),
                        FocusTraversalOrder(
                          order: NumericFocusOrder(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                            child: EditProfileTextField(
                              textEditingDefault: _nameTextEditDefault,
                              maxLength: 20,
                              hintText: MeModel().contact!.smallerWallet,
                              focusNode: nameFocusNode,
                            ),
                          ),
                        ),
                        SizedBox(height: Zeplin.size(40)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: Row(
                            children: [
                              Text(L10n.my_01_09_status_message, style: _titleTextStyle)
                            ],
                          ),
                        ),
                        SizedBox(height: Zeplin.size(20)),
                        FocusTraversalOrder(
                          order: NumericFocusOrder(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                            child: EditProfileTextFormField(
                              textEditingDefault: _statusMessageTextEditDefault,
                              maxLength: 60,
                              minLine: 5,
                              maxLines: 6,
                              hintText: L10n.my_01_10_input_status_message,
                              focusNode: statusFocusNode
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),   
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPressed() async {
    String? profileImgUrl = contactModel.profileImgUrl;
    if(tempImageData != null) {
      profileImgUrl = await ProfileManager().uploadThumbnail(tempImageData!);
    }

    int status = await ProfileManager().updateProfile(profileImgUrl: profileImgUrl, nftId: contactModel.profileImgNftId, nickname: _nameTextEditDefault.controller.text, statusMessage: _statusMessageTextEditDefault.controller.text);
    // if(status == 200) {
      HomeNavigator.pop();
      // return;
    // }

    if(status == 703) {
      isDuplicatedNickname = true;
      setState(() {});
    }
  }

  void leavePage() {
    contactModel = ContactModel(playerId: MeModel().playerId!, profileImgUrl: MeModel().contact!.profileImgUrl,
        profileImgNftId: MeModel().contact!.profileImgNftId, nickname: MeModel().contact!.nickname, statusMessage: MeModel().contact!.statusMessage);

    initTextEditDefault(_nameTextEditDefault, "name", contactModel.nickname ?? "");
    initTextEditDefault(_statusMessageTextEditDefault, "statusMessage", contactModel.statusMessage ?? "");

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void cancelFunc() {

    if(!isChanged()) {
      leavePage();
      widget.showEditPage?.call(0);
      // HomeNavigator.pop();
      return;
    }

    SquareDefaultDialog.showSquareDialog(
      title: L10n.popup_02_edit_profile_title,
      content: Text(L10n.popup_03_edit_profile_content),
      button1Text: L10n.common_03_cancel,
      button2Text: L10n.common_02_confirm,
      button2Action: () {
        SquareDefaultDialog.closeDialog().call();
        leavePage();
        widget.showEditPage?.call(0);
        // HomeNavigator.pop();
      }
    );
  }
}
