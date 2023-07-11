// import 'package:easy_web_view/easy_web_view.dart';
// import 'package:flutter/material.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/home/navigator/home_navigator.dart';
// import 'package:square_web/model/me_model.dart';
//
// class CsWebViewPage extends StatefulWidget with HomeWidget {
//   CsWebViewPage({Key? key}) : super(key: key);
//
//   @override
//   _CsWebViewPageState createState() => _CsWebViewPageState();
//
//   @override
//   MenuPack get getMenuPack => MenuPack(
//     leftMenu: MenuPack.backButton(),
//     padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)));
//
//   @override
//   HomeWidgetType get widgetType => HomeWidgetType.twoDepth;
// }
//
// class _CsWebViewPageState extends State<CsWebViewPage> {
//
//   String url = '$CS_URL?access_key=$CS_ACCESS_KEY&secret_key=$CS_SECRET_KEY&brand_key1=inquirykr'
//       '&userName=${MeModel().playerId}&applicationLanguage=${L10n.localeName}';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Center(heightFactor: 2.4, child: Text(L10n.enquire, style: centerTitleTextStyle)),
//             SizedBox(height: Zeplin.size(10)),
//             Expanded(
//               flex: 1,
//               child: EasyWebView(
//                 key: ValueKey('webview'),
//                 src: url,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
