import 'package:square_web/config.dart';

class EmoticonPackModel {
  String? emoticonPackId;
  int? regTime;

  EmoticonPackModel({
    this.emoticonPackId,
    this.regTime
  });

  EmoticonPackModel.fromMap(dynamic map) {
    emoticonPackId = map["packId"];
    regTime = map["regTime"];
  }

  String get path => "emoticon/$emoticonPackId";
  String get packIconPath => "$path/icon.png";
  String get imagePath => "$path/emoticonSet.png";
  String get metaDataPath => "$path/meta.yaml";

  @override
  String toString() => "EmoticonPackModel:${emoticonPackId}/${regTime}";

  @override
  int get hashCode => emoticonPackId!.hashCode;

  @override
  bool operator ==(Object other) {
    if(!(other is EmoticonPackModel))
      return false;
    return emoticonPackId == other.emoticonPackId;
  }
}