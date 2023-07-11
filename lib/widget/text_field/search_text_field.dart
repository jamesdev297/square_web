import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/widget/button.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingDefault? textEditingDefault;
  final String? hintText;
  final FocusNode? focusNode;
  final bool autoFocus;
  final VoidCallback? onTap;
  final Color? fontColor;
  final TextAlign? textAlign;
  final Widget? suffixIcon;
  final bool hasSuffixIcon;
  final int? maxLength;
  final Function(String)? onSubmitted;

  SearchTextField({this.textEditingDefault, this.hintText, this.focusNode, this.hasSuffixIcon = false, this.suffixIcon,
    this.autoFocus = false, this.onTap, this.fontColor, this.textAlign = TextAlign.start, this.onSubmitted, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Zeplin.size(42, isPcSize: true),
      child: TextField(
        obscureText: false,
        enableInteractiveSelection: true,
        toolbarOptions: ToolbarOptions(
          copy: true,
          cut: true,
          paste: true,
          selectAll: true,
        ),
        onSubmitted: onSubmitted,
        onTap: onTap,
        controller: textEditingDefault!.controller,
        onChanged: textEditingDefault!.onChanged,
        autofocus: autoFocus,
        focusNode: focusNode,
        inputFormatters:[
          LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.only(left: Zeplin.size(32), right: Zeplin.size(32), top: 10),
          border:  OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: CustomColor.paleGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: CustomColor.focusGrey, width: Zeplin.size(2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: CustomColor.paleGrey)),
          hintStyle: TextStyle(fontSize: Zeplin.size(26), color: CustomColor.paleGreyDarkL, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: CustomColor.paleGrey,
          hoverColor: CustomColor.paleGrey,
          suffixIcon: hasSuffixIcon == true && (textEditingDefault!.isComposing || textEditingDefault!.controller.text.characters.length > 0) ?
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: EdgeInsets.only(right: Zeplin.size(20)),
                child: GestureDetector(
                  child: Icon28(Assets.img.ico_26_close_gy),
                  onTap: () {
                    textEditingDefault!.resetOnSubmit("");
                    textEditingDefault!.onChanged("");
                  },
                ),
              ),
            ) : SizedBox(width: Zeplin.size(48)),
          suffixIconConstraints: BoxConstraints(maxHeight: Zeplin.size(60)),
        ),
        textAlign: textAlign!,
        style: chatTextFieldStyle,
      ),
    );
  }

}
