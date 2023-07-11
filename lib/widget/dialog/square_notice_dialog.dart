import 'dart:math';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/main.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/button.dart';

class SquareNoticeDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget? contentWidget;
  final String button1Text;
  final VoidCallback button1Action;

  SquareNoticeDialog({required this.title,
    required this.content,
    this.contentWidget,
    required this.button1Text,
    required this.button1Action,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      elevation: 0.0,
      insetPadding: EdgeInsets.only(top: Zeplin.size(40)),
      child: dialogContent(
        title: title,
        content: content,
        contentWidget: contentWidget,
        button1Text: button1Text,
        button1Action: button1Action,
      ),
    );
  }

  static void showSquareDialog({
    required String title,
    required String content,
    Widget? contentWidget,
    required String button1Text,
    required VoidCallback? button1Action,
    }) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      context: navigatorKey.currentState!.overlay!.context,
      builder: (context) =>
        SquareNoticeDialog(
          title: title,
          content: content,
          contentWidget: contentWidget,
          button1Text: button1Text,
          button1Action: button1Action ?? SquareNoticeDialog.closeDialog,
        ));
  }


  static VoidCallback get closeDialog =>
          () {
        Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
      };

  Widget dialogContent(
      {required String title,
        required String content,
        Widget? contentWidget,
        required String button1Text,
        required VoidCallback button1Action,
      }) {
    return Container(
      width: min(500, max(300, DeviceUtil.screenWidth - 60)),
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: Zeplin.size(22), right: Zeplin.size(22), top: Zeplin.size(22), bottom: Zeplin.size(10)),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: Zeplin.size(18)),
                      Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize:Zeplin.size(34), color: Colors.black)),
                      SizedBox(height: Zeplin.size(28)),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: SquareNoticeDialog.closeDialog,
                      child: Image.asset(Assets.img.ico_46_x_bk, width: Zeplin.size(46),)),
                )
              ],
            ),
          ),
          // Divider(height: 1, thickness: 1, color: CustomColor.veryLightGrey,),
          Padding(
            padding: EdgeInsets.only(left: Zeplin.size(30), right: contentWidget == null ? Zeplin.size(30) : 0, bottom: Zeplin.size(18)),
            child: Column(
              children: [
                // SizedBox(height: Zeplin.size(20)),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: Zeplin.size(367, isPcSize: true)
                  ),
                  child: ListView(
                    padding: contentWidget != null ? EdgeInsets.only(right: Zeplin.size(28)) : null,
                    shrinkWrap: true,
                    children: [
                      if(contentWidget != null)
                        contentWidget
                      else
                        Text(content, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.grey4))
                    ],
                  ),
                ),
                SizedBox(height: Zeplin.size(30)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: contentWidget != null ? EdgeInsets.only(right: Zeplin.size(28)) : null,
                          child: PebbleRectButton(
                            onPressed: button1Action,
                            child: Text(button1Text, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Zeplin.size(28))),
                            backgroundColor: CustomColor.azureBlue,
                            borderColor: CustomColor.azureBlue,
                          ), height: Zeplin.size(94)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
