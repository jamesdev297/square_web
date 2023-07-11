import 'dart:async';

import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/page/more/user_feedback/report_problem_page.dart';
import 'package:square_web/page/more/user_feedback/send_feedback_page.dart';
import 'package:square_web/page/more/user_feedback/send_feedback_page_top_menu.dart';
import 'package:square_web/page/more/user_feedback/suggest_page.dart';

class SendFeedbackPageHome extends StatefulWidget with HomeWidget{
  final Function showPage;

  SendFeedbackPageHome({required this.showPage, Key? key}) : super(key: key);

  @override
  _SendFeedbackPageHomeState createState() => _SendFeedbackPageHomeState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "SendFeedbackPageHome";

  @override
  bool get isInternalImplement => true;
}

class _SendFeedbackPageHomeState extends State<SendFeedbackPageHome> {
  PreloadPageController pageController = PreloadPageController();
  int pageIndex = 0;

  late HomeWidget mainPage;
  late HomeWidget reportProblemPage;
  late HomeWidget suggestPage;

  StreamController<Map<String, dynamic>> checkStream = StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mainPage = SendFeedbackPage(showPage: showPage, rootShowPage: widget.showPage);
    reportProblemPage = ReportProblemPage(checkStream: checkStream, showPage: showPage);
    suggestPage = SuggestPage(checkStream: checkStream, showPage: showPage);

    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.showPage.call(0);
      }
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void showPage(int index) {
    pageIndex = index;
    if(index == 1) {
      reportProblemPage = ReportProblemPage(key: ValueKey("report:${DateTime.now()}"), checkStream: checkStream, showPage: showPage);
      HomeNavigator.pushHomeWidget(reportProblemPage);
    } else if(index == 2) {
      suggestPage = SuggestPage(key: ValueKey("suggest:${DateTime.now()}"), checkStream: checkStream, showPage: showPage);
      HomeNavigator.pushHomeWidget(suggestPage);
    }

    if(MeModel().showTransition) {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut);
    }
    setState(() {
    });
  }

  Widget _buildInternal() {
    if(pageIndex == 0) {
      return mainPage;
    }else if(pageIndex == 1) {
      reportProblemPage = ReportProblemPage(key: ValueKey("report:${DateTime.now()}"), checkStream: checkStream);
      return reportProblemPage;
    }else {
      suggestPage = SuggestPage(key: ValueKey("suggest:${DateTime.now()}"), checkStream: checkStream);
      return suggestPage;
    }
  }

  Widget _buildNoTransition() {
    return Stack(
      children: [
        _buildInternal(),
        Align(
          alignment: Alignment.topCenter,
          child: SendFeedbackPageTopMenu(
            checkStream: checkStream,
            pageIndex: pageIndex,
            showPage: showPage,
            rootShowPage: widget.showPage,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: MeModel().showTransition ? Stack(
        children: [
          PreloadPageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              mainPage,
              reportProblemPage,
              suggestPage
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: Zeplin.size(88),
                ),
                SendFeedbackPageTopMenu(
                  checkStream: checkStream,
                  pageIndex: pageIndex,
                  showPage: showPage,
                  rootShowPage: widget.showPage,
                ),
              ],
            ),
          )
        ],
      ) : _buildNoTransition(),
    );
  }
}
