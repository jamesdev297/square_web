import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/custom_status_code.dart';
import 'package:square_web/constants/ui_theme.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/copy_util.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/widget/code_highligher/highlight_view.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/markdown/widget.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';
import 'package:markdown/markdown.dart' as md;


class TextMessage extends StatelessWidget {
  final MessageModel messageModel;
  final Color messageColor;
  final HomeWidget? rootWidget;
  final String? typingText;

  static final popUpItemHeight = Zeplin.size(90);
  static final popUpItemWidth = Zeplin.size(255);
  static final padding = 4;

  TextMessage({Key? key, required this.messageModel, required this.messageColor, required this.rootWidget, this.typingText}) : super(key: key);

  late List<SquarePopUpItem> squarePopUpItems;
  late GlobalKey globalKey;
  String? selectedText;
  double minWidth = 0;

  void _onPointerDown(BuildContext context, PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
      showToolTip(context, event.position);
    }
  }

  void showToolTip(BuildContext context, Offset pointerOffset) {
    SquarePopUpMenu.show(buildContext: context, rootWidgetKey: globalKey, squarePopUpItems: squarePopUpItems, getPopUpOffset: (Offset offset, Size size, Size popUpSize) {

          double dx = pointerOffset.dx;
          double dy = pointerOffset.dy;

          if(pointerOffset.dx + popUpSize.width > DeviceUtil.screenWidth) {
            dx = pointerOffset.dx - popUpSize.width;
          }

          if(pointerOffset.dy + popUpSize.height > DeviceUtil.screenHeight) {
            dy = pointerOffset.dy - popUpSize.height;
          }

          return GetPopUpOffsetCallbackResponse(Offset(dx, dy), isSlideUp: false);
        },
        popUpSize: Size(TextMessage.popUpItemWidth, TextMessage.popUpItemHeight));
  }


  Widget _buildText(bool isSelected) {
    if(messageModel.messageType == MessageType.markdown) {
      return MarkdownBody(
        softLineBreak: true,
        shrinkWrap: true,
        selectable: isSelected,
        data: typingText!,
        onTapLink: (text, url, title){
          launchUrl(Uri.parse(url!));
        },
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
        ),
        imageBuilder: (Uri uri, String? title, String? alt) {
          if (uri.scheme == 'http' || uri.scheme == 'https') {
            return Image.network(
                uri.toString(), errorBuilder: (context, _, __) {
              return Text("$alt");
            });
          }
          return Text("$alt");
        },
        builders: {
          'code': CodeElementBuilder(isSelected),
        },
      );
    } else if(messageModel.messageType == MessageType.link || (messageModel.messageBody?.contains('http://') == true) || (messageModel.messageBody?.contains('https://') == true)) {
      return LinkText(
        messageModel.messageBody!,
        textStyle: chatTextStyle,
        linkStyle: chatLinkTextStyle,
      );
    }
    return Text("${messageModel.messageBody}", style: chatTextStyle);
  }

  @override
  Widget build(BuildContext context) {
    globalKey = ChatMessageManager().getGlobalKey(messageModel.messageId);

    bool hasReport = messageModel is SquareChatMsgModel && !MeModel().isMe(messageModel.playerId) && messageModel.messageType != MessageType.markdown;
    squarePopUpItems = [
      SquarePopUpItem(
          assetPath: Assets.img.ico_36_copy_bk,
          name: L10n.common_51_copy,
          onTap: () => _copyText(context)),
      if(hasReport)
        SquarePopUpItem(
            assetPath: Assets.img.ico_36_report_bk,
            name: L10n.square_01_25_report,
            onTap: () async {
              SquareChatMsgModel squareChatMsgModel = messageModel as SquareChatMsgModel;
              if(await SquareManager().checkReportedSquareMessage(squareChatMsgModel) == CustomStatus.ALREADY_REPORTED_MESSAGE) {
                SquareDefaultDialog.showSquareDialog(
                  title: L10n.square_01_28_reported_dialog_title,
                  description: L10n.square_01_29_reported_dialog_context,
                  button1Text: L10n.common_02_confirm,
                );
                return;
              }

              SquareDefaultDialog.showSquareDialog(
                  title: L10n.square_01_26_report_dialog_title,
                  description: L10n.square_01_27_report_dialog_context,
                  button1Text: L10n.common_03_cancel,
                  button1Action: SquareDefaultDialog.closeDialog(),
                  button2Text: L10n.common_02_confirm,
                  button2Action: () async {
                    int status = await SquareManager().reportSquareMessage(squareChatMsgModel);
                    SquareDefaultDialog.closeDialog().call();

                    switch (status) {
                      case HttpStatus.badRequest:
                        LogWidget.info("can't report your message");
                        return;
                      case CustomStatus.ALREADY_REPORTED_MESSAGE:
                        SquareDefaultDialog.showSquareDialog(
                          title: L10n.square_01_28_reported_dialog_title,
                          description: L10n.square_01_29_reported_dialog_context,
                          button1Text: L10n.common_02_confirm,
                        );
                        break;
                      case CustomStatus.EXCEED_ONE_DAY_REPORT_LIMIT:
                        SquareDefaultDialog.showSquareDialog(
                            title: L10n.square_01_33_report_limit_dialog_title,
                            description: L10n.square_01_34_report_limit_dialog_context,
                            button1Text: L10n.common_02_confirm);
                        break;
                      case HttpStatus.ok:
                        ToastOverlay.show(buildContext: context, text: L10n.square_01_38_reported, rootWidget: rootWidget!);
                        break;
                    }
                  });
            }),
    ];

    if(messageModel.messageType == MessageType.markdown) {
      minWidth = Zeplin.size(70);
    }

    return Listener(
      key: globalKey,
      onPointerDown: (event) => _onPointerDown(context, event),
      child: GestureDetector(
        onLongPressStart: (longPress) => showToolTip(context, longPress.globalPosition),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(26), vertical: Zeplin.size(19)),
          constraints: BoxConstraints(minHeight: Zeplin.size(60)),
          decoration: BoxDecoration(
            color: messageColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Zeplin.size(900), minWidth: minWidth, minHeight: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: _buildSelectedArea()
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedArea() {
    if(defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux)
      return ValueListenableBuilder<bool>(
          valueListenable: SquareTransition.skipToBuildSelectionArea,
          builder: (BuildContext context, bool value, Widget? child) {
            if(value == true)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildText(false),
                ],
              );

            return SelectionArea(child: _buildText(true), onSelectionChanged: (contents) {
              selectedText = contents?.plainText;
            });
          });

    return _buildText(false);
  }

  void _copyText(BuildContext context) {
    String? msg = selectedText?.isNotEmpty == true ? selectedText : messageModel.messageBody;

    if(msg != null && msg.isNotEmpty) {
      CopyUtil.copyText(msg, () {
        ToastOverlay.show(buildContext: context, rootWidget: rootWidget!);
      });
    }
  }
}


class CodeElementBuilder extends MarkdownElementBuilder {

  final bool isSelected;

  CodeElementBuilder(this.isSelected);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    return SizedBox(
      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
      child: HighlightView(
        element.textContent,
        language: language,
        theme: atomOneDarkTheme,
        padding: const EdgeInsets.all(8),
        isSelected: isSelected,
      ),
    );
  }
}
