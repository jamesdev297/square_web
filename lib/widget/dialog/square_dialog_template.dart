
import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/button.dart';

class SquareDialogTemplate {
  static Widget dialogContent(
      {String? title,
      String? description,
      String? extraDescription,
      Widget? content,
      String? button1Text,
      VoidCallback? button1Action,
      String? button2Text,
      VoidCallback? button2Action,
      Widget? customButtonPack,
      bool? showShadow,
      double? width,
      EdgeInsets? padding,
      bool? onlyTitle,
      }) {
    return Container(
      padding: padding ?? EdgeInsets.only(
          top: Zeplin.size(22, isPcSize: true),
          right: Zeplin.size(15, isPcSize: true),
          left: Zeplin.size(15, isPcSize: true),
          bottom: Zeplin.size(15, isPcSize: true)),
      constraints: width == null ? BoxConstraints(maxWidth: Zeplin.size(300, isPcSize: true)) : null,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if(showShadow == true)
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
            )
        ]
      ),
      child: Column(
        children: [
          if(title != null)
            Text(title,style: TextStyle(fontWeight: FontWeight.w500, fontSize:Zeplin.size(34), color: Colors.black)),
          if(title != null)
            SizedBox(height: Zeplin.size(13, isPcSize: onlyTitle == true ? false : true)),
          if(content != null)
            content,
          if(extraDescription == null && description != null)
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, color: CustomColor.taupeGray, fontSize: Zeplin.size(26))),
          if(extraDescription != null)
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  if(description != null)
                    TextSpan(text: description, style: TextStyle(fontWeight: FontWeight.w500, color: CustomColor.taupeGray, fontSize: Zeplin.size(26))),
                  TextSpan(text: extraDescription, style: TextStyle(color: CustomColor.azureBlue, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          if(button1Text != null || customButtonPack != null)
            SizedBox(height: Zeplin.size(27, isPcSize: onlyTitle == true ? false : true)),
          if(customButtonPack != null)
            customButtonPack,
          if(button1Text != null && customButtonPack == null)
            getButtonPack(true, button1Action: button1Action, button1Text: button1Text, button2Action: button2Action, button2Text: button2Text)
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  static Widget getButtonPack(bool horizontal, {String? button1Text, String? button2Text, VoidCallback? button1Action, VoidCallback? button2Action, Widget? customButton}) {
    var firstButtonColor = button2Text != null ? CustomColor.paleGrey : CustomColor.azureBlue;
    var firstButtonTextColor = button2Text != null ? Colors.black : Colors.white;

    if(horizontal) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            child: Container(
                child: PebbleRectButton(
                  borderColor: firstButtonColor,
                  onPressed: button1Action,
                  child: Text(button1Text!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: firstButtonTextColor, fontSize: Zeplin.size(28))),
                  backgroundColor: firstButtonColor,
                ),
                height: Zeplin.size(94))),
        if (button2Text != null)
          SizedBox(
            width: Zeplin.size(14),
          ),
        if (button2Text != null)
          Expanded(
              child: Container(
            child: PebbleRectButton(
              borderColor: CustomColor.azureBlue,
              onPressed: button2Action,
              child: Text(button2Text,
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
              backgroundColor: CustomColor.azureBlue,
            ),
            height: Zeplin.size(94),
          )),
        if (customButton != null)
          SizedBox(
            width: Zeplin.size(14),
          ),
        if (customButton != null) customButton
      ]);
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Container(
                    child: PebbleRectButton(
                      borderColor: firstButtonColor,
                      onPressed: button1Action,
                      child: Text(button1Text!,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: firstButtonTextColor, fontSize: Zeplin.size(28))),
                      backgroundColor: firstButtonColor,
                    ),
                    height: Zeplin.size(94))),
          ],
        ),
        if (button2Text != null)
          SizedBox(
            width: Zeplin.size(14),
          ),
        if (button2Text != null)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: Container(
                    child: PebbleRectButton(
                      borderColor: CustomColor.azureBlue,
                      onPressed: button2Action,
                      child: Text(button2Text,
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
                      backgroundColor: CustomColor.azureBlue,
                    ),
                    height: Zeplin.size(94),
                  )),
            ],
          ),
        if (customButton != null)
          SizedBox(
            width: Zeplin.size(14),
          ),
        if (customButton != null) Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton,
          ],
        )
      ]);
    }
  }
}
