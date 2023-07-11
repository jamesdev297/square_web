import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';

import 'pick_emoticon_grid.dart';

class DesktopEmoticonView extends StatelessWidget {

  final ChangeKeyboardTypeBloc changeKeyboardTypeBloc;
  const DesktopEmoticonView({Key? key, required this.changeKeyboardTypeBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangeKeyboardTypeBloc, ChangeKeyboardTypeState>(
      bloc: changeKeyboardTypeBloc,
      builder: (context, changeKeyboardTypeState) {

        bool isMobile = screenWidthNotifier.value < maxWidthMobile;

        if((changeKeyboardTypeState is EmoticonTypeState) && !isMobile) {
          return Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: Zeplin.size(19), right: Zeplin.size(110)),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.0),
                    border: Border.all(color: CustomColor.veryLightGrey)
                  ),
                  height: Zeplin.size(490),
                  width: Zeplin.size(680),
                  child:  ClipRRect(
                      borderRadius: BorderRadius.circular(13.0),
                      child:PickEmoticonGrid(false)
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
