import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/constants/chain_net_type.dart';
class PlayerNftModel {
  late String playerId;
  late String tokenId;
  late String contractAddress;
  late ChainNetType blockchainNetType;

  String? squareId;
  String? squareName;
  String? squareImgUrl;
  String? imgUrl;
  String? nftName;
  int? memberCount;
  bool? joined;

  int? regTime;
  int? nftRegTime;
  int? squareRegTime;
  int? squareModTime;

  SquareModel? squareModel;

  String get cursorId => "${blockchainNetType.name}-${contractAddress}-${tokenId}";

  PlayerNftModel.fromMap(dynamic map) {
    playerId = map["playerId"];
    tokenId = map["tokenId"];
    contractAddress = map["contractAddress"];
    blockchainNetType = ChainNetType.values[map["blockchainNetType"]]!;
    nftName = map["nftName"];

    squareId = map["squareId"];
    squareName = map["squareName"];
    memberCount = map["memberCount"];
    joined = map["joined"];

    nftRegTime = map["nftRegTime"];
    regTime = map["regTime"];
    squareRegTime = map["squareRegTime"];
    squareModTime = map["squareModTime"];

    imgUrl = map['imgUrl'];
    squareImgUrl = map["squareImgUrl"];


    squareModel = SquareModel(squareId: squareId!, squareImgUrl: squareImgUrl, squareName: squareName, chainNetType: blockchainNetType, contractAddress: contractAddress);
  }
}