import 'package:json_annotation/json_annotation.dart';

part 'pushbackground.g.dart';

@JsonSerializable(nullable: false)
class PushBackground {
  String? contentTitle;
  String? contentText;

  String? smallIcon;
  String? appId;
  String? pushTime;
  String? pushType;
  String? theme;
  String? badge;
  String? ticker;
  String? vibrate;
  String? sound;
  String? link;
  String? deepLink;
  String? bigText;
  String? bigImageUrl;
  String? reportingUrl;

  PushBackground(this.contentTitle, this.contentText);

  factory PushBackground.fromJson(Map<String, dynamic> json) => _$PushBackgroundFromJson(json);
  Map<String, dynamic> toJson() => _$PushBackgroundToJson(this);
}
