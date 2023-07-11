// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/model/me_model.dart';
// import 'package:square_web/model/message/message_model.dart';
// import 'package:square_web/model/openchat/openchat_model.dart';
// import 'package:square_web/service/openchat_manager.dart';
// import 'package:square_web/widget/dialog/square_report_dialog.dart';
// import 'package:square_web/widget/sliding_panel.dart';
// import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
//
// class ReportOverlayScreen extends StatefulWidget {
//   final OpenChatMsgModel messageModel;
//   const ReportOverlayScreen({Key? key, required this.messageModel}) : super(key: key);
//
//   @override
//   _ReportOverlayScreenState createState() => _ReportOverlayScreenState();
// }
//
// class _ReportOverlayScreenState extends State<ReportOverlayScreen> {
//   late PanelController panelController;
//   Map<String, VoidCallback> itemMap = {};
//   bool reportDone = false;
//   int maxReportCount = 0;
//   int reportCount = 0;
//   late List<Widget> widgetList;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     panelController = PanelController();
//
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       panelController.open();
//     });
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
//           Text(item.key, style: TextStyle(fontWeight: Zeplin.notoSansMedium, fontSize: Zeplin.size(28)),),
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
//       panelController.animatePanelToPosition(0.5, duration: Duration(milliseconds: 300), curve: Curves.easeOutExpo);
//       setState(() {
//         reportCount = response.dailyReportedCount!;
//         maxReportCount = response.dailyReportMax!;
//         reportDone = true;
//       });
//     } else {
//       SquareOpenChatDialog.reportResponse(response);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: SlidingPanel(
//         borderRadius: radiusM,
//         isDraggable: false,
//         controller: panelController,
//         minSize: 100,
//         maxSize: DeviceUtil.screenHeight * 0.65,
//         body: GestureDetector(
//           onTap: () {
//             SquareOpenChatDialog.hideReportOverlay();
//           },
//           child: Container(
//             color: CustomColor.backgroundYellow,
//           ),
//         ),
//         panel: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: reportDone ? Container(
//             child: Column(
//               children: [
//                 SizedBox(height: 5,),
//                 Image.asset(Assets.img.ico_70_check_green, width: Zeplin.size(70),),
//                 SizedBox(height: 10,),
//                 Text(L10n.reportDone, style: TextStyle(fontWeight: Zeplin.notoSansBold, fontSize: Zeplin.size(32)),),
//                 SizedBox(height: 14,),
//                 Text(L10n.reportDoneContent, textAlign: TextAlign.center,style: TextStyle(fontWeight: Zeplin.notoSansMedium, fontSize: Zeplin.size(28)),),
//                 SizedBox(height: 10,),
//                 Text(L10n.overReported(maxReportCount), style: TextStyle(fontWeight: Zeplin.notoSansMedium, fontSize: Zeplin.size(24), color: CustomColor.blueyGrey),),
//                 Text("(${L10n.remainCount} : $reportCount/$maxReportCount)",style: TextStyle(fontWeight: Zeplin.notoSansMedium, fontSize: Zeplin.size(24), color: CustomColor.blueyGrey)),
//               ],
//             )
//           ) : Column(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Text(L10n.userReport, style: TextStyle(fontWeight: Zeplin.notoSansBold, fontSize: Zeplin.size(32)),),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(L10n.whyReport, style: TextStyle(fontWeight: Zeplin.notoSansMedium, fontSize: Zeplin.size(24)),),
//                   ],
//                 ),
//               ),
//             ] + widgetList,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
