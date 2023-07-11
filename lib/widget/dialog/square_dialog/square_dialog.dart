import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/dialog/square_dialog_template.dart';

part 'square_default_dialog_widget.dart';

abstract class SquareDialogWidget extends StatelessWidget with SquareDialog {
  @override
  Widget build(BuildContext context) {
    return SquareDialogTemplate.dialogContent(
      title: title,
      description: description,
      button1Text: button1Text,
      content: content,
      button2Text: button2Text,
      button2Action: button2Action,
      button1Action: button1Action,
      extraDescription: extraDescription,
      showShadow: showShadow,
    );
  }
}

mixin SquareDialog {
  String? title;
  String? description;
  String? extraDescription;
  Widget? content;
  String? button1Text;
  VoidCallback button1Action = SquareDefaultDialog.closeDialog();
  String? button2Text;
  VoidCallback? button2Action;
  bool? showShadow = true;
}
