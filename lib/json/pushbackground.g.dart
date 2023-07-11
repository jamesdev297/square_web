// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pushbackground.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushBackground _$PushBackgroundFromJson(Map<String, dynamic> json) {
  return PushBackground(
    json['contentTitle'] as String?,
    json['contentText'] as String?,
  )
    ..appId = json['appId'] as String?
    ..pushTime = json['pushTime'] as String?
    ..theme = json['theme'] as String?
    ..pushType = json['pushType'] as String?
    ..badge = json['badge'] as String?
    ..ticker = json['ticker'] as String?
    ..vibrate = json['vibrate'] as String?
    ..smallIcon = json['smallIcon'] as String?
    ..sound = json['sound'] as String?
    ..link = json['link'] as String?
    ..deepLink = json['deepLink'] as String?
    ..bigText = json['bigText'] as String?
    ..bigImageUrl = json['bigImageUrl'] as String?
    ..reportingUrl = json['reportingUrl'] as String?;
}

Map<String, dynamic> _$PushBackgroundToJson(PushBackground instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'contentTitle': instance.contentTitle,
      'contentText': instance.contentText,
      'pushTime': instance.pushTime,
      'theme': instance.theme,
      'pushType': instance.pushType,
      'badge': instance.badge,
      'ticker': instance.ticker,
      'vibrate': instance.vibrate,
      'smallIcon': instance.smallIcon,
      'sound': instance.sound,
      'link': instance.link,
      'deepLink': instance.deepLink,
      'bigText': instance.bigText,
      'bigImageUrl': instance.bigImageUrl,
      'reportingUrl': instance.reportingUrl,
    };
