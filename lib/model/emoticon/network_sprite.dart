import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/emoticon/emoticon_model.dart';
import 'package:square_web/util/http_resource_util.dart';


class NetworkSprite extends Sprite {
  NetworkSprite(Duration interval, List<SpriteFrame> frames, Point<num> size,
      Point<num> anchor)
      : super(interval, frames, size, anchor);

  static Future<SpriteSheetSpec> newSheetSpec(
      String metaDataPath, String emoticonPath) async {
    dynamic map = await HttpResourceUtil.downloadYaml(metaDataPath);

    int totalFrames = map["totalFrames"];
    int column = map["framesPerRow"];
    double width = map["width"] ?? EmoticonConfig.defaultEmoticonImageSize;
    double height = map["height"] ?? EmoticonConfig.defaultEmoticonImageSize;

    double cellSize = width / column;
    int row = (totalFrames / column).ceil();
    List<SpriteSheetSprite> sprites = [];

    for (int r = 0; r < row; r++) {
      for (int c = 0; c < column; c++) {
        if ((r * column + c) >= totalFrames) continue;
        sprites.add(newSprite(emoticonPath, cellSize, r, c));
      }
    }

    return SpriteSheetSpec(
        sprites,
        Duration(
            milliseconds:
                map['interval'] ?? EmoticonConfig.defaultEmoticonInterval),
        Point<num>(cellSize, cellSize));
  }

  static SpriteSheetSprite newSprite(
      String emoticonPath, double size, int row, int column) {
    return SpriteSheetSprite(
      emoticonPath,
      portion: SpriteSheetPortion(
          Point<num>(size * column, size * row), Point<num>(size, size)),
    );
  }

  static Future<Sprite?> load(EmoticonModel emoticonModel) async {
    // String? jsonStr = await getStringFromUrl(emoticonModel.metaDataPath);
    // if(jsonStr == null) return null;
    // final json = jsonDecode(jsonStr);
    final spec = await newSheetSpec(emoticonModel.metaDataPath,
        emoticonModel.path); // SpriteSheetSpec.fromJson(json)!;
    final frames = <SpriteFrame>[];


    ui.Image image = (await HttpResourceUtil.downloadImage(emoticonModel.imagePath))!;


    for (final spriteSpec in spec.sprites) {
      final portion = spriteSpec.portion ??
          SpriteSheetPortion(Point(0, 0), Point(image.width, image.height));
      bool flip = spriteSpec.flip ?? spec.flip ?? false;

      Point<num> offset = spriteSpec.translate ?? Point<num>(0, 0);
      if (spriteSpec.anchor != null) {
        Point<num> spriteAnchor = spriteSpec.anchor!;
        if (flip) {
          spriteAnchor = Point(spec.size.x - spec.anchor.x, spec.anchor.y) -
              Point(portion.size.x - spriteAnchor.x, spriteAnchor.y);
        } else {
          spriteAnchor = spec.anchor - spriteAnchor;
        }
        offset = offset + spriteAnchor;
      }

      frames.add(SpriteFrame(image,
          translate: offset,
          interval: spriteSpec.interval,
          portion: portion,
          flip: flip));
    }

    return Sprite(spec.interval, frames, spec.size, spec.anchor);
  }
}
