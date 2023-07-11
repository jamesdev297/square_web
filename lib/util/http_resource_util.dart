import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:yaml/yaml.dart';
import 'dart:ui' as ui;

class HttpResourceUtil {

  static Future<dynamic> downloadYaml(String metaDataPath) async {
    String? yamlString = await downloadString(metaDataPath);
    if (yamlString == null) return null;
    return loadYaml(yamlString);
  }

  static Future<ui.Image?> downloadImage(String path) async {
    Uint8List? bytes = await downloadBytes(path);
    if (bytes == null) return null;
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  static Future<Uint8List?> downloadBytes(String url) async {
    try {
      var ret = (await rootBundle.load(url)).buffer.asUint8List();
      return ret;
      // http.Response response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      // if (response.statusCode == 200) {
      //   return response.bodyBytes;
      // }
      return null;
    } catch (e) {
      LogWidget.debug("downloadBytes error: $e");
      return null;
    }
  }

  static Future<dynamic> getHeadersFromImageUrl(String url) async {
    try {
      http.Response response = await http.head(Uri.parse(url)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.headers;
      }
      return null;
    } catch (e) {
      LogWidget.debug("getByteSizeFromImageUrl error: $e");
      return null;
    }
  }

  static Future<bool> uploadNftImage(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      LogWidget.debug("uploadNftImage error: $e");
      return false;
    }
  }

  static Future<bool> headNftImageFromCdnAddress(String url) async {
    try {
      http.Response response = await http.head(Uri.parse(url)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      LogWidget.debug("headNftImageFromCdnAddress error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> downloadFile(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = {};
        map.putIfAbsent("bytes", () => response.bodyBytes);
        map.putIfAbsent("content-type", () => response.headers['content-type']);
        return map;
      }
      return null;
    } catch (e) {
      LogWidget.debug("downloadBytes error: $e");
      return null;
    }
  }

  static Future<String?> downloadString(String url) async {
    try {
      return const Utf8Decoder().convert((await rootBundle.load(url)).buffer.asUint8List());
      /*var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }*/
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> getHealthCheck(String url) async {
    try {
      var response = await http.head(Uri.parse(url)).timeout(Duration(milliseconds: 2000));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

}