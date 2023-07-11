import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/custom_dropdown/custom_divider.dart';

class FeedbackTextFormField extends StatelessWidget {
  final TextEditingDefault summarizeEditingDefault;
  final TextEditingDefault descriptionEditingDefault;
  final FocusNode summarizeFocusNode;
  final FocusNode descriptionFocusNode;
  final bool isValid;

  const FeedbackTextFormField({Key? key, required this.summarizeEditingDefault, required this.descriptionEditingDefault, required this.summarizeFocusNode, required this.descriptionFocusNode, this.isValid = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: CustomColor.paleGrey,
            borderRadius: BorderRadius.circular(15),
            border:  Border.all(color: summarizeFocusNode.hasFocus || descriptionFocusNode.hasFocus ? CustomColor.textFieldBorderGrey : CustomColor.paleGrey, width: Zeplin.size(2)),
          ),
          child: Column(
            children: [
              TextField(
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                focusNode: summarizeFocusNode,
                controller: summarizeEditingDefault.controller,
                style: chatTextFieldStyle,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                onChanged: summarizeEditingDefault.onChanged,
                onEditingComplete: () {},
                inputFormatters:[
                  LengthLimitingTextInputFormatter(50),
                ],
                decoration: InputDecoration(
                  hintText: L10n.feedback_01_summarize_hint,
                  hintStyle: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
                  contentPadding: EdgeInsets.only(left: Zeplin.size(29), right: Zeplin.size(120)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counter: null,
                ),
              ),
              CustomDivider(padding: 0, thickness: 1),
              TextFormField(
                focusNode: descriptionFocusNode,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                controller: descriptionEditingDefault.controller,
                style: chatTextFieldStyle,
                inputFormatters:[
                  LengthLimitingTextInputFormatter(1000),
                ],
                autocorrect: false,
                onChanged: descriptionEditingDefault.onChanged,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)),
                  hintText: L10n.feedback_01_description_hint,
                  contentPadding: EdgeInsets.only(left: Zeplin.size(29), right: Zeplin.size(30), top: Zeplin.size(30), bottom: Zeplin.size(60)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counter: null,
                ),
                minLines: 7,
                maxLines: 7,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: Zeplin.size(27),
          right: Zeplin.size(20),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: "${descriptionEditingDefault.controller.text.length}", style: TextStyle(letterSpacing: 1.2, color: isValid ? CustomColor.paleGreyDarkL : CustomColor.red, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
                TextSpan(text: "/1000", style: TextStyle(letterSpacing: 1.2, color: CustomColor.paleGreyDarkL, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ),
        Positioned(
          top: Zeplin.size(27),
          right: Zeplin.size(20),
          child: Text("${summarizeEditingDefault.controller.text.length}/50", style: TextStyle(letterSpacing: 1.2, color: CustomColor.paleGreyDarkL, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}
