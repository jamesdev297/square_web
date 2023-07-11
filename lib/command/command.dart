import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:square_web/config.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/squarepacket.dart';
import 'package:http/http.dart' as http;

import 'dart:collection';

abstract class WsCommand extends Command {
  SquarePacket? reqPacket;
  SquarePacket? resPacket;
  int? wsTimeout;

  Future<bool> processRequest(SquarePacket? request) async {
    reqPacket = request;
    resPacket = await WebsocketDao().callRequest(reqPacket, wsTimeout);
    if (resPacket == null) {
      return false;
    }
    if (resPacket!.getStatus() != 200) {
      return false;
    }
    return true;
  }

  int? get status => resPacket == null ? -1 : resPacket!.getStatus();

  String? get desc => resPacket!.getDesc();

  JsonMap get content => resPacket!.getContent();

  @override
  String toString() {
    return "reqPacket: ${reqPacket!.toJson()}${resPacket == null ? '' : '\nresPacket: ${resPacket!.toJson()}'}";
  }
}

enum HttpMethod { POST, GET }

abstract class HttpCommand extends Command {
  SquarePacket? reqPacket;
  SquarePacket? resPacket;
  HttpMethod method;
  bool withCredential;

  HttpCommand(this.method, {this.withCredential = false});

  Future<bool> processRequest(SquarePacket request, {ServiceId serviceId = ServiceId.pepper_core}) async {
    reqPacket = request;
    request.body.map?.removeWhere((key, value) => value == null);
    LogWidget.debug("http request. command:${this.runtimeType} / uri:${request.uri} / ${request.body.toJson()}, serverType : ${Config.getHttpServerAddr(serviceId)}");
    http.Response? response;

    BrowserClient client = BrowserClient()..withCredentials = withCredential;
    try {
      Map<String, String>? queryParam = null;
      switch (method) {
        case HttpMethod.POST:
          queryParam = request.param.toStrMap();
          if(queryParam.isEmpty)
            queryParam = null;

          response = await client.post(
              Uri.https(Config.getHttpServerAddr(serviceId), request.uri, queryParam),
              // Uri.http(Config.getHttpServerAddr(serviceId), request.uri, queryParam),
              headers: {"Content-Type": "application/json"}..addAll(request.header.toStrMap()),
              body: utf8.encode(request.body.toJson()));
          break;
        case HttpMethod.GET:
          queryParam = request.body.toStrMap();
          if(queryParam.isEmpty)
            queryParam = null;

          response = await client.get(
              Uri.https(Config.getHttpServerAddr(serviceId), request.uri, queryParam),
              // Uri.http(Config.getHttpServerAddr(serviceId), request.uri, queryParam),
              headers: request.header.toStrMap());
          break;
      }
    } finally {
      client.close();
    }

    if (response == null) return false;
    LogWidget.debug("http response. status : ${response.statusCode} / header : ${response.headers} "
        "/ body : ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}");

    resPacket = SquarePacket(
        uri: reqPacket!.uri,
        header: JsonMap(null, jsonText: jsonEncode(response.headers)),
        body: JsonMap(null, jsonText: response.body));

    if (resPacket == null) {
      return false;
    }
    if (resPacket!.getStatus() != 200) {
      return false;
    }
    return true;
  }

  int? get status => resPacket == null ? -1 : resPacket!.getStatus();

  String? get desc => resPacket!.getDesc();

  JsonMap get content => resPacket!.getContent();

  @override
  String toString() {
    return "reqPacket: ${reqPacket!.toJson()}${resPacket == null ? '' : '\nresPacket: ${resPacket!.toJson()}'}";
  }
}

abstract class Command extends BaseCommand {
  Future<bool> undo() async {
    return true;
  }

  bool get isOnRecord => false;
}

abstract class BaseCommand {
  String getUri();

  Future<bool> execute();

  Future<bool> undo();

  bool get isOnRecord => true;
}

class CommandExecutor {
  final CommandHistory _commandHistory = CommandHistory();

  Future<bool> executeCommand(BaseCommand command) async {
    bool result = await command.execute();
    if (command.isOnRecord) {
      _commandHistory.add(command);
    }
    return result;
  }

  Future<bool> undo() async {
    BaseCommand command = _commandHistory.pop()!;
    bool result = await command.undo();
    return result;
  }

  CommandHistory get history => _commandHistory;

  dynamic get historyList => _commandHistory.list;

  List<String> get historylistReversed => _commandHistory.listReversed;
}

class CommandHistory {
  final ListQueue<BaseCommand> _commandList = ListQueue<BaseCommand>();
  final int maxSize = 50;

  bool get isEmpty => _commandList.isEmpty;

  List<String> get list => _commandList.map((c) => c.getUri()).toList();

  List<String> get listReversed => _commandList.map((c) => c.getUri()).toList().reversed.toList();

  void add(BaseCommand command) {
    _commandList.add(command);
    if (_commandList.length > maxSize) {
      _commandList.removeFirst();
    }
  }

  BaseCommand? pop() {
    if (_commandList.isNotEmpty) {
      var command = _commandList.removeLast();
      return command;
    }
    return null;
  }
}
