import 'package:flutter/cupertino.dart';
import 'dart:js' as js;
import 'package:square_web/constants/constants.dart';

class CopyUtil {
  static Future<void> copyText(String text, VoidCallback? onSuccess) async {
    bool result = js.context.callMethod(copyTextKey, [text]);
    if(result) {
      onSuccess?.call();
    }
  }
}