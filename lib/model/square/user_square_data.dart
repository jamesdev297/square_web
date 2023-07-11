import 'dart:typed_data';

import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/square/square_model.dart';

class UserSquareData {
  String? squareId;
  String? squareName;
  String? squareImgUrl;
  String? lang;
  SquareType squareType = SquareType.user;
  Uint8List? tempSquareImgData;

  String? aiPlayerId;

  UserSquareData({this.squareId, this.squareName, this.squareImgUrl, this.lang, this.tempSquareImgData, this.aiPlayerId});
  UserSquareData.fromData(UserSquareData? model)
      : this.squareId = model?.squareId,
        this.squareName = model?.squareName ?? "",
        this.squareImgUrl = model?.squareImgUrl,
        this.aiPlayerId = model?.aiPlayerId;

  UserSquareData.fromSquareWithAi(SquareModel? model, String aiPlayerId)
      : this.squareId = model?.squareId,
        this.squareName = model?.squareName ?? "",
        this.squareImgUrl = model?.squareImgUrl,
        this.aiPlayerId = aiPlayerId;

  UserSquareData.fromSquare(SquareModel? model)
      : this.squareId = model?.squareId,
        this.squareName = model?.squareName ?? "",
        this.squareImgUrl = model?.squareImgUrl;

  @override
  String toString() {
    return "UserSquareData { squareId: $squareId, squareName: $squareName, squareImgUrl: $squareImgUrl, aiPlayerId: $aiPlayerId, tempSquareImgData: ${tempSquareImgData?.length} }";
  }
}