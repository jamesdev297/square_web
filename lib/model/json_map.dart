import 'dart:convert';

class JsonMap {
  Map<String, dynamic>? map;

  JsonMap.empty() {
    map = {};
  }

  JsonMap(this.map, {String? jsonText}) {
    if (jsonText != null) {
      this.map = jsonDecode(jsonText);
    }

    if (map == null) {
      throw FormatException("can't make a json map");
    }
  }

  dynamic operator [](String key) => map![key];
  void operator []=(String key, dynamic value) => map![key] = value;
  dynamic get(String key) => map![key];
  bool contains(String key) => map![key] != null;
  dynamic putIfAbsent(String key, dynamic value) => map!.putIfAbsent(key, () => value);
  String toJson() => jsonEncode(map);
  dynamic addAll(Map<String, dynamic> map) => this.map!.addAll(map);
  Map<String, dynamic> toMap() => map!;
  Map<String, String> toStrMap() => map!.map((key, value) => MapEntry(key, value.toString()));
}
