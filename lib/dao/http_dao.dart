import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/json/help_httpresult.dart';
import 'package:square_web/json/httpresult.dart';

class HttpDao {
  static final HttpDao _instance = HttpDao._internal();
  factory HttpDao() => _instance;
  HttpDao._internal();

  HttpResult? resultHttp(http.Response response) {
    Map<String, dynamic>? result;
    if (response.body != null) {
      if (response.body.startsWith("{")) {
        result = json.decode(response.body);
        if (!result!.containsKey("status")) {
          result.putIfAbsent("status", () => response.statusCode);
        }
      } else {
        result = {"status": response.statusCode, "desc" : response.body };
      }
    } else {
      result = {"status": response.statusCode};
    }

    try {
      return HttpResult.fromJson(result);
    } catch (e) {
      LogWidget.debug("resultHttp $response");
      return null;
    }
  }

  HelpHttpResult? resultHelpHttp(http.Response response) {
    Map<String, dynamic>? result;
    if (response.body != null) {
      if (response.body.startsWith("{")) {
        result = json.decode(utf8.decode(response.bodyBytes));
        if (!result!.containsKey("status")) {
          result.putIfAbsent("status", () => response.statusCode);
        }
      } else {
        result = {"status": response.statusCode, "contents" : response.body };
      }
    } else {
      result = {"status": response.statusCode};
    }

    try {
      return HelpHttpResult.fromJson(result);
    } catch (e) {
      LogWidget.debug("resultHelpHttp ${response.body}");
      return null;
    }
  }

  Future<HttpResult?> callPost(String url, {Map<String, String>? headers, body}) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    return resultHttp(response);
  }

  Future<HttpResult?> uploadMedia(String url, {Map<String, String>? headers, body}) async {
    final response = await http.put(Uri.parse(url), headers: headers, body: body);

    return resultHttp(response);
  }

  Future<HelpHttpResult?> callGetHelpContent(String url) async {
    final response = await http.get(Uri.parse(url));
    return resultHelpHttp(response);
  }

  Future<http.Response> callGetResponse(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }
}
