import 'package:file_picker/file_picker.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/dao/http_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/feedback/report_problem_model.dart';
import 'package:square_web/model/feedback/suggest_model.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/squarepacket.dart';

import 'command.dart';

class ReportProblemCommand extends WsCommand {
  ReportProblemModel model;
  String? feedbackId;

  @override
  int? wsTimeout = 5000;

  ReportProblemCommand(this.model);

  @override
  String getUri() => Uris.feedback.reportProblem;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "topic": model.topic,
        "email": model.email,
        "device": model.device,
        "summarize": model.summarize,
        "description": model.description,
        if(model.fileLinkList != null && model.fileLinkList!.isNotEmpty)
          "fileLinkList": model.fileLinkList,
      }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    feedbackId = content['feedback'];
    return true;
  }
}

class SuggestCommand extends WsCommand {
  SuggestModel model;
  String? feedbackId;

  @override
  int? wsTimeout = 5000;

  SuggestCommand(this.model);

  @override
  String getUri() => Uris.feedback.suggest;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "email": model.email,
        "summarize": model.summarize,
        "description": model.description,
        if(model.fileLinkList != null && model.fileLinkList!.isNotEmpty)
          "fileLinkList": model.fileLinkList,
      }));
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    feedbackId = content['feedback'];
    return true;
  }
}

class UploadFileCommand extends WsCommand {
  List<PlatformFile> fileList;
  List<String> uploadedUrlList = [];

  UploadFileCommand(this.fileList);

  @override
  String getUri() => Uris.feedback.uploadFeedbackFile;

  @override
  Future<bool> execute() async {

    var packet = SquarePacket(uri: getUri(), body: JsonMap({
      "count": fileList.length
    }));
    return true;

    if (!await processRequest(packet)) {
      return false;
    }

    List<dynamic> urlList = resPacket!.getContent().get("urlList");
    List<dynamic> uploadedUrlTempList = resPacket!.getContent().get("uploadedUrlList");

    for(int i = 0; i < urlList.length; i++) {
      PlatformFile file = fileList[i];

      if(allowedImageExtensions.contains(file.extension?.toLowerCase())) {
        var result = await HttpDao().uploadMedia(urlList[i], headers: {"Content-Type": "image/${fileList[i].extension?.toLowerCase()}"}, body: file.bytes);
        if (result?.status == 200) {
          uploadedUrlList.add(uploadedUrlTempList[i]);
          LogWidget.debug("uploaded success : ${uploadedUrlTempList[i]}");
        } else {
          LogWidget.debug("uploaded ${result?.toJson()}");
        }
      } else {
        var result = await HttpDao().uploadMedia(urlList[i], headers: {"Content-Type": "video/mp4"}, body: file.bytes);
        if (result?.status == 200) {
          uploadedUrlList.add(uploadedUrlTempList[i]);
          LogWidget.debug("uploaded success : ${uploadedUrlTempList[i]}");
        } else {
          LogWidget.debug("uploaded ${result?.toJson()}");
        }
      }
    }

    return true;
  }
}
