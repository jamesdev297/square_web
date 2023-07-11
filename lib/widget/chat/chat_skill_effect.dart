
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/simple_animations.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/chat/skill/particle_model.dart';
import 'package:square_web/widget/chat/skill/rocket_particle_model.dart';

class ChatSkillEffect extends StatefulWidget {
  @override
  State<ChatSkillEffect> createState() => _ChatSkillEffectState();
}

class _ChatSkillEffectState extends State<ChatSkillEffect> with TickerProviderStateMixin {
  late StreamSubscription streamSubscription;
  List<ParticleModel> skillParticleModels = [];

  late Offset chatEffectOffset;
  ChatSkillImageModel rocketModel = ChatSkillImageModel(path: Assets.img.square_rocket);
  GlobalKey<RenderingState> renderStateKey = GlobalKey();
  List<ParticleModel> removeParticles = [];
  List<ParticleModel> effectParticles = [];
  List<ChatSkillModel> waitParticles = [];

  Timer? renderTimer;

  late double chatPageWidth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox;
      chatEffectOffset = box.localToGlobal(Offset.zero);
      renderStateKey.currentState?.stopRender();
    });

    streamSubscription = ChatMessageManager().chatSkillStreamController.stream.listen((event) async {

      renderTimer?.cancel();
      if(renderStateKey.currentState?.ticker?.isActive == false) {
        renderStateKey.currentState?.startRender();
      }
      renderTimer = Timer(Duration(seconds: 3), () {
        renderStateKey.currentState?.stopRender();
      });

      if(rocketModel.image == null) {
        await rocketModel.loadImage();
      }
      waitParticles.add(event);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    renderStateKey.currentState?.stopRender();
    renderTimer?.cancel();
    streamSubscription.cancel();
    rocketModel.disposeImage();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        chatPageWidth = constraints.maxWidth;
        return Rendering(
          key: renderStateKey,
          startTime: Duration(seconds: 3000),
          onTick: _simulateParticles,
          builder: (context, time) {
            return CustomPaint(
              painter: ParticlePainter(
                  skillParticleModels, effectParticles, time),
            );
          },
        );
      }
    );
  }

  void _simulateParticles(Duration time) {

    waitParticles.forEach((element) {
      final fullDuration = Duration(milliseconds: ChatSkill.rocketSkillDuration);
      final animationController = AnimationController(duration: fullDuration, vsync: this)..forward();
      final endXOffset = chatPageWidth * 0.75 * random.nextDouble() + 5 + random.nextDouble() * 200;
      // final endXOffset =  5 + random.nextDouble() * 700;
      skillParticleModels.add(RocketParticleModel(
          time: time,
          spriteModel: rocketModel,
          startPosition : Offset(element.startOffset.dx - chatEffectOffset.dx + 50, element.startOffset.dy - chatEffectOffset.dy + 50),
          endPosition : Offset(element.startOffset.dx - chatEffectOffset.dx - endXOffset, element.startOffset.dy - chatEffectOffset.dy - DeviceUtil.screenHeight - 100)
      ));
    });
    waitParticles = [];

    skillParticleModels.forEach((particle) {
      if(particle.animationProgress?.progress(time) == 1.0) {
        removeParticles.add(particle);
      }
    });

    removeParticles.forEach((removeParticle) {
      skillParticleModels.remove(removeParticle);
    });
    removeParticles = [];

    effectParticles.forEach((effectParticle) {
      skillParticleModels.add(effectParticle);
    });
    effectParticles= [];

    return;
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particleModels;
  List<ParticleModel> effectParticles;
  Duration time;

  ParticlePainter(this.particleModels, this.effectParticles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    particleModels.forEach((particle) {
      if(particle.animationProgress != null) {
        var progress = particle.animationProgress!.progress(time);
        particle.subDraw(progress, size, canvas, time);
      }
    });
    particleModels.forEach((particle) {
      if(particle.animationProgress != null) {
        var progress = particle.animationProgress!.progress(time);
        particle.draw(progress, size, canvas, effectParticles, time);
      } else {
        particle.draw(0.0, size, canvas, effectParticles, time);
      }
    });
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

