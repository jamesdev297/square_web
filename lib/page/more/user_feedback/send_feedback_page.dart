import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/widget/button.dart';

class SendFeedbackPage extends StatefulWidget with HomeWidget{
  final Function? showPage;
  final Function? rootShowPage;

  SendFeedbackPage({this.showPage, this.rootShowPage, Key? key}) : super(key: key);

  @override
  _SendFeedbackPageState createState() => _SendFeedbackPageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    leftMenu: MenuPack.backButton(), padding: EdgeInsets.only(top: Zeplin.size(32)),
    centerMenu: Text(L10n.feedback_01_send_feedback, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
  );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "SendFeedbackPage";

  @override
  bool get isInternalImplement => true;

}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  final TextStyle subTitleTextStyle = TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.rootShowPage?.call(0);
      }
    });*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: Zeplin.size(120)),
          ListTile(
            onTap: () {
              widget.showPage?.call(1);
            },
            contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
            leading: Text(L10n.feedback_01_report_problem, style: subTitleTextStyle),
            trailing: Icon36(Assets.img.ico_36_arrow_gy),
          ),
          ListTile(
            onTap: () {
              widget.showPage?.call(2);
            },
            contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
            leading: Text(L10n.feedback_01_suggest, style: subTitleTextStyle),
            trailing: Icon36(Assets.img.ico_36_arrow_gy),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(34)),
            child: Row(
              children: [
                Expanded(child: Text(L10n.feedback_01_feedback_content, style: TextStyle(fontSize: Zeplin.size(26), color: CustomColor.taupeGray, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      )
    );
  }
}
