import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';

import 'contact_model.dart';

class SquareContact extends ContactModel {
  SquareContact():super(playerId: squarePlayerId, nickname: squarePlayerId, profileImgAsset: Assets.img.image_square);
}