import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/text_editing_default.dart';

class EditProfileTextFormField extends StatelessWidget {
  final TextEditingDefault textEditingDefault;
  final int maxLength;
  final int? minLine;
  final int maxLines;
  final String? hintText;
  final FocusNode focusNode;
  final bool isValid;
  const EditProfileTextFormField({Key? key, required this.textEditingDefault, required this.maxLength, required this.maxLines, required this.hintText, required this.focusNode, this.minLine, this.isValid = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: CustomColor.paleGrey,
            borderRadius: BorderRadius.circular(15),
            border:  Border.all(color: focusNode.hasFocus ? CustomColor.focusGrey : CustomColor.paleGrey, width: Zeplin.size(2)),
          ),
          child: TextFormField(
            focusNode: focusNode,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            controller: textEditingDefault.controller,
            style: chatTextFieldStyle,
            maxLength: maxLength,
            autocorrect: false,
            onChanged: textEditingDefault.onChanged,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)),
              hintText: hintText,
              contentPadding: EdgeInsets.only(left: Zeplin.size(29), right: Zeplin.size(30), top: Zeplin.size(30), bottom: Zeplin.size(60)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              counter: null,
              counterText: "",
            ),
            minLines: minLine ?? (this.maxLength-1),
            maxLines: maxLines,
            keyboardType: TextInputType.text,
          ),
        ),
        Positioned(
          bottom: Zeplin.size(27),
          right: Zeplin.size(20),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: "${textEditingDefault.controller.text.length}", style: TextStyle(color: isValid ? CustomColor.paleGreyDarkL : CustomColor.red, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
                TextSpan(text: " / $maxLength", style: TextStyle(color: CustomColor.paleGreyDarkL, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ),
      ],
    );
  }
}
