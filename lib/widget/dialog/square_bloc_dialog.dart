import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/square_dialog_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/main.dart';

import 'square_dialog/square_dialog.dart';


class SquareBlocDialog extends StatelessWidget {
  final SquareDialogBloc? squareDialogBloc;
  final BuildContext? context;

  SquareBlocDialog({this.squareDialogBloc, this.context});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(60)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: BlocBuilder<SquareDialogBloc, SquareDialogState>(
        bloc: squareDialogBloc,
        builder: (context, state) {

          return SquareDefaultDialogWidget();

        },
      )
    );
  }

  static void showSquareDialog({
    bool? isShowEventButton,
    SquareDialogBloc? squareDialogBloc,
    bool barrierDismissible = false,
    Color? barrierColor,}) {
    showDialog(
        useSafeArea: false,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) =>
            Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                SquareBlocDialog(
                  squareDialogBloc: squareDialogBloc,
                  context: context,
                ),
              ],
            ),);
  }

  static VoidCallback get closeDialog => () {
    Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
  };
}



