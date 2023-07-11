

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/simple_animations.dart';
import 'package:square_web/widget/chat/skill/particle_model.dart';

class RocketParticleModel extends ParticleModel {

  RocketParticleModel(
      {required ChatSkillImageModel spriteModel,
        required Offset startPosition,
        required Offset endPosition,
        required Duration time,
      })
      : super(spriteModel: spriteModel, startPosition: startPosition, endPosition: endPosition, generatedTime: time){
    restart();
  }

  ui.Image? get spriteImage => spriteModel!.image;

  @override
  Offset getPosition(double progress, Size size) {
    final animation = tween.transform(progress);
    if (prevDx != null) {
      dx = animation["x"] - prevDx;
      dy = animation["y"] - prevDy;
    }
    prevDx = animation["x"];
    prevDy = animation["y"];
    return Offset(
        animation["x"], animation["y"]);
  }

  @override
  void restart() {
    final duration = Duration(milliseconds: ChatSkill.rocketSkillDuration);

    final randomDivideX = 1.5 + random.nextDouble();
    final randomDivideY = 2 + random.nextDouble();

    final midPosition = Offset(
        (startPosition.dx + endPosition!.dx) / randomDivideX,
        (startPosition.dy + endPosition!.dy) / randomDivideY);

    final durationmid = Duration(milliseconds: ChatSkill.rocketSkillMidDuration);
    tween = MultiTrackTween([
      Track("x").add(
          durationmid, Tween(begin: startPosition.dx, end: midPosition.dx),
          curve: Curves.ease).add(
          durationmid, Tween(begin: midPosition.dx, end: endPosition!.dx),
          curve: Curves.easeInCubic),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition!.dy),
          curve: Curves.easeIn
      ),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: generatedTime!);
  }


  @override
  void draw(double progress, Size size, Canvas canvas, List<ParticleModel> effectParticles, Duration currentTime) {
    if(spriteImage == null)
      return ;
    if (progress < 0.1)
      return ;


    final position = getPosition(progress, size);

    if (dx != null) {
      canvas.save();
      final angle = atan2(dy!, dx!) + 3.14 / 2;
      final width = spriteImage!.width * ratio / 2;
      final height = spriteImage!.height * ratio/ 2;
      final double r = sqrt(width * width + height * height) / 2;
      final alpha = atan(height / width);
      final beta = alpha + angle;
      final shiftY = r * sin(beta);
      final shiftX = r * cos(beta);

      canvas.translate(position.dx - width/2, position.dy - height - shiftY);
      canvas.rotate(angle);

      canvas.scale(ratio);
      canvas.drawImage(spriteImage!, Offset.zero, paint);

      canvas.restore();
      effectParticles.add(RocketSubParticleModel(
          colorType: random.nextInt(4),
          time: currentTime,
          startPosition: Offset(position.dx + 40 + random.nextDouble() * 30,
              position.dy - 20 + random.nextDouble() * 60),
          radius: 10 + random.nextDouble() * 20));
    }
  }
}


class FriendRocketParticleModel extends ParticleModel {
  FriendRocketParticleModel(
      {required ChatSkillImageModel spriteModel,
        required Offset startPosition,
        required Offset endPosition,
        required Duration time,
      })
      : super(spriteModel: spriteModel, startPosition: startPosition, endPosition: endPosition, generatedTime: time){
    restart();
  }

  ui.Image? get spriteImage => spriteModel!.image;

  @override
  Offset getPosition(double progress, Size size) {
    final animation = tween.transform(progress);
    if (prevDx != null) {
      dx = animation["x"] - prevDx;
      dy = animation["y"] - prevDy;
    }
    prevDx = animation["x"];
    prevDy = animation["y"];
    return Offset(
        animation["x"], animation["y"]);
  }

  @override
  void restart() {
    final duration = Duration(milliseconds: ChatSkill.rocketSkillDuration);

    final randomDivideX = 1 + random.nextDouble() * 3;
    final randomDivideY = 2 + random.nextDouble();

    final midPosition = Offset(
        (startPosition.dx + endPosition!.dx) / randomDivideX,
        (startPosition.dy + endPosition!.dy) / randomDivideY);

    final durationmid = Duration(milliseconds: ChatSkill.rocketSkillMidDuration);
    tween = MultiTrackTween([
      Track("x").add(
          durationmid, Tween(begin: startPosition.dx, end: midPosition.dx),
          curve: Curves.ease).add(
          durationmid, Tween(begin: midPosition.dx, end: endPosition!.dx),
          curve: Curves.easeInCubic),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition!.dy),
          curve: Curves.easeIn
      ),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: generatedTime!);
  }


  @override
  void draw(double progress, Size size, Canvas canvas, List<ParticleModel> effectParticles, Duration currentTime) {
    if(spriteImage == null)
      return ;

    final position = getPosition(progress, size);

    if (dx != null) {
      canvas.save();
      final angle = atan2(dy!, dx!) + 3.14 / 2;
      final width = spriteImage!.width * ratio / 2;
      final height = spriteImage!.height * ratio/ 2;
      final double r = sqrt(width * width + height * height) / 2;
      final alpha = atan(height / width);
      final beta = alpha + angle;
      final shiftY = r * sin(beta);
      final shiftX = r * cos(beta);

      canvas.translate(position.dx - width/2, position.dy - height - shiftY);
      canvas.rotate(angle);

      // canvas.scale(-ratio, ratio);
      canvas.scale(ratio);
      canvas.drawImage(spriteImage!, Offset.zero, paint);
      canvas.restore();

      effectParticles.add(RocketSubParticleModel(
          colorType: random.nextInt(4),
          time: currentTime,
          startPosition: Offset(position.dx + random.nextDouble() * 30,
              position.dy - 20 + random.nextDouble() * 60),
          radius: 10 + random.nextDouble() * 20));
    }
  }
}



class RocketSubParticleModel extends ParticleModel {
  double? radius;
  Color? color;
  int? layer;
  int? colorType;
  Duration? time;

  RocketSubParticleModel(
      {
        this.radius,
        this.color,
        this.layer,
        this.colorType,
        required Offset startPosition,
        required Duration time,
      })
      :super(
      startPosition: startPosition,
      generatedTime: time
  ) {
    restart();
  }

  @override
  Offset getPosition(double progress, Size size){
    return Offset(startPosition.dx, startPosition.dy - progress*50);
  }

  Color? getColor(double progress){
    return tween.transform(progress);
  }

  @override
  void restart() {
    final duration = Duration(milliseconds: 500 + random.nextInt(500));

    tween = TweenSequence(
      <TweenSequenceItem<Color?>>[
        TweenSequenceItem<Color?>(
          tween:  ColorTween(
              begin: Color.fromRGBO(255, 239, 112, 1),
              end: Color.fromRGBO(255, 146, 21, 1)
          ),
          weight: 20.0,
        ),
        TweenSequenceItem<Color?>(
          tween:  ColorTween(
              begin: Color.fromRGBO(255, 146, 21, 1),
              end: Color.fromRGBO(255, 45, 39, 1)
          ),
          weight: 20.0,
        ),
        TweenSequenceItem<Color?>(
          tween:  ColorTween(
              begin: Color.fromRGBO(255, 45, 39, 1),
              end: Color.fromRGBO(184, 52, 52, 1)
          ),
          weight: 20.0,
        ),
        TweenSequenceItem<Color?>(
          tween:  ColorTween(
              begin: Color.fromRGBO(184, 52, 52, 1),
              end: Color.fromRGBO(101, 67, 65, 1)
          ),
          weight: 20.0,
        ),
        TweenSequenceItem<Color?>(
          tween:  ColorTween(
              begin: Color.fromRGBO(101, 67, 65, 1),
              end: Color.fromRGBO(111, 94, 92, 1)
          ),
          weight: 20.0,
        ),
      ],
    );
    animationProgress = AnimationProgress(duration: duration, startTime: generatedTime!);
  }

  @override
  void subDraw(double progress, Size size, Canvas canvas, Duration currentTime) {
    final position = getPosition(progress, size);
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(1.5-progress*1.5);
    canvas.drawCircle(Offset.zero, 20, paint..color = getColor(progress)!);
    canvas.restore();
  }

}