import 'package:flutter/material.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/profile_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/text_field/edit_profile_text_field.dart';

class SquareEditNicknameDialog extends StatefulWidget {
  final ContactModel contactModel;
  final BuildContext context;
  final PlayerProfileBloc? playerProfileBloc;

  const SquareEditNicknameDialog({required this.contactModel, required this.context, this.playerProfileBloc});


  @override
  _SquareEditNicknameDialogState createState() => _SquareEditNicknameDialogState();
}

class _SquareEditNicknameDialogState extends State<SquareEditNicknameDialog> {

  TextEditingDefault textEditingDefault = TextEditingDefault();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    textEditingDefault.init("player nickname", this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        textEditingDefault.resultText = text;
      },
    );

    textEditingDefault.controller.text = widget.contactModel.targetNickname ?? "";
    textEditingDefault.controller.selection = TextSelection.fromPosition(TextPosition(offset: textEditingDefault.controller.text.characters.length));
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(60), vertical: Zeplin.size(46)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Zeplin.size(38), vertical: Zeplin.size(48)),
        constraints: BoxConstraints(maxWidth: Zeplin.size(600)),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]
        ),
        child: Column(
          children: [
            Text(L10n.profile_07_01_set_nickname, style: TextStyle(fontWeight: FontWeight.w500, fontSize:Zeplin.size(34), color: Colors.black)),
            SizedBox(height: Zeplin.size(20)),
            Column(
              children: [
                Text(L10n.profile_07_02_set_nickname_content, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                SizedBox(height: Zeplin.size(20)),
                EditProfileTextField(textEditingDefault: textEditingDefault, maxLength: 20, hintText: "", focusNode: focusNode),
                SizedBox(height: Zeplin.size(10)),
                Row(
                  children: [
                    SizedBox(width: Zeplin.size(30)),
                    Text(L10n.profile_07_03_target_nickname(widget.contactModel.nickname ?? widget.contactModel.smallerWallet), style: TextStyle(color: CustomColor.outlineGrey, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
            SizedBox(height: Zeplin.size(50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Expanded(
                  child: Container(
                    child: PebbleRectButton(
                      borderColor: CustomColor.paleGrey,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(L10n.common_03_cancel, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: Zeplin.size(28))),
                      backgroundColor: CustomColor.paleGrey,
                    ), height: Zeplin.size(94)
                  )
                ),
                SizedBox(width: Zeplin.size(14)),
                Expanded(
                  child: Container(
                    child: PebbleRectButton(
                      borderColor: CustomColor.azureBlue,
                      onPressed: () async {
                        String? nickname = textEditingDefault.controller.text.trim();
                        if(await ProfileManager().setTargetNickname(widget.contactModel, nickname, widget.playerProfileBloc)) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(L10n.common_02_confirm, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
                      backgroundColor: CustomColor.azureBlue,
                    ),
                    height: Zeplin.size(94),
                  )
                )
              ]
            )
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}
