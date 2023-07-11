// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/constants/custom_status_code.dart';
// import 'package:square_web/debug/overlay_logger_widget.dart';
// import 'package:square_web/main.dart';
// import 'package:square_web/model/message/message_model.dart';
// import 'package:square_web/model/openchat/openchat_model.dart';
// import 'package:square_web/service/openchat_manager.dart';
// import 'package:square_web/widget/chat/report_user_panel.dart';
// import 'package:square_web/widget/chat/search_channel_overlay_screen.dart';
// import 'package:square_web/widget/dialog/square_simple_dialog.dart';
//
// class SquareOpenChatDialog {
//   static OverlayEntry? searchChannelOverlay;
//   static OverlayEntry? reportDialogOverlay;
//
//   static final Map<OpenChatReportType, String> openChatReportReasonStrMap = {
//     OpenChatReportType.block: L10n.reportReasonBlock,
//     OpenChatReportType.illegal: L10n.reportReasonIllegal,
//     OpenChatReportType.swearing: L10n.reportReasonSwearing,
//     OpenChatReportType.personalInfo: L10n.reportReasonPersonalInfo,
//     OpenChatReportType.hateSpeech: L10n.reportReasonHateSpeech,
//     OpenChatReportType.sexual: L10n.reportReasonSexual,
//     OpenChatReportType.unknown: L10n.unknown
//   };
//
//   static void showReportDialog(Widget content) {
//     OverlayState? overlayState = navigatorKey.currentState!.overlay;
//     if (reportDialogOverlay == null) {
//       reportDialogOverlay = OverlayEntry(builder: (context) {
//         return Material(
//           type: MaterialType.transparency,
//           child: Container(
//             color: CustomColor.backgroundYellow,
//             child: Center(
//               child: SquareSimpleDialog(
//                   onTapButton: () {
//                     hideReportDialogOverlay();
//                   },
//                   content: content),
//             ),
//           ),
//         );
//       });
//       overlayState!.insert(reportDialogOverlay!);
//     }
//   }
//
//   static void hideReportDialogOverlay() {
//     reportDialogOverlay?.remove();
//     reportDialogOverlay = null;
//   }
//
//   static void showReportBottomSheet(OpenChatMsgModel messageModel) {
//     showModalBottomSheet(
//       useRootNavigator: true,
//       barrierColor: CustomColor.backgroundYellow,
//       context: navigatorKey.currentContext!,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return ReportUserPanel(messageModel: messageModel);
//       }
//     );
//   }
//
//   static void showNotCurrentMemberBottomSheet(String? nickname) {
//     showModalBottomSheet(
//       useRootNavigator: true,
//       barrierColor: CustomColor.backgroundYellow,
//       backgroundColor: Colors.transparent,
//       context: navigatorKey.currentContext!,
//       builder: (context) {
//
//         return Container(
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: radiusM,
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
//               ]
//           ),
//           height: Zeplin.size(309),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Padding(
//                 padding: EdgeInsets.only(top: Zeplin.size(50), bottom: Zeplin.size(30)),
//                 child: Text(L10n.failToReport, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(32), fontFamily: Zeplin.robotoBold),
//                 ),
//               ),
//               Text(L10n.alreadyLeaveRoomMember("${nickname ?? L10n.unknownUser}"), style: TextStyle(color: Colors.black, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
//             ],
//           ),
//         );
//       });
//   }
//
//   static void showSearchChannelOverlay() {
//     OverlayState? overlayState = navigatorKey.currentState!.overlay;
//     if (searchChannelOverlay == null) {
//       searchChannelOverlay = OverlayEntry(builder: (context) {
//         return Material(
//           type: MaterialType.transparency,
//           child: SearchChannelOverlay(),
//         );
//       });
//       overlayState!.insert(searchChannelOverlay!);
//     }
//   }
//
//   static void hideSearchChannelOverlay() async {
//     searchChannelOverlay?.remove();
//     searchChannelOverlay = null;
//   }
//
//   static void alreadyReportUser() {
//     showReportDialog(SizedBox(
//         height: Zeplin.size(108),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(L10n.alreadyReportedUser(1),
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30))),
//           ],
//         )));
//   }
//
//   static void alreadyReportedMsg() {
//     showReportDialog(SizedBox(
//         height: Zeplin.size(160),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(L10n.alreadyReportedMsg,
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30)),
//                 textAlign: TextAlign.center),
//           ],
//         )));
//   }
//
//   static void overReportCount(int maxReportCount) {
//     showReportDialog(SizedBox(
//         height: Zeplin.size(160),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               L10n.overReported(10),
//               style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30)),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text("(${L10n.remainCount} : 0/$maxReportCount)",
//                 style: TextStyle(
//                     fontWeight: FontWeight.w500, fontSize: Zeplin.size(30), color: CustomColor.blueyGrey)),
//           ],
//         )));
//   }
//
//   static void alreadyRestrictedUser() {
//     showReportDialog(SizedBox(
//         height: Zeplin.size(160),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(L10n.alreadyRestricted,
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30)),
//                 textAlign: TextAlign.center),
//           ],
//         )));
//   }
//
//   static void reportResponse(ReportResponse response) {
//     switch (response.statusCode) {
//       case 404: //NOT_FOUND_MESSAGE
//         LogWidget.error("not found openchat message on server.");
//         break;
//       case HttpStatus.created:
//         alreadyReportedMsg();
//         break;
//       case CustomStatus.EXCEED_LIMIT: // - 하루 신고 횟수 초과
//         overReportCount(response.dailyReportMax!);
//         break;
//       case CustomStatus.TOO_FAST_REQUEST: // - 같은 유저 1시간에 1회 신고가능
//         alreadyReportUser();
//         break;
//       case CustomStatus.ALREADY_RESTRICTED:
//         alreadyRestrictedUser();
//         break;
//       case CustomStatus.NOT_CURRENT_MEMBER:
//         showNotCurrentMemberBottomSheet(response.nickname);
//         break;
//
//     }
//   }
//   static void showRestrictedReason() {
//     /*OpenChatRestrictedInfo? info = OpenChatRestrictedInfo.fromMap({
//       "reportedPlayerId": "",
//       "reportCount": 5,
//       "restrictPeriod" : {
//         "count": 5,
//         "period": 5 * 60 * 1000
//       },
//       "nextRestrictPeriod" : {
//         "count": 10,
//         "period": 10 * 60 * 1000
//       },
//       "reason": "block",
//       "restrictEndTime" : DateTime.now().millisecondsSinceEpoch + 5 * 60 * 1000
//     });*/
//     OpenChatRestrictedInfo? info = OpenChatManager().myChannel?.restrictInfo;
//     if(info == null)
//       return;
//
//     showReportDialog(SizedBox(
//         height: Zeplin.size(360),
//         width: Zeplin.size(600),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   L10n.restrictedInfoTitle(info.restrictPeriod.periodStr),
//                   style: TextStyle(
//                       color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(30)),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: Zeplin.size(31),
//             ),
//             Table(
//               border: TableBorder.all(color: CustomColor.blueyGrey, width: 0.5),
//               columnWidths: const <int, TableColumnWidth>{
//                 0: FlexColumnWidth(0.8),
//                 1: FlexColumnWidth(),
//               },
//               children: [
//                 TableRow(children: [
//                   Container(
//                     height: Zeplin.size(80),
//                     color: CustomColor.paleGrey,
//                     child: Center(
//                         child: Text(L10n.reportedCount,
//                             style: TextStyle(
//                                 color: CustomColor.darkGrey,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: Zeplin.size(24)))),
//                   ),
//                   Container(
//                     height: Zeplin.size(80),
//                     color: CustomColor.paleGrey,
//                     child: Center(
//                         child: Text(L10n.reportedReason,
//                             style: TextStyle(
//                                 color: CustomColor.darkGrey,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: Zeplin.size(24)))),
//                   ),
//                 ]),
//                 TableRow(children: [
//                   Container(
//                     height: Zeplin.size(80),
//                     color: Colors.white,
//                     child: Center(
//                         child: Text("${info.reportCount}",
//                             style: TextStyle(
//                                 color: CustomColor.darkGrey,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: Zeplin.size(24)))),
//                   ),
//                   Container(
//                     height: Zeplin.size(80),
//                     color: Colors.white,
//                     child: Center(
//                         child: Text("${openChatReportReasonStrMap[info.reason]}",
//                             style: TextStyle(
//                                 color: CustomColor.darkGrey,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: Zeplin.size(24)))),
//                   ),
//                 ]),
//               ],
//             ),
//             SizedBox(
//               height: Zeplin.size(14)
//             ),
//             Text(
//               "※ ${L10n.nextRestrictInfo(info.nextRestrictPeriod.count, info.nextRestrictPeriod.periodStr)}",
//               style: TextStyle(
//                   color: CustomColor.waterMelon, fontWeight: FontWeight.w500, fontSize: Zeplin.size(23)),
//               textAlign: TextAlign.left,
//             ),
//           ],
//         )));
//   }
//
//   static void hideAllDialogs() {
//     hideReportDialogOverlay();
//     hideSearchChannelOverlay();
//   }
// }
