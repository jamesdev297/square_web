// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:square_web/bloc/help_bloc.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/home/navigator/home_navigator.dart';
// import 'package:square_web/model/help_model.dart';
// import 'package:square_web/model/scroll_default.dart';
// import 'package:square_web/service/bloc_manager.dart';
// import 'package:square_web/widget/custom_expansion_tile.dart';
// import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
//
// class HelpPage extends StatefulWidget with HomeWidget {
//   @override
//   _HelpPageState createState() => _HelpPageState();
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
// class _HelpPageState extends State<HelpPage> {
//   final ScrollDefault _scrollDefault = ScrollDefault();
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Widget buildExpansionTileItem(HelpModel helpContent) {
//     return CustomExpansionTile(
//       title:  Text("${helpContent.subTitle}", style: TextStyle(color: Colors.black, fontFamily: Zeplin.robotoBold, fontSize: Zeplin.size(28))),
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.only(top: Zeplin.size(38), bottom: Zeplin.size(38)),
//           color: CustomColor.paleGrey,
//           child: ListTile(
//             title: Text("${helpContent.subContent}", style: TextStyle(color: Colors.black, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
//           ),
//         )
//       ],
//       iconColor: CustomColor.outlineGrey,
//       collapsedIconColor: CustomColor.outlineGrey,
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _scrollDefault.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: BlocBuilder<HelpBloc, HelpBlocState>(
//               bloc: BlocManager.getBloc(),
//               builder: (context, state) {
//                 if (state is HelpUninitialized) {
//                   return SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80);
//                 }
//
//                 if (state is HelpLoaded) {
//                   return Column(
//                     children: [
//                       Center(heightFactor: 2.4, child: Text(L10n.help, style: centerTitleTextStyle)),
//                       SizedBox(height: spaceL),
//                       Expanded(
//                         child: Scrollbar(
//                           child: SingleChildScrollView(
//                             child: ListView.builder(
//                                 padding: EdgeInsets.zero,
//                                 shrinkWrap: true,
//                                 itemCount: state.helpContentList!.length,
//                                 itemBuilder: (context, index) {
//                                   return buildExpansionTileItem(state.helpContentList![index]);
//                                 },
//                                 controller: _scrollDefault.controller,
//                             )
//                           ),
//                         ),
//                       )
//                     ],
//                   );
//                 }
//                 return Container();
//               }
//             ),
//       ));
//   }
// }
