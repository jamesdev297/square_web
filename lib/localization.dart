import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localizations/src/utils/date_localizations.dart' as util;
import 'package:intl/intl.dart' as intl;

typedef OwnedKanBadgeFunction = String Function(int value);

class CupertinoLocalizationKoSquare extends GlobalCupertinoLocalizations {
  final String localeName;
  /// Create an instance of the translation bundle for Korean.
  ///
  /// For details on the meaning of the arguments, see [GlobalCupertinoLocalizations].
  const CupertinoLocalizationKoSquare({
    required this.localeName,
    required intl.DateFormat fullYearFormat,
    required intl.DateFormat dayFormat,
    required intl.DateFormat mediumDateFormat,
    required intl.DateFormat singleDigitHourFormat,
    required intl.DateFormat singleDigitMinuteFormat,
    required intl.DateFormat doubleDigitMinuteFormat,
    required intl.DateFormat singleDigitSecondFormat,
    required intl.NumberFormat decimalFormat,
  }) : super(
    localeName: localeName,
    fullYearFormat: fullYearFormat,
    dayFormat: dayFormat,
    mediumDateFormat: mediumDateFormat,
    singleDigitHourFormat: singleDigitHourFormat,
    singleDigitMinuteFormat: singleDigitMinuteFormat,
    doubleDigitMinuteFormat: doubleDigitMinuteFormat,
    singleDigitSecondFormat: singleDigitSecondFormat,
    decimalFormat: decimalFormat,
  );

  static const List<String> _shortWeekdays = <String>[
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  static const List<String> _shortMonths = <String>[
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월',
  ];

  static const List<String> _months = <String>[
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월',
  ];


  @override
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];


  @override
  String datePickerMediumDate(DateTime date) {
    return '${_shortMonths[date.month - DateTime.january]} '
        '${date.day.toString().padRight(2)}일 ${_shortWeekdays[date.weekday - DateTime.monday]}';
  }

  @override
  String get alertDialogLabel => '알림';

  @override
  String get anteMeridiemAbbreviation => '오전';

  @override
  String get copyButtonLabel => '복사';

  @override
  String get cutButtonLabel => '잘라냄';

  @override
  String get datePickerDateOrderString => 'ymd';

  @override
  String get datePickerDateTimeOrderString => 'date_dayPeriod_time';

  @override
  String? get datePickerHourSemanticsLabelFew => null;

  @override
  String? get datePickerHourSemanticsLabelMany => null;

  @override
  String get datePickerHourSemanticsLabelOne => '\$hour시 정각';

  @override
  String get datePickerHourSemanticsLabelOther => '\$hour시 정각';

  @override
  String? get datePickerHourSemanticsLabelTwo => null;

  @override
  String? get datePickerHourSemanticsLabelZero => null;

  @override
  String? get datePickerMinuteSemanticsLabelFew => null;

  @override
  String? get datePickerMinuteSemanticsLabelMany => null;

  @override
  String get datePickerMinuteSemanticsLabelOne => '1분';

  @override
  String get datePickerMinuteSemanticsLabelOther => '\$minute분';

  @override
  String? get datePickerMinuteSemanticsLabelTwo => null;

  @override
  String? get datePickerMinuteSemanticsLabelZero => null;

  @override
  String get pasteButtonLabel => '붙여넣기';

  @override
  String get postMeridiemAbbreviation => '오후';

  @override
  String get selectAllButtonLabel => '전체 선택';

  @override
  String? get timerPickerHourLabelFew => null;

  @override
  String? get timerPickerHourLabelMany => null;

  @override
  String get timerPickerHourLabelOne => '시간';

  @override
  String get timerPickerHourLabelOther => '시간';

  @override
  String? get timerPickerHourLabelTwo => null;

  @override
  String? get timerPickerHourLabelZero => null;

  @override
  String? get timerPickerMinuteLabelFew => null;

  @override
  String? get timerPickerMinuteLabelMany => null;

  @override
  String get timerPickerMinuteLabelOne => '분';

  @override
  String get timerPickerMinuteLabelOther => '분';

  @override
  String? get timerPickerMinuteLabelTwo => null;

  @override
  String? get timerPickerMinuteLabelZero => null;

  @override
  String? get timerPickerSecondLabelFew => null;

  @override
  String? get timerPickerSecondLabelMany => null;

  @override
  String get timerPickerSecondLabelOne => '초';

  @override
  String get timerPickerSecondLabelOther => '초';

  @override
  String? get timerPickerSecondLabelTwo => null;

  @override
  String? get timerPickerSecondLabelZero => null;

  @override
  String get todayLabel => '오늘';

  @override
  // TODO: implement modalBarrierDismissLabel
  String get modalBarrierDismissLabel => throw UnimplementedError();

  @override
  // TODO: implement tabSemanticsLabelRaw
  String get tabSemanticsLabelRaw => throw UnimplementedError();

  @override
  // TODO: implement searchTextFieldPlaceholderLabel
  String get searchTextFieldPlaceholderLabel => throw UnimplementedError();

  static Map<String, OwnedKanBadgeFunction> ownedKanBadgeTextMap = {
    'en' : (int sum) {
      if(sum > 1000000000) {
        return (sum/1000000000).toStringAsFixed(1) + "B";
      }else if(sum > 1000000) {
        return (sum/1000000).toStringAsFixed(1) + "M";
      }else if(sum > 1000) {
        return (sum/1000).toStringAsFixed(1) + "K";
      }else {
        return sum.toString();
      }
    },
    'ko' : (int sum) {
      if(sum > 100000000) {
        return (sum/100000000).toStringAsFixed(1) + "억";
      }else if(sum > 10000000) {
        return (sum/10000000).toStringAsFixed(1) + "천만";
      }else if(sum > 1000000) {
        return (sum/1000000).toStringAsFixed(1) + "백만";
      }else if(sum > 10000) {
        return (sum/10000).toStringAsFixed(1) + "만";
      }else {
        return sum.toString();
      }
    },
  };

  static CupertinoLocalizationKoSquare? of(BuildContext context) {
    return Localizations.of<CupertinoLocalizationKoSquare>(context, CupertinoLocalizationKoSquare);
  }
}


class CupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const CupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => kCupertinoSupportedLanguages.contains(locale.languageCode);

  static final Map<Locale, Future<CupertinoLocalizations>> _loadedTranslations = <Locale, Future<CupertinoLocalizations>>{};

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    assert(isSupported(locale));
    return _loadedTranslations.putIfAbsent(locale, () {
      final String localeName = intl.Intl.canonicalizedLocale(locale.toString());
      assert(
      locale.toString() == localeName,
      'Flutter does not support the non-standard locale form $locale (which '
          'might be $localeName',
      );
      util.loadDateIntlDataIfNotLoaded();

      late intl.DateFormat fullYearFormat;
      late intl.DateFormat dayFormat;
      late intl.DateFormat mediumDateFormat;
      // We don't want any additional decoration here. The am/pm is handled in
      // the date picker. We just want an hour number localized.
      late intl.DateFormat singleDigitHourFormat;
      late intl.DateFormat singleDigitMinuteFormat;
      late intl.DateFormat doubleDigitMinuteFormat;
      late intl.DateFormat singleDigitSecondFormat;
      late intl.NumberFormat decimalFormat;

      void loadFormats(String? locale) {
        fullYearFormat = intl.DateFormat.y(locale);
        dayFormat = intl.DateFormat.d(locale);
        mediumDateFormat = intl.DateFormat.MMMEd(locale);
        // TODO(xster): fix when https://github.com/dart-lang/intl/issues/207 is resolved.
        singleDigitHourFormat = intl.DateFormat('HH', locale);
        singleDigitMinuteFormat = intl.DateFormat.m(locale);
        doubleDigitMinuteFormat = intl.DateFormat('mm', locale);
        singleDigitSecondFormat = intl.DateFormat.s(locale);
        decimalFormat = intl.NumberFormat.decimalPattern(locale);
      }

      if (intl.DateFormat.localeExists(localeName)) {
        loadFormats(localeName);
      } else if (intl.DateFormat.localeExists(locale.languageCode)) {
        loadFormats(locale.languageCode);
      } else {
        loadFormats(null);
      }



      return SynchronousFuture<CupertinoLocalizations>(
          CupertinoLocalizationKoSquare(localeName: localeName, fullYearFormat: fullYearFormat, dayFormat: dayFormat, mediumDateFormat: mediumDateFormat, singleDigitHourFormat: singleDigitHourFormat, singleDigitMinuteFormat: singleDigitMinuteFormat, doubleDigitMinuteFormat: doubleDigitMinuteFormat, singleDigitSecondFormat: singleDigitSecondFormat, decimalFormat: decimalFormat)
      );
    });
  }

  @override
  bool shouldReload(CupertinoLocalizationsDelegate old) => false;

  @override
  String toString() => 'CupertinoLocalizations.delegate(${kCupertinoSupportedLanguages.length} locales)';
}
