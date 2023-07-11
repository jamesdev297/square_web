import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';

class SendFeedbackPageTopMenu extends StatefulWidget {
  final StreamController<Map<String, dynamic>> checkStream;
  final Function rootShowPage;
  final Function showPage;
  final int pageIndex;

  const SendFeedbackPageTopMenu({
    Key? key,
    required this.checkStream,
    required this.showPage,
    required this.rootShowPage,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<SendFeedbackPageTopMenu> createState() => _SendFeedbackPageTopMenuState();
}


class _SendFeedbackPageTopMenuState extends State<SendFeedbackPageTopMenu> {

  int lastSecondPageIndex = 1;
  bool lastSuggestSubmitActive = false;
  bool lastReportSubmitActive = false;

  Widget _buildFirstMenu() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(child: Icon46(Assets.img.ico_46_arrow_bk),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.rootShowPage(0);
                  // HomeNavigator.pop();
                },
              ),
            )),
        Align(
            alignment: Alignment.topCenter,
            child: Text(L10n.feedback_01_send_feedback,
                style: TextStyle(color: CustomColor.darkGrey,
                    fontSize: Zeplin.size(34),
                    fontWeight: FontWeight.w500))
        ),
      ],
    );
  }

  Widget _buildSecondMenu() {
    if(lastSecondPageIndex == 2) {
      return _buildThirdMenu();
    }

    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(child: Icon46(Assets.img.ico_46_arrow_bk),
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Completer<bool> checkCompleter = Completer();
                  widget.checkStream.add({
                    "name" : "report",
                    "result" : checkCompleter
                  });
                  if(await checkCompleter.future == true) {
                    SquareDefaultDialog.showSquareDialog(
                        title: L10n.feedback_01_discard,
                        content: Text(L10n.popup_12_feedback_leave
                            , style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                            , textAlign: TextAlign.center),
                        button1Text: L10n.common_03_cancel,
                        button2Text: L10n.common_02_confirm,
                        button2Action: () {
                          SquareDefaultDialog.closeDialog().call();
                          widget.showPage(0);
                          // HomeNavigator.pop();
                          lastReportSubmitActive = false;
                        }
                    );
                  } else {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                    lastReportSubmitActive = false;
                  }
                },
              ),
            )),
        Align(
            alignment: Alignment.topCenter,
            child: Text(L10n.feedback_01_report_problem,
                style: TextStyle(color: CustomColor.darkGrey,
                    fontSize: Zeplin.size(34),
                    fontWeight: FontWeight.w500))
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: Zeplin.size(6)),
            child: SizedBox(
              height: Zeplin.size(34),
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.checkStream.add({
                        "name" : "report-submit",
                      });
                    },
                    child: StreamBuilder<Map<String, dynamic>>(
                        stream: widget.checkStream.stream,
                        builder: (context, snapshot) {
                          bool isActive = lastReportSubmitActive;
                          if(snapshot.hasData) {
                            if(snapshot.data != null) {
                              if(snapshot.data!["name"] == "report-isActiveSubmit") {
                                isActive = snapshot.data!["value"];
                                lastReportSubmitActive = isActive;
                              }
                            }
                          }
                          return Text(L10n.feedback_01_submit,
                              style: TextStyle(fontSize: Zeplin.size(26),
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? CustomColor.azureBlue : CustomColor.taupeGray));
                        }),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdMenu() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(child: Icon46(Assets.img.ico_46_arrow_bk),
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Completer<bool> checkCompleter = Completer();
                  widget.checkStream.add({
                    "name" : "suggest",
                    "result" : checkCompleter
                  });
                  if(await checkCompleter.future == true) {
                    SquareDefaultDialog.showSquareDialog(
                        title: L10n.feedback_01_discard,
                        content: Text(L10n.popup_12_feedback_leave
                            , style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                            , textAlign: TextAlign.center),
                        button1Text: L10n.common_03_cancel,
                        button2Text: L10n.common_02_confirm,
                        button2Action: () {
                          SquareDefaultDialog.closeDialog().call();
                          widget.showPage(0);
                          // HomeNavigator.pop();
                          lastSuggestSubmitActive = false;
                        }
                    );
                  } else {
                    widget.showPage(0);
                    // HomeNavigator.pop();
                    lastSuggestSubmitActive = false;
                  }
                },
              ),
            )),
        Align(
            alignment: Alignment.topCenter,
            child:  Text(L10n.feedback_01_suggest,
                      style:
                      TextStyle(
                        color: CustomColor.darkGrey,
                        fontSize: Zeplin.size(34),
                        fontWeight: FontWeight.w500)
            )),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: Zeplin.size(6)),
            child: SizedBox(
              height: Zeplin.size(34),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.checkStream.add({
                        "name" : "suggest-submit",
                      });
                    },
                    child: StreamBuilder<Map<String, dynamic>>(
                      stream: widget.checkStream.stream,
                      builder: (context, snapshot) {
                        bool isActive = lastSuggestSubmitActive;
                        if(snapshot.hasData) {
                          if(snapshot.data != null) {
                            if(snapshot.data!["name"] == "suggest-isActiveSubmit") {
                              isActive = snapshot.data!["value"];
                              lastSuggestSubmitActive = isActive;
                            }
                          }
                        }
                        return Text(L10n.feedback_01_submit,
                            style: TextStyle(fontSize: Zeplin.size(26),
                                fontWeight: FontWeight.w500,
                                color: isActive ? CustomColor.azureBlue : CustomColor.taupeGray));
                      }),
                    )),
            ),
          ),
        ),
      ],
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lastSuggestSubmitActive = false;
  }


  Widget _buildNoTransition() {
    if(widget.pageIndex == 0) {
      return _buildFirstMenu();
    }else if(widget.pageIndex == 1) {
      return _buildSecondMenu();
    }else{
      return _buildThirdMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.pageIndex == 1 || widget.pageIndex == 2) {
      lastSecondPageIndex = widget.pageIndex;
    }

    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: Padding(
          padding: EdgeInsets.only(
              top: Zeplin.size(32),
              left: Zeplin.size(16),
              right: Zeplin.size(16)),
          child: MeModel().showTransition ? AnimatedCrossFade(
            duration: Duration(milliseconds: 100),
            crossFadeState: widget.pageIndex >= 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _buildFirstMenu(),
            secondChild: _buildSecondMenu(),
          ) : _buildNoTransition()
      ),
    );
  }
}