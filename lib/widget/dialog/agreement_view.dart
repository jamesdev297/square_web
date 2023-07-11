// import 'package:easy_web_view/easy_web_view.dart';
// import 'package:flutter/material.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/model/agreement_model.dart';
// import 'package:square_web/widget/button.dart';
//
// class AgreementView extends StatefulWidget {
//   final AgreementModel? agreementModel;
//   final bool withBackButton;
//   final String? title;
//
//   AgreementView(this.agreementModel,
//       { this.withBackButton = true, bool useMyPageTitle: false }) :
//         title = useMyPageTitle ? agreementModel!.myPageTitle : agreementModel!
//             .title;
//
//   @override
//   State<StatefulWidget> createState() => AgreementViewState();
// }
//
// class AgreementViewState extends State<AgreementView> {
//
//   Widget _buildHeader(BuildContext context) {
//     return Stack(
//       alignment:
//       AlignmentDirectional.centerStart,
//       children: [
//         Align(
//           alignment: Alignment.center,
//           child: Center(heightFactor: 2.4, child: Text(widget.title!, style: centerTitleTextStyle)),
//         ),
//         if(widget.withBackButton)
//           GestureDetector(child: SizedBox(height: Zeplin.size(46), width: Zeplin.size(46),
//             child: Center(child: Icon46(Assets.img.ico_46_arrow_bk))),
//             onTap: () => Navigator.pop(context),
//           )
//       ]
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                     padding: EdgeInsets.only(
//                         left: Zeplin.size(24), right: Zeplin.size(24)),
//                     child: _buildHeader(context)
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: Zeplin.size(38),
//           ),
//           Expanded(
//             flex: 1,
//             child: EasyWebView(
//               key: ValueKey('webview'),
//               src: widget.agreementModel!.contentUrl!,
//             ),
//           ),
//         ]
//       )
//     );
//   }
// }
