part of  'help_httpresult.dart';

HelpHttpResult _$HelpHttpResultFromJson(Map<String, dynamic> json) {
  List<dynamic> contents = json['contents'];
  List<Map<String, dynamic>> contentsMap = [];
  contents.forEach((element) {
    Map<String, dynamic> temp = {};
    element.keys.forEach((key){
      temp.putIfAbsent(key, () => element[key]);
    });
    contentsMap.add(temp);
  });

  return HelpHttpResult(
    status: json['status'] as int?,
    contents: contentsMap,
  );
}