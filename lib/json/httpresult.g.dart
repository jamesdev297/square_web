// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'httpresult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpResult _$HttpResultFromJson(Map<String, dynamic> json) {
  return HttpResult(
    status: json['status'] as int?,
    desc: json['desc'] as String?,
    content: json['content'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$HttpResultToJson(HttpResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'desc': instance.desc,
      'content': instance.content,
    };
