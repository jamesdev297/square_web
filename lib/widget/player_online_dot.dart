import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/service/contact_manager.dart';

class PlayerOnlineDot extends StatelessWidget {
  final String playerId;
  final double size;
  final bool isShow;

  const PlayerOnlineDot(
    this.playerId, {
      this.size = 20,
      this.isShow = true,
      Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: ContactManager().onlinePlayerStatusMap,
      builder: (context, Map<String, bool> value, widget) {
        if(value[playerId] == true)
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: CustomColor.dartMint,
                shape: BoxShape.circle
            ),
          );

        return Container();
      },
    );
  }
}