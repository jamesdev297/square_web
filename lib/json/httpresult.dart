import 'package:json_annotation/json_annotation.dart';

part 'httpresult.g.dart';

@JsonSerializable(nullable: false)
class HttpResult {
  int? status;
  final String? desc;
  final Map<String, dynamic>? content;

  HttpResult({this.status, this.desc, this.content});
  factory HttpResult.fromJson(Map<String, dynamic> json) => _$HttpResultFromJson(json);
  Map<String, dynamic> toJson() => _$HttpResultToJson(this);
}
