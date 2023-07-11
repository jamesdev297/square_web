// import 'package:flutter/material.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/model/me_model.dart';
// import 'package:square_web/widget/square.dart';
// import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
//
// import 'button.dart';
//
// class WithdrawDialog extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return ButtonBarTheme(
//         data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
//         child: AlertDialog(
//           contentPadding: EdgeInsets.only(top: Zeplin.size(63), left: Zeplin.size(38), right: Zeplin.size(38)),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(15))),
//           content: SizedBox(
//             width: Zeplin.size(567),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: Container(
//                       height: Zeplin.size(144),
//                       width: Zeplin.size(144),
//                       child: Square(headParts: MeModel().contact!.square!.headParts, eyesParts: MeModel().contact!.square!.eyesParts, noseAndLipsParts: MeModel().contact!.square!.noseAndLipsParts, accessoryParts: MeModel().contact!.square!.accessoryParts),
//                     ),
//                   ),
//                   SizedBox(height: spaceL),
//                   Text(L10n.common_22_withdraw_title, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(34), fontFamily: Zeplin.robotoBold)),
//                   SizedBox(height: Zeplin.size(38)),
//                   Text(L10n.common_23_withdraw_content,textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(30), fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//           ),
//           actionsPadding: EdgeInsets.only(bottom: spaceML, top: spaceML, right: 5, left: 5),
//           actions: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Container(
//                   child: PebbleRectButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Center(child: Text(L10n.common_03_cancel, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(32), fontFamily: Zeplin.robotoBold))),
//                   ),
//                   width: Zeplin.size(233),
//                   height: Zeplin.size(100),
//                 ),
//                 SizedBox(width: Zeplin.size(14)),
//                 Container(
//                   child: PebbleRectButton(
//                       onPressed: () async {
//                         Navigator.of(context).pop();
//                         FullScreenSpinner.show(context);
//                         // var code = (await KGSessionForCustomUI.unregister())!;
//                         // if(code == KGResultCode.SUCCESS) {
//                         //   proxyNavigation("/splash");
//                         //   FullScreenSpinner.hide();
//                         // } else {
//                         //   FullScreenSpinner.hide();
//                         //   SquareDefaultDialog.showSquareDialog(
//                         //     barrierColor: CustomColor.backgroundYellow,
//                         //     description: L10n.failedWithdraw(code),
//                         //     button1Text: L10n.confirm,
//                         //     button1Action: SquareDefaultDialog.closeDialog(),
//                         //   );
//                         // }
//                       },
//                       child: Center(child: Text(L10n.common_24_withdraw, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(32), fontFamily: Zeplin.robotoBold))),
//                       backgroundColor: CustomColor.lemon,
//                   ),
//                   width: Zeplin.size(233),
//                   height: Zeplin.size(100),
//                 ),
//               ],
//             ),
//           ],
//         )
//     );
//   }
// }
