import 'package:intl/intl.dart';
import 'package:square_web/constants/constants.dart';

class LocaleDate {
  static final LocaleDate _instance = LocaleDate._internal();

  factory LocaleDate() => _instance;
  LocaleDate._internal();

  String expressionMsgTime(int? msgTime, {bool onlyTime = false}) {
    DateTime now = DateTime.now();
    DateTime msgDateTime = DateTime.fromMillisecondsSinceEpoch(msgTime!);
    

    if (onlyTime || !(msgDateTime.isBefore(getDayStart(now)))) {
      return DateFormat('a hh:mm', L10n.localeName)
          .format(msgDateTime);
    // } else if (msgTime > yesterdayStart) {
    //   return L10n.yesterday;
    } else if (!(msgDateTime.isBefore(DateTime(now.year)))) {
      return DateFormat("MMMd", L10n.localeName)
          .format(msgDateTime);
    } else {
      return DateFormat('yyyy. M. d')
          .format(msgDateTime);
    }
  }

  String getDate(int time) {
    return DateFormat("yMMMd", L10n.localeName).add_EEEE()
         .format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  String getDateMDY(int time) {
    return DateFormat("MMM d, yyy", L10n.localeName).format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  String MillisecondsSinceEpochToString(int time) {
    return DateFormat("MMMd", L10n.localeName).addPattern(" EEEE a h:mm")
         .format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  int getMillisecondsFromMinutes(int minutes) {
    return (minutes * 100000 / 1.66667).round();
  }

  int getMillisecondsFromDays(int days) {
    return days * 24 * 3600000;
  }

  DateTime getDayStart(DateTime time){
    return DateTime(time.year, time.month, time.day);
  }
}
