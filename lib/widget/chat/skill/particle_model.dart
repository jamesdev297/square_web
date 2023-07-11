


import 'package:flutter/material.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/simple_animations.dart';

class ParticleModel {
  Duration? generatedTime;
  late Animatable tween;
  ChatSkillImageModel? spriteModel;
  Offset startPosition;
  Offset? endPosition;
  double? dx;
  double? dy;
  double? prevDx;
  double? prevDy;
  Paint paint = Paint();
  final ratio = 0.7;
  AnimationProgress? animationProgress;

  ParticleModel({this.spriteModel, this.generatedTime, required this.startPosition, this.endPosition});

  void draw(double progress, Size size, Canvas canvas, List<ParticleModel> effectParticles, Duration currentTime) {}
  void subDraw(double progress, Size size, Canvas canvas, Duration currentTime) {}
}