
import 'package:json_annotation/json_annotation.dart';

part 'help_httpresult.g.dart';

@JsonSerializable(nullable: false)
class HelpHttpResult{
  int? status;
  List<Map<String, dynamic>>? contents;


  HelpHttpResult({this.status, this.contents});

  factory HelpHttpResult.fromJson(Map<String, dynamic> json) => _$HelpHttpResultFromJson(json);
}
