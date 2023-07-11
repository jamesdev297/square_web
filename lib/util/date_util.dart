import 'package:square_web/constants/constants.dart';

class DateUtil {
  static String dateDurationToString(Duration duration, {bool twoStep = false, bool onlyUnderHours = false}) {
    if(duration.inDays > 7 && !onlyUnderHours)
      return '${duration.inDays % 7}${L10n.common_28_week}${twoStep ? " ${duration.inDays % 7}${L10n.common_29_day}" : ""}';
    else if(duration.inDays != 0 && !onlyUnderHours)
      return '${duration.inDays}${L10n.common_29_day}${twoStep ? " ${duration.inHours % 24}${L10n.common_30_hour}" : ""}';
    else if(duration.inHours > 0)
      return '${onlyUnderHours ? duration.inHours : duration.inHours % 24}${L10n.common_30_hour}${twoStep ? " ${duration.inMinutes % 60}${L10n.common_31_minute}" : ""}';
    else if(duration.inMinutes > 0)
      return '${duration.inMinutes % 60}${L10n.common_31_minute}${twoStep ? " ${duration.inSeconds % 60}${L10n.common_32_sec}" : ""}';
    else if(duration.inSeconds > 0)
      return '${duration.inSeconds}${L10n.common_32_sec}';
    else
      return L10n.common_33_now;
  }
}