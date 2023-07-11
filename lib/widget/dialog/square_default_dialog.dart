import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/main.dart';
import 'package:square_web/widget/dialog/square_dialog_template.dart';

enum UniqueDialogKey { restart, expiredToken, squareLeftMember, sendVerifyEmail }

class SquareDefaultDialog extends StatefulWidget {
  static Set<UniqueDialogKey> uniqueDialogKeys = {};
  final String? title;
  final String? description;
  final Widget? content;
  final String? button1Text;
  final VoidCallback? button1Action;
  final String? button2Text;
  final VoidCallback? button2Action;
  final Widget? customButtonPack;
  final String? extraDescription;
  final BuildContext? context;
  final bool? showShadow;
  final double? width;
  final bool showDim = true;
  final EdgeInsets? padding;
  final bool? onlyTitle;
  final Widget? toastMessage;

  SquareDefaultDialog({
    this.title,
    this.description,
    this.content,
    this.button1Text,
    this.button1Action,
    this.button2Text,
    this.button2Action,
    this.customButtonPack,
    this.context,
    this.showShadow,
    this.extraDescription,
    this.width,
    this.padding,
    this.onlyTitle,
    this.toastMessage
  });

  @override
  State<StatefulWidget> createState() => _SquareDefaultDialogState();

  static void showRestartDialog(String description) {
    if (uniqueDialogKeys.contains(UniqueDialogKey.restart)) return;
    uniqueDialogKeys.add(UniqueDialogKey.restart);

    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) => SquareDefaultDialog(
              title: L10n.common_25_error,
              description: description,
              button1Text: L10n.common_26_restart,
              button1Action: () {
                uniqueDialogKeys.remove(UniqueDialogKey.restart);
                proxyNavigation("/splash");
                Navigator.of(context).pop();
              },
              context: context,
            ));
  }

  static void showSquareDialog({
    String? title,
    Widget? content,
    String? description,
    String? button1Text,
    VoidCallback? button1Action,
    String? button2Text,
    VoidCallback? button2Action,
    Widget? customButtonPack,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool showBarrierColor = true,
    bool showShadow = true,
    String? extraDescription,
    double? width,
    EdgeInsets? padding,
    bool? isButton1TextWhite,
    UniqueDialogKey? uniqueDialogKey,
    Widget? toastMessage
  }) {
    if (uniqueDialogKey != null) {
      if (uniqueDialogKeys.contains(uniqueDialogKey)) return;

      uniqueDialogKeys.add(uniqueDialogKey);
    }
    showDialog(
      barrierDismissible: barrierDismissible,
      barrierColor: showBarrierColor ? (barrierColor ?? Colors.black.withOpacity(0.4)) : null,
      context: navigatorKey.currentState!.overlay!.context,
      builder: (context) => SquareDefaultDialog(
        title: title,
        content: content,
        description: description,
        extraDescription: extraDescription,
        button1Text: button1Text,
        button2Text: button2Text,
        button1Action: button1Action ?? SquareDefaultDialog.closeDialog(uniqueDialogKey: uniqueDialogKey),
        button2Action: button2Action,
        customButtonPack: customButtonPack,
        showShadow: showShadow,
        context: context,
        width: width,
        padding: padding,
        onlyTitle: title != null && content == null && description == null && extraDescription == null,
        toastMessage: toastMessage
      ));
  }

  static VoidCallback closeDialog({UniqueDialogKey? uniqueDialogKey}) => () {
      LogWidget.debug("dialog closed!!");
      Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
        if(uniqueDialogKey != null)
          uniqueDialogKeys.remove(uniqueDialogKey);
      };
}

class _SquareDefaultDialogState extends State<SquareDefaultDialog>
    with SquareDialogTemplate, SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    // animation 형태
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> _animation = CurvedAnimation(
      parent: _animationController,
      curve: Cubic(0.11, 0.46, 0.15, 1.3),
    );

    return ScaleTransition(
      scale: _animation,
      child: Stack(
        children: [
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            elevation: 0.0,
            backgroundColor: widget.showDim ? Colors.black.withOpacity(0.4) : Colors.transparent,
            insetPadding: EdgeInsets.only(top: Zeplin.size(40)),
            child: SquareDialogTemplate.dialogContent(
              title: widget.title,
              content: widget.content,
              description: widget.description,
              extraDescription: widget.extraDescription,
              button1Text: widget.button1Text,
              button1Action: widget.button1Action,
              button2Text: widget.button2Text,
              button2Action: widget.button2Action,
              customButtonPack: widget.customButtonPack,
              showShadow: widget.showShadow,
              width: widget.width,
              padding: widget.padding,
              onlyTitle: widget.onlyTitle,
            ),
          ),

          if(widget.toastMessage != null)
            widget.toastMessage!
        ],
      ),
    );
  }
}
