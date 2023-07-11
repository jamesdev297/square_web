import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:square_web/constants/constants.dart';

class StringUtil {
  static String getProfileImgUrlWithModTime(String profileImgUrl, int? modTime) {
    if(modTime == null) {
      return profileImgUrl;
    }
    return "${profileImgUrl}?mt=${modTime}";
  }

  static String? empty2Null(String? str) =>
      str?.isNotEmpty != true ? null : str;

  static List<Text> getLightCertainWord(String? source, String? word,
      {double? fontSize}) {
    if (fontSize == null) fontSize = Zeplin.size(28);

    if (word == null || word == "") {
      return [
        Text(source!,
            style: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis)
      ];
    }

    if (source == null || source == "") return [];

    final findIndex = source.toLowerCase().indexOf(word.toLowerCase());
    if (findIndex == -1)
      return [
        Text(source,
            style: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis)
      ];
    final preText = source.substring(0, findIndex);
    final lastText = source.substring(findIndex + word.length, source.length);

    return [
          Text(preText,
              style: TextStyle(
                  fontSize: fontSize, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
          Text(source.substring(findIndex, findIndex + word.length),
              style: TextStyle(
                  color: CustomColor.azureBlue,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis)
        ] +
        getLightCertainWord(lastText, word, fontSize: fontSize);
  }

  static String? addOrderPrefix(String s) {
    var code = s.toLowerCase().codeUnitAt(0);
    var prefix;

    // 한글 AC00—D7AF
    if (0xac00 <= code && code <= 0xd7af)
      prefix = '1';
    // 한글 자모 3130—318F
    else if (0x3130 <= code && code <= 0x318f)
      prefix = '2';
    // 영어 소문자 0061-007A
    else if (0x61 <= code && code <= 0x7a)
      prefix = '3';
    // 그외
    else
      prefix = '9';

    return prefix + s.toLowerCase();
  }

  static List<TextSpan> parseColorText(String str, Color accentColor,
      {bool boldToAccent = false, double? fontSize, bool isUnderline = false, VoidCallback? onTap1, VoidCallback? onTap2, VoidCallback? onTap3}) {
    var split = str.split('#color#');
    return [
      for (var i = 0; i < split.length; i++)
        if (i % 2 == 1)
          TextSpan(
            mouseCursor: onTap1 != null ? SystemMouseCursors.click : MouseCursor.defer,
            text: split[i],
            style: TextStyle(color: accentColor, fontSize: fontSize, fontWeight: boldToAccent ? FontWeight.bold : null, decoration: isUnderline ? TextDecoration.underline : null),
            recognizer: TapGestureRecognizer()
              ..onTap = i == 1 ? onTap1 : i == 3 ? onTap2 : onTap3)
        else
          TextSpan(text: split[i])
    ];
  }

  static List<TextSpan> parseManyColorText(String str) {
    var split = str.split("@@");
    return [
      for (var i = 0; i < split.length; i++)
        TextSpan(
          text: split[i].split("!#")[0],
          style: TextStyle(
            color: Color(int.parse(split[i].split("!#")[1])),
          ),
        ),
    ];
  }

  static String durationToString(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if(twoDigits(duration.inHours) == "00")
      return "${L10n.common_34_minute(twoDigitMinutes)}";

    return "${twoDigits(duration.inHours)}${L10n.common_30_hour}";
  }

  static String numberWithComma(int param) {
    return new NumberFormat('###,###,###,###').format(param);
  }

  static String smallerString(String param) {
    return param;
    if(param.length < 8)
      return param;

    return param.substring(0, 8) + "..." + param.substring(param.length-6, param.length);
  }

  static bool isValidEmailFormat(String text) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
  }
}

extension StringEx on String {
  String get breakWord {
    String breakWord = '';
    this.runes.forEach((e) {
      breakWord += String.fromCharCode(e);
      breakWord += '\u200B';
    });
    return breakWord;
  }

  String get removeZeroPoint => this.replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");

  String get numComma => this.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}
