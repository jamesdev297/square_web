import 'package:square_web/config.dart';

class EmoticonModel {
  String emoticonId;
  String? _emoticonPackId;

  EmoticonModel({
    required this.emoticonId,
    String? emoticonPackId,
  }) {
    this._emoticonPackId = emoticonPackId;
  }

  String get path => "emoticon/$emoticonId";

  String get metaDataPath => "${path}/meta.yaml";

  String get imagePath => "$path/image.png";

  String get emoticonPackId {
    if(_emoticonPackId != null) return _emoticonPackId!;
    List<String> splited = emoticonId.split("/");
    splited.removeLast();
    _emoticonPackId = splited.join();
    return _emoticonPackId!;
  }

}
