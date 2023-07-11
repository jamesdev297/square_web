import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/uris.dart';
import 'package:square_web/model/json_map.dart';
import 'package:square_web/model/squarepacket.dart';

import 'command.dart';

class IsContainsBannedWordCommand extends WsCommand {
  String sentence;

  IsContainsBannedWordCommand(this.sentence);

  @override
  String getUri() => Uris.common.isContainsBannedWord;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
        uri: getUri(),
        body: JsonMap({
          "sentence": "$sentence",
        }));
    return false;

    if(!await processRequest(packet)) {
      return false;
    }

    if(this.status == 200)
      return true;

    return false;
  }
}

class UploadNftImageCommand extends WsCommand {
  ChainNetType? chain;
  String url;
  String contract;
  String tokenId;

  UploadNftImageCommand(this.chain, this.url, this.contract, this.tokenId);

  @override
  String getUri() => Uris.common.uploadNftImage;

  @override
  Future<bool> execute() async {
    var packet = SquarePacket(
      uri: getUri(),
      body: JsonMap({
        "chain": chain?.name,
        "type": nft,
        "url": url,
        "contract": contract,
        "tokenId": tokenId,
      })
    );
    return true;

    if(!await processRequest(packet)) {
      return false;
    }

    if(this.status == 200)
      return true;

    return false;
  }
}
