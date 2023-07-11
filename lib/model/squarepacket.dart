import 'dart:convert';

// import 'dart:typed_data';
// import 'package:bson/bson.dart';

import 'package:archive/archive_io.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/json_map.dart';

class SquarePacket {
  String uri;
  JsonMap _header = JsonMap.empty();
  JsonMap _body = JsonMap.empty();
  JsonMap _param = JsonMap.empty();

  JsonMap get header => _header;
  set header(JsonMap? header) {
    if (header == null) return ;
    this._header = header;
  }

  JsonMap get body => _body;
  set body(JsonMap? body) {
    if (body == null) return ;
    this._body = body;

  }

  JsonMap get param => _param;
  set param(JsonMap? param) {
    if (param == null) return ;
    this._param = param;
  }

  int get txNo {
    if (!header.contains("txNo")) {
      int tx = random.nextInt(987654321);
      header["txNo"] = tx;
      header.putIfAbsent("txNo", () => tx);
      return tx;
    } else {
      return header["txNo"];
    }
  }

  SquarePacket({required this.uri, JsonMap? header, JsonMap? body, JsonMap? param}) {
    this.header = header;
    this.body = body;
    this.param = param;
    this.txNo;
  }

  factory SquarePacket.fromJson(String jsonPacket) {
    List<dynamic> list = json.decode(jsonPacket);
    SquarePacket packet = SquarePacket(
      uri: list[0], header: JsonMap(list[1]), body: JsonMap(list[2]));

    return packet;
  }

  String toJson() {
    return json.encode(
      [
        uri,
        header.map,
        body.map,
      ]
    );
  }

  // factory SquarePacket.fromBson(Uint8List byteData) {
  //   var bsonBinary = BsonBinary.from(byteData);
  //   Map<String, dynamic> map = BSON().deserialize(bsonBinary);
  //   SquarePacket packet = SquarePacket(
  //       uri: map["0"], header: JsonMap(map["1"]), body: JsonMap(map["2"]));
  //
  //   return packet;
  // }

  // Uint8List toBson() {
  //   BsonBinary bsonBinary = BSON().serialize([
  //     uri,
  //     header.map,
  //     body.map,
  //   ]);
  //   return bsonBinary.byteList;
  // }

  static String decodeZLib(List<int> byteData) {
    List<int> decompressed = ZLibDecoder().decodeBytes(byteData);
    return utf8.decode(decompressed);
  }

  List<int> toZLib() {
    String json = toJson();
    List<int> compressed = ZLibEncoder().encode(utf8.encode(json));
    return compressed;
  }

  int? getStatus() {
    return body["status"];
  }

  String? getDesc() {
    return body["desc"];
  }

  JsonMap getContent() {
    return JsonMap(body["content"]);
  }
}
