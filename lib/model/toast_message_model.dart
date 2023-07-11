import 'package:flutter/material.dart';
import 'package:square_web/model/player_model.dart';

mixin ToastMessageModel {
  late Player sender;
  VoidCallback? onPressed;

  String? getMessage();
  String? get nickname {
    if(sender.nickname!.length > 16) {
      return sender.nickname!.substring(0, 16) + "...";
    }
    return sender.nickname;
  }
}

// class SkillToastMessageModel with ToastMessageModel {
//   FriendsSkillModel? skillModel;
//
//   SkillToastMessageModel({required Player sender, VoidCallback? onPressed, this.skillModel}) {
//     super.sender = sender;
//     super.onPressed = onPressed;
//
//   }
//
//   @override
//   String getMessage() {
//     return SkillManager().skillMap[skillModel!.skill.type]!.skillName! + " 스킬을 날렸어요!";
//   }
//
// }

class MessageToastMessageModel with ToastMessageModel {
  String? message;

  MessageToastMessageModel({required Player sender, VoidCallback? onPressed, this.message}) {
    super.sender = sender;
    super.onPressed = onPressed;
  }

  @override
  String? getMessage() {
    if(message!.length > 24) {
      return message!.substring(0, 24) + "...";
    }
    return message;
  }

}

class LikeKanToastMessageModel with ToastMessageModel {
  String? message;

  LikeKanToastMessageModel({VoidCallback? onPressed, this.message}) {
    super.onPressed = onPressed;
  }

  @override
  String? getMessage() {
    return message;
  }

}

class VerifyEmailToastMessageModel with ToastMessageModel {
  String? message;

  VerifyEmailToastMessageModel({VoidCallback? onPressed, this.message}) {
    super.onPressed = onPressed;
  }

  @override
  String? getMessage() {
    return message;
  }

}
