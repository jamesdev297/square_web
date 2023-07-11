import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:square_web/config.dart';
import 'package:square_web/constants/chain_net_type.dart';

class ImageUtil {

  static Future<Uint8List?> resizeImageWeb(Uint8List image, String mimeType) async{
    int width, height;
    String jpg64 = base64Encode(image);
    html.ImageElement myImageElement = html.ImageElement();
    myImageElement.src = 'data:$mimeType;base64,$jpg64';

    await myImageElement.onLoad.first; // allow time for browser to render

    if (myImageElement.width! > myImageElement.height!) {
      width = 720;
      height = (width * myImageElement.height! / myImageElement.width!).round();
    } else {
      height = 720;
      width = (height * myImageElement.width! / myImageElement.height!).round();
    }

    html.CanvasElement myCanvas = html.CanvasElement(width: width, height: height);
    html.CanvasRenderingContext2D ctx = myCanvas.context2D;

    ctx.drawImageScaled(myImageElement, 0, 0, width, height);

    return getBlobData(await myCanvas.toBlob(mimeType));
  }

  static Future<Uint8List> getBlobData(html.Blob blob) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    reader.onLoad.listen((_) => completer.complete(reader.result as Uint8List));
    return completer.future;
  }

  static double getSizeMB(int bytes) {
    final kb = bytes / 1024;
    return kb / 1024;
  }

  static String? getNftImgUrl(ChainNetType? chain, String? rawImgUrl, String? contractAddress, String? tokenId, int? modTime) {

    if(chain == null || rawImgUrl == null || contractAddress == null || tokenId == null || modTime == null)
      return rawImgUrl;

    if(modTime != null && modTime < DateTime.now().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch) {
      return '${Config.cdnAddress}/nft/${chain.name}/$contractAddress/$tokenId';
    }

    return rawImgUrl;

  }

  static String? convertRawImgUrl(String? rawImgUrl) {

    if(Config.ipfsServiceAddr.value == null) {
      return rawImgUrl;
    }

    if(rawImgUrl?.startsWith("ipfs://ipfs/") == true) {
      return rawImgUrl?.replaceFirst("ipfs://ipfs/", Config.ipfsServiceAddr.value!);
    } else if(rawImgUrl?.startsWith("ipfs://") == true) {
      return rawImgUrl?.replaceFirst("ipfs://", Config.ipfsServiceAddr.value!);
    }

    return rawImgUrl;
  }

  static bool hasIpfsStartWidth(String? rawImgUrl) {
    if (rawImgUrl == null)
      return false;

    return rawImgUrl.startsWith("ipfs://ipfs/") || rawImgUrl.startsWith("ipfs://");
  }

}