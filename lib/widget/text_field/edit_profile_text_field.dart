import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/text_editing_default.dart';

class EditProfileTextField extends StatelessWidget {
  final TextEditingDefault textEditingDefault;
  final int maxLength;
  final String hintText;
  final FocusNode focusNode;
  const EditProfileTextField({Key? key, required this.textEditingDefault, required this.maxLength, required this.hintText, required this.focusNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Stack(
      children: [
        Container(
          height: Zeplin.size(84),
          decoration: BoxDecoration(
            color: CustomColor.paleGrey,
            borderRadius: BorderRadius.circular(15),
            border:  Border.all(color: focusNode.hasFocus ? CustomColor.textFieldBorderGrey : CustomColor.paleGrey, width: Zeplin.size(2)),
          ),
          child: TextField(
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            focusNode: focusNode,
            controller: textEditingDefault.controller,
            style: chatTextFieldStyle,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onChanged: textEditingDefault.onChanged,
            onEditingComplete: () {},
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
              contentPadding: EdgeInsets.only(left: Zeplin.size(29), right: Zeplin.size(120), bottom: Zeplin.size(15)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              counter: null,
              counterText: ""
            ),
          ),
        ),
        Positioned(
          bottom: Zeplin.size(27),
          right: Zeplin.size(20),
          child: Text("${textEditingDefault.controller.text.length}/$maxLength", style: TextStyle(letterSpacing: 1.2, color: CustomColor.paleGreyDarkL, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}
