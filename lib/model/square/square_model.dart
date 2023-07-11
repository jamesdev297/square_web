import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/string_util.dart';

enum AiChatSquareStatus { RUNNING, ENABLE, }


class SquareModel extends Equatable{
  late String squareId;
  late String contractAddress;
  late ChainNetType chainNetType;
  late SquareType squareType;
  String? description;
  String? squareName;
  String? subtitle;
  String? squareImgUrl;
  int? _memberCount;
  int? lastMsgTime;
  bool? joined;
  String? symbol;
  int? onlineNum;
  int? regTime;
  int? modTime;

  Color get bgColor {
    var random = Random(contractAddress.hashCode.abs());
    List<int> rgb = [255, paletteColor, random.nextInt(255 - paletteColor) + paletteColor];
    rgb.shuffle(random);
    return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 0.8);
  }
  Color get textColor => CustomColor.blueyGrey;

  String get name => squareName ?? smallerWallet(contractAddress);

  int get memberCount {
    _memberCount ??= SquareManager().globalSquareMap[squareId]!["members"].length;
    return _memberCount!;
  }

  static String smallerWallet(String contractAddress) {
    return StringUtil.smallerString(contractAddress);
  }

  SquareModel({
        required this.squareId,
        required this.contractAddress,
        required this.chainNetType,
        this.squareName,
        this.description,
        this.squareImgUrl,
        // this.graffitiCanvasImgUrl,
        this.onlineNum,
        this.squareType = SquareType.nft
      }) {
    //TODO 임시로 할당, 나중에 지워야함
    // this.graffitiCanvasImgUrl = '${Config.cdnAddress}/tiles/15/27938/12693.png';
  }

  @override
  String toString() {
    return 'SquareModel{squareId: $squareId, squareName: $squareName, type: $squareType, contractAddress: $contractAddress, chainNetType: $chainNetType, squareName: $squareName, squareImgUrl: $squareImgUrl, lastMsgTime: $lastMsgTime, onlineNum: $onlineNum, modTime: $modTime}';
  }

  SquareModel.fromByLink(String squareId, dynamic content) {
    this.squareId = squareId;
    contractAddress = content['contractAddress'];
    chainNetType = ChainNetType.values[content['blockchainNetType']]!;
    squareName = content['squareName'];
    description = content['description'];
    // memberCount = content['memberCount'];
    squareType = SquareType.values.byName(content['squareType']  ?? "nft");
    symbol = content['symbol'];
    regTime = content['regTime'];
    modTime = content['modTime'];

    squareImgUrl = content['squareImgUrl'];
  }

  SquareModel.fromMap(dynamic map) {
    squareId = map['squareId'];
    contractAddress = map['contractAddress'];
    chainNetType = ChainNetType.values[map['blockchainNetType']]!;
    squareName = map['squareName'];
    description = map['description'];
    subtitle = map['subtitle'];
    // memberCount = map['memberCount'];
    joined = map['joined'] == true;
    symbol = map['symbol'];
    description = map['description'];
    if(description != null) {
      description = description!.replaceAll("\\n", "\n");
    }

    squareType = SquareType.values.byName(map['squareType'] ?? "nft");

    squareImgUrl = map['squareImgUrl'];
    regTime = map['regTime'];
    modTime = map['modTime'];

  }

  static bool isAiChatSquare(String squareId) => squareId.startsWith(ChainNetType.ai.name + "-");
  static bool isUserChatSquare(String squareId) => squareId.startsWith(ChainNetType.user.name + "-");
  static bool hasAiMemberChatSquare(String squareId) => isAiChatSquare(squareId) || isUserChatSquare(squareId);

  static String? getAiPlayerId(String squareId) {
    return isAiChatSquare(squareId) ? squareId.split("-")[1] : null;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [squareId];
}
