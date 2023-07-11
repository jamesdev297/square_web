// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/debug/overlay_logger_widget.dart';
// import 'package:square_web/service/auth_manager/auth_manager.dart';
// import 'dart:html' as html;
//
// import '../static_wigets/square_circular_progress_indicator.dart';
//
// enum _DialogState {
//   signIn,
//   loading,
//   not_enabled,
// }
//
// class SignInDialog extends StatefulWidget {
//   static Future<bool> show(BuildContext context) async {
//     showDialog(
//         context: context,
//         builder: (context) => Dialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))), child: SignInDialog()));
//     return true;
//   }
//
//   @override
//   State<StatefulWidget> createState() => SignInDialogState();
// }
//
// class SignInDialogState extends State<SignInDialog> {
//   ValueNotifier<_DialogState> _dialogState = ValueNotifier(_DialogState.signIn);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: 500,
//         height: 400,
//         child: ValueListenableBuilder(
//           valueListenable: _dialogState,
//           builder: (context, value, child) {
//             switch (value) {
//               case _DialogState.signIn:
//                 return _buildSignInDialog();
//               case _DialogState.loading:
//                 return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [SquareCircularProgressIndicator(), Text("Sign In")]);
//               case _DialogState.not_enabled:
//                 return _buildNotEnabledDialog();
//               default:
//                 return _buildSignInDialog();
//             }
//           },
//         ));
//   }
//
//   Widget _buildSignInDialog() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Align(
//                 alignment: Alignment.center,
//                 child: Text("로그인 또는 회원가입",
//                     style: TextStyle(fontSize: Zeplin.size(23), fontFamily: Zeplin.robotoBold, color: Colors.black))),
//             Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   splashRadius: 15,
//                   icon: const Icon(Icons.close),
//                   color: Colors.black,
//                   tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 )),
//           ],
//         ),
//         Divider(),
//         SizedBox(height: Zeplin.size(40)),
//         Text("로그인이 필요한 서비스 입니다.",
//             style: TextStyle(fontSize: Zeplin.size(35), fontFamily: Zeplin.robotoBold, color: Colors.black)),
//         SizedBox(height: Zeplin.size(20)),
//         Text("아래 암호화폐 지갑에 연결하거나 새 지갑을 만들어 로그인해주세요.",
//             style: TextStyle(fontSize: Zeplin.size(23), fontWeight: FontWeight.w500, color: Colors.black)),
//         SizedBox(height: Zeplin.size(60)),
//         OutlinedButton(
//             style: OutlinedButton.styleFrom(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
//                 maximumSize: Size(300, 80)),
//             onPressed: () async {
//               _dialogState.value = _DialogState.loading;
//               AuthResult authResult = await AuthManager().signForToken(idpCode: WalletType.metamask, context: context);
//               LogWidget.info("AuthResult : $authResult");
//               if (authResult == AuthResult.not_enabled) {
//                 _dialogState.value = _DialogState.not_enabled;
//                 return;
//               } else if (authResult == AuthResult.success) {
//                 Navigator.of(context).maybePop();
//                 return;
//               }
//               _dialogState.value = _DialogState.signIn;
//             },
//             child: Container(
//               alignment: Alignment.center,
//               height: Zeplin.size(100),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(Assets.img.ico_metamask, width: Zeplin.size(50), height: Zeplin.size(50)),
//                   SizedBox(width: Zeplin.size(20)),
//                   Text("Metamask",
//                       style:
//                           TextStyle(fontSize: Zeplin.size(24), fontFamily: Zeplin.robotoBold, color: Colors.black)),
//                 ],
//               ),
//             )),
//         SizedBox(height: Zeplin.size(40)),
//         TextButton(
//             onPressed: () {},
//             child: Text(
//               "암호화폐 지갑이 뭔가요?",
//               style: TextStyle(fontSize: Zeplin.size(24), fontWeight: FontWeight.w500),
//             )),
//         SizedBox(height: Zeplin.size(20)),
//         TextButton(
//             onPressed: () {},
//             child:
//                 Text("왜 지갑으로 로그인하나요?", style: TextStyle(fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)))
//       ],
//     );
//   }
//
//   Widget _buildNotEnabledDialog() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Align(
//                 alignment: Alignment.center,
//                 child: Text("지갑 생성",
//                     style: TextStyle(fontSize: Zeplin.size(23), fontWeight: FontWeight.w500, color: Colors.black))),
//             Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   splashRadius: 15,
//                   icon: const Icon(Icons.close),
//                   color: Colors.black,
//                   tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 )),
//           ],
//         ),
//         Divider(),
//         SizedBox(height: Zeplin.size(80)),
//         Text("지갑을 생성해주세요.",
//             style: TextStyle(fontSize: Zeplin.size(35), fontFamily: Zeplin.robotoBold, color: Colors.black)),
//         SizedBox(height: Zeplin.size(20)),
//         Text("확인된 지갑이 없습니다. Metamask 설치 후 지갑을 생성해주세요.",
//             style: TextStyle(fontSize: Zeplin.size(23), fontWeight: FontWeight.w500, color: Colors.black)),
//         SizedBox(height: Zeplin.size(80)),
//         Text("Supported Browsers",
//             style: TextStyle(fontSize: Zeplin.size(35), fontFamily: Zeplin.robotoBold, color: Colors.black)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Column(
//               children: [
//                 IconButton(
//                     onPressed: () => html.window.open("https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn", "_blank"),
//                     icon: Image.asset(Assets.img.icon_chrome), iconSize: Zeplin.size(96)),
//                 Text("Chrome")
//               ],
//             ),
//             SizedBox(width: Zeplin.size(20)),
//             Column(
//               children: [
//                 IconButton(
//                     onPressed: () => html.window.open("https://addons.mozilla.org/ko/firefox/addon/ether-metamask/", "_blank"),
//                     icon: Image.asset(Assets.img.icon_firefox), iconSize: Zeplin.size(96)),
//                 Text("Firefox")
//               ],
//             ),
//             SizedBox(width: Zeplin.size(20)),
//             Column(
//               children: [
//                 IconButton(
//                     onPressed: () => html.window.open("https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn", "_blank"),
//                     icon: Image.asset(Assets.img.icon_brave), iconSize: Zeplin.size(96)),
//                 Text("Brave")
//               ],
//             ),
//             SizedBox(width: Zeplin.size(20)),
//             Column(
//               children: [
//                 IconButton(
//                     onPressed: () => html.window.open("https://microsoftedge.microsoft.com/addons/detail/metamask/ejbalbakoplchlghecdalmeeeajnimhm", "_blank"),
//                     icon: Image.asset(Assets.img.icon_edge), iconSize: Zeplin.size(96)),
//                 Text("Edge")
//               ],
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
