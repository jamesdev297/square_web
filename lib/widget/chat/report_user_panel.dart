// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/model/message/message_model.dart';
// import 'package:square_web/model/openchat/openchat_model.dart';
// import 'package:square_web/service/openchat_manager.dart';
// import 'package:square_web/widget/dialog/square_report_dialog.dart';
// import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
//
// class ReportUserPanel extends StatefulWidget {
//   final OpenChatMsgModel messageModel;
//
//   const ReportUserPanel({Key? key, required this.messageModel}) : super(key: key);
//
//   @override
//   _ReportUserPanelState createState() => _ReportUserPanelState();
// }
//
// class _ReportUserPanelState extends State<ReportUserPanel> with SingleTickerProviderStateMixin{
//
//   bool reportDone = false;
//   int maxReportCount = 0;
//   int reportCount = 0;
//   late List<Widget> widgetList;
//   double height = Zeplin.size(805);
//
//   @override
//   void initState() {
//     super.initState();
//
//     List<MapEntry<String, VoidCallback>> itemList = SquareOpenChatDialog.openChatReportReasonStrMap.entries
//         .where((e) => e.key != OpenChatReportType.unknown)
//         .map((e) => MapEntry<String, VoidCallback>(e.value, () => _report(e.key))).toList();
//
//     widgetList = List.generate(itemList.length, (index) {
//       final item = itemList[index];
//       return RawMaterialButton(onPressed: () {
//         item.value();
//       }, child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           SizedBox(width: Zeplin.size(34)),
//           Text(item.key, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28)),),
//         ],
//       ),);
//     });
//   }
//
//   void _report(OpenChatReportType reason) async {
//     FullScreenSpinner.show(context);
//     ReportResponse response = await OpenChatManager().reportPlayer(widget.messageModel, reason);
//     FullScreenSpinner.hide();
//
//     if(response.statusCode == 200) {
//       setState(() {
//         reportCount = response.dailyReportedCount!;
//         maxReportCount = response.dailyReportMax!;
//         height = Zeplin.size(481);
//         reportDone = true;
//       });
//     } else {
//       SquareOpenChatDialog.reportResponse(response);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(milliseconds: 300),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: radiusM,
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
//         ]
//       ),
//       height: height,
//       child: reportDone ? Container(
//           child: Column(
//             children: [
//               SizedBox(height: Zeplin.size(50)),
//               Image.asset(Assets.img.ico_70_check_green, width: Zeplin.size(70)),
//               SizedBox(height: Zeplin.size(10)),
//               Text(L10n.reportDone, style: TextStyle(fontFamily: Zeplin.robotoBold, fontSize: Zeplin.size(32)),),
//               SizedBox(height: Zeplin.size(30)),
//               Text(L10n.reportDoneContent, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(28)),),
//               SizedBox(height: Zeplin.size(20)),
//               Text(L10n.overReported(maxReportCount), style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(24), color: CustomColor.blueyGrey)),
//               Text("(${L10n.remainCount} : $reportCount/$maxReportCount)",style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(24), color: CustomColor.blueyGrey)),
//             ],
//           )
//       ) : Column(
//         children: <Widget>[
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: Zeplin.size(45)),
//             child: Text(L10n.userReport, style: TextStyle(fontFamily: Zeplin.robotoBold, fontSize: Zeplin.size(32)),),
//           ),
//           Padding(
//             padding: EdgeInsets.only(bottom: Zeplin.size(10), left: Zeplin.size(34)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(L10n.whyReport, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(24)),),
//               ],
//             ),
//           ),
//         ] + widgetList,
//       ),
//     );
//   }
// }
