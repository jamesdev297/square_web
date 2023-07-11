import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/dialog/square_dialog_template.dart';
import 'package:timer_builder/timer_builder.dart';

class SquareResendLockDialog {
  static Set<UniqueDialogKey> uniqueDialogKeys = {};

  static void showSquareDialog(
      {required ValueNotifier<DateTime> lockEndTimeNotifier,
      String? title,
      Widget? content,
      String? description,
      String? button1Text,
      VoidCallback? button1Action,
      String? button2Text,
      VoidCallback? button2Action,
      String button2DisabledTextBuilder(Duration remain)?,
      bool isHorizonButton = true,
      bool barrierDismissible = true,
      Color? barrierColor,
      bool showBarrierColor = true,
      bool showShadow = true,
      String? extraDescription,
      double? width,
      EdgeInsets? padding,
      bool? isButton1TextWhite,
      UniqueDialogKey? uniqueDialogKey,
      Widget? toastMessage}) {
    showDialog(
        barrierDismissible: barrierDismissible,
        barrierColor: showBarrierColor ? (barrierColor ?? Colors.black.withOpacity(0.4)) : null,
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) => SquareDefaultDialog(
              title: title,
              description: description,
              content: content,
              customButtonPack: SquareDialogTemplate.getButtonPack(isHorizonButton,
                button1Text: button1Text,
                button1Action: button1Action,
                customButton: Container(
                  padding: EdgeInsets.symmetric(vertical: Zeplin.size(20)),
                  child: ValueListenableBuilder(
                      valueListenable: lockEndTimeNotifier,
                      builder: (context, DateTime value, child) {
                        if (value.isBefore(DateTime.now())) {
                          return GestureDetector(
                            onTap: button2Action,
                            child: Text(button2Text!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: Colors.black, fontSize: Zeplin.size(28))),
                          );
                        }
                        return TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
                          DateTime now = DateTime.now();
                          if (value.isBefore(now)) {
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              lockEndTimeNotifier.value = lockEndTimeNotifier.value.subtract(Duration(seconds: 10));
                            });
                          }
                          Duration remain = lockEndTimeNotifier.value.difference(now);
                          if(button2DisabledTextBuilder != null)
                            return Text(button2DisabledTextBuilder(remain),
                              style: TextStyle(color: CustomColor.blueyGrey));

                          return Container();
                        });
                      }),
                ),
              ),
              context: context,
              showShadow: showShadow,
              extraDescription: extraDescription,
              width: width,
              padding: padding,
            ));
  }

  static VoidCallback closeDialog({UniqueDialogKey? uniqueDialogKey}) => () {
        LogWidget.info("click!!!");
        Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
        if (uniqueDialogKey != null) uniqueDialogKeys.remove(uniqueDialogKey);
      };
}
