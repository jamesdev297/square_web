import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/util/copy_util.dart';

typedef void OnTapCallback(String? stackTrace);

class _LogLine {
  final String msg;
  final String? stackTrace;
  String? _logPrefix;
  final Color color;
  final int logLevel;
  // final bool shortMode;
  final OnTapCallback? onTapCallBack;
  static final logLevelStrMap = {
    0: "debug",
    1: "info",
    2: "warning",
    3: "error",
    4: "system"
  };
  static final logLevelShortStrMap = {
    0: "d",
    1: "i",
    2: "w",
    3: "e",
    4: "sys"
  };

  String? logLevelStr(int logLevel) => LogWidget.shortLogMode ? logLevelShortStrMap[logLevel] : logLevelStrMap[logLevel];

  _LogLine(this.msg, this.stackTrace, this.color, this.logLevel,
      {this.onTapCallBack}) {
    if (stackTrace != null) _logPrefix = _getLogPrefix();
  }

  String? _getLogPrefix() {
    if(LogWidget._logPrefixMode == LogPrefixMode.time) {
      return DateTime.now().toString();
    }

    String? logPrefix;
    if (kIsWeb) {
      if (kDebugMode) {
        Frame frame = Trace.current().frames
            .firstWhere((frame) => !frame.library.contains(LogWidget._filename));
        logPrefix = ("${frame.member} (${frame.library.replaceFirst("packages/", "package:")}:${frame.line}:${frame.column})");
      }

    } else {
      String stack = StackTrace.current.toString();
      logPrefix = stack
          .split('\n')
          .firstWhere((line) => !line.contains((LogWidget).toString())
            && !line.contains((_LogLine).toString()))
          .replaceFirstMapped(RegExp(r"(#\d+[ \t]+)"), (match) => "");
    }

    if(LogWidget.shortLogMode && logPrefix != null)
      logPrefix = RegExp(r"\(([^)]+)").stringMatch(logPrefix)!.split("/").last;

    return logPrefix;
  }

  TextSpan toTextSpan() {
    Color labelColor = color.withOpacity(0.5);
    return TextSpan(children: [
      TextSpan(
          text: "[${logLevelStr(logLevel)}]",
          style: TextStyle(color: labelColor)),
      if (_logPrefix != null)
        TextSpan(
            text: "[$_logPrefix]",
            style: TextStyle(color: labelColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () => onTapCallBack?.call(stackTrace)),
      TextSpan(text: "\n $msg\n", style: TextStyle(color: color)),
    ]);
  }

  @override
  String toString() {
    return "[${logLevelStr(logLevel)}]${_logPrefix != null ? '[$_logPrefix]' : ''} $msg";
  }
}

enum LogPrefixMode {
  methodName,
  time
}

// ignore: must_be_immutable
class LogWidget extends StatefulWidget {

  static LogWidget? _instance;
  static late int _maxLine;
  static TextStyle? _textStyle;
  static LogPrefixMode _logPrefixMode = LogPrefixMode.methodName;
  static bool shortLogMode = false;
  static int minLogLevel = 0;
  static final _filename = "overlay_logger_widget.dart";

  static bool _withConsole = true;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static OverlayEntry? _openLoggerBtnEntry;

  static void init({
    int maxLine = 1000,
    TextStyle? textStyle,
    bool withConsole = true,
    bool debugModeOnly = true,
    bool? shortLogMode,
    required bool withOverlayButton,
    required GlobalKey<NavigatorState> navigatorKey,
    required String zone,
  }) {
    LogWidget._maxLine = maxLine;
    LogWidget._textStyle =
        textStyle ?? TextStyle(color: Colors.white, fontSize: Zeplin.size(26), height: 1.3);
    LogWidget._withConsole = withConsole;
    LogWidget._navigatorKey = navigatorKey;
    LogWidget.shortLogMode = shortLogMode?? LogWidget.shortLogMode;

    if (debugModeOnly && kDebugMode || !debugModeOnly) {
      if (withOverlayButton && _openLoggerBtnEntry == null) {
        OverlayState? overlayState = _navigatorKey!.currentState!.overlay;
        if (overlayState != null) {
          _openLoggerBtnEntry = OverlayEntry(builder: (context) {
            return Stack(children: [DebuggerOpenBtn()]);
          });
          overlayState.insert(_openLoggerBtnEntry!);
        }
      }
      _instance ??= LogWidget._internal();
    } else if(zone == 'live') {
      _instance = null;
    }
  }

  OverlayEntry? overlayEntry;
  StreamController<void>? _logStreamController;
  final List<_LogLine> logList = <_LogLine>[
    _LogLine("startLog", null, Colors.amber, 4)
  ];

  Iterable<_LogLine> get leveledAndReversedLogList =>
      logList.reversed.where((log) {
        if(log.logLevel < logLevel)
          return false;

        if(_includeFilter != null && _includeFilter!.isNotEmpty)
          return log.toString().contains(_includeFilter!);

        return true;
      });

  bool toBottom = true;
  int logLevel = 0;
  late State _currentState;

  String? get logLevelStr =>
      _LogLine.logLevelStrMap[logLevel]; // 0: debug, 1: info, 2: warring, 3: error

  LogWidget._internal();

  // tip for auto-completion about debug
  static void get d => {};

  static void get show => _instance?._show();

  static void get hide => _instance?._hide();

  static void debug(String msg) => _writeLog(msg, Colors.white, 0);

  static void info(String msg) => _writeLog(msg, Colors.blueAccent, 1);

  static void warning(String msg) => _writeLog(msg, Colors.yellow, 2);

  static void error(String msg) => _writeLog(msg, Colors.redAccent, 3);

  static final _excludeFilter = [
    "\"isDoneAiSay\":false",
    "isDoneAiSay: false"
  ];

  static String? _includeFilter;

  static void _writeLog(String msg, Color color, int logLevel) {
    if(LogWidget.minLogLevel > logLevel)
      return;

    if(LogWidget._instance == null)
      return;

    if(_excludeFilter.any((element) => msg.contains(element)))
      return;

    var logLine = _LogLine(msg, StackTrace.current.toString(), color, logLevel,
        onTapCallBack: _onTapCalledMethodName);
    if (_withConsole) {
      if (logLevel == 0)
        debugPrint(logLine.toString());
      else
        LogWidget.debug(logLine.toString());
    }
    _instance?.addLogLine(logLine);
  }

  static void _onTapCalledMethodName(String? stackTrace) {
    if (_navigatorKey != null) {
      OverlayState? overlayState = _navigatorKey!.currentState!.overlay;
      if (overlayState != null) {
        VoidCallback? closeCallback;
        OverlayEntry stackTracePageEntry = OverlayEntry(
            builder: (context) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => closeCallback?.call(),
                    ),
                    title: Text("Stacktrace")),
                body: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      stackTrace ?? "",
                      style: _textStyle,
                    ))));
        closeCallback = () => stackTracePageEntry.remove();

        overlayState.insert(stackTracePageEntry);
      }
    }
  }

  void _show() async {
    if (overlayEntry == null) {
      OverlayState? overlayState = _navigatorKey!.currentState?.overlay;
      if (overlayState != null) {
        overlayEntry = OverlayEntry(builder: (context) => this);
        overlayState.insert(overlayEntry!);
      }
    }
  }

  void _hide() async {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void addLogLine(_LogLine logLine) {
    logList.add(logLine);
    if (logList.length > LogWidget._maxLine)
      logList.removeRange(0, logList.length - LogWidget._maxLine);

    if (_logStreamController != null && !_logStreamController!.isClosed) {

    }
  }

  @override
  State<StatefulWidget> createState() {
    _logStreamController = StreamController<void>();
    _currentState = _LogWidgetState();
    return _currentState;
  }
}

class _LogWidgetState extends State<LogWidget> {
  bool toBottom = true;
  ScrollController _scrollController = ScrollController();

  _LogLine? lastLog;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 1) {
        setState(() {
          toBottom = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget._logStreamController!.close();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        LogWidget.hide;
        return true;
      },
      child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
          appBar: AppBar(
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              titleSpacing: 0,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 10,
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            widget.logLevel++;
                            if (widget.logLevel > 3) widget.logLevel = 0;
                          });
                        },
                        child: Text(widget.logLevelStr!)),
                  ),
                  Expanded(
                      flex: 10,
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              widget.logList
                                ..clear()
                                ..add(_LogLine(
                                    "clear logs", null, Colors.amber, 4));
                            });
                          },
                          child: Text("Clear"))),
                  Expanded(
                      flex: 10,
                      child: TextButton(
                          onPressed: () {
                            CopyUtil.copyText(widget.logList.join("\n\n"), () { });
                          },
                          child: Text("Copy"))),
                  Expanded(
                      flex: 3,
                      child: Tooltip(
                        message: "enable short mode",
                        child: Checkbox(
                            value: LogWidget.shortLogMode,
                            onChanged: (bool? value) {
                              setState(() {
                                LogWidget.shortLogMode = !LogWidget.shortLogMode;
                              });
                            },
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: TextButton(
                        onPressed: () => widget._hide(),
                        child: Icon(Icons.close)),
                  ),
                ],
              )),
          floatingActionButton: FloatingActionButton(

            onPressed: () {
              setState(() {
                toBottom = !toBottom;
                if (toBottom) _scrollController.jumpTo(0.0);
              });
            },
            child: Icon(
              Icons.arrow_downward,
              color: Colors.black,
            ),
            mini: true,
            backgroundColor: toBottom
                ? Colors.blueAccent.withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: StreamBuilder(
                        stream: widget._logStreamController!.stream,
                        builder: (context, snap) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            if (toBottom) _scrollController.jumpTo(0.0);
                          });
                          var leveledAndReversedLogIterator =
                              widget.leveledAndReversedLogList;
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.all(10),
                            itemCount: leveledAndReversedLogIterator.length,
                            itemBuilder: (context, index) {
                              return SelectableText.rich(
                                leveledAndReversedLogIterator
                                    .elementAt(index)
                                    .toTextSpan(),
                                style: LogWidget._textStyle,
                              );
                            },
                          );
                        })),
                  SizedBox(
                    height: 30,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width > 0 ? MediaQuery.of(context).size.width : 200) - 20,
                              height: 25 ,
                              child: TextField(
                                maxLines: 1,
                                minLines: 1,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(3),
                                  labelText: "filter"
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    if(value != null && value.isEmpty) {
                                      LogWidget._includeFilter = null;
                                    } else {
                                      LogWidget._includeFilter = value;
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          )),
    );
  }
}

class DebuggerOpenBtn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DebuggerOpenBtnState();
}

class _DebuggerOpenBtnState extends State<DebuggerOpenBtn> {
  Offset position = Offset(10, 300);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
            feedback: Container(
              child: FloatingActionButton(
                child: Icon(Icons.bug_report_outlined),
                onPressed: () => LogWidget.show,
              ),
              height: 30,
              width: 30,
            ),
            child: Container(
              child: FloatingActionButton(
                  child: Icon(Icons.bug_report_outlined),
                  onPressed: () => LogWidget.show),
              height: 30,
              width: 30,
            ),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              setState(() {
                position = details.offset;
              });
            }));
  }
}
