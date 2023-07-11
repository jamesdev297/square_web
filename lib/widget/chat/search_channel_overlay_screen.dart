// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:square_web/bloc/search_channel_bloc.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/debug/overlay_logger_widget.dart';
// import 'package:square_web/service/bloc_manager.dart';
// import 'package:square_web/widget/dialog/square_default_dialog.dart';
//
// class SearchChannelOverlay extends StatefulWidget {
//   const SearchChannelOverlay({Key? key}) : super(key: key);
//
//   @override
//   _SearchChannelOverlayState createState() => _SearchChannelOverlayState();
// }
//
// class _SearchChannelOverlayState extends State<SearchChannelOverlay> with SingleTickerProviderStateMixin {
//   late AnimationController _showController;
//   Timer? showTimer;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _showController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
//     if(BlocManager.getBloc<SearchChannelBloc>()!.state is SearchingChannelState) {
//       _showBox();
//     }
//   }
//
//   @override
//   void dispose() {
//     _showController.dispose();
//     showTimer?.cancel();
//     super.dispose();
//   }
//
//   void _showBox() {
//     showTimer?.cancel();
//     _showController.reset();
//     _showController.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<SearchChannelBloc, SearchChannelState>(
//         bloc: BlocManager.getBloc(),
//         listener: (context, state) {
//         LogWidget.debug("searchChannelState : ${state.runtimeType} / ${state is SearchChannelInitial ? state.changeSuccess : ""}");
//           if (state is SearchChannelInitial) {
//             showTimer?.cancel();
//             if(state.changeSuccess == true) {
//               showTimer = Timer(Duration(seconds: 1), () {
//                 _showController.reverse();
//               });
//             }else if(state.changeSuccess == false){
//               SquareDefaultDialog.showSquareDialog(
//                   barrierColor: CustomColor.backgroundYellow,
//                   description: L10n.searchChannelFailed,
//                   button1Text: L10n.confirm, button1Action: SquareDefaultDialog.closeDialog());
//             }
//           }
//           if(state is SearchingChannelState) {
//             _showBox();
//           }
//         },
//         builder: (context, state) {
//           bool? changeSuccess;
//
//           if(state is SearchChannelInitial) {
//             changeSuccess = state.changeSuccess;
//           }
//
//           Widget contentInBox = Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: Zeplin.size(70),
//                 height: Zeplin.size(70),
//                 child: Center(
//                   child: CircularProgressIndicator(color: Colors.white,),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(L10n.searchingChannel, style: TextStyle(color: Colors.white, fontSize: Zeplin.size(28), fontFamily: Zeplin.robotoBold),)
//             ],
//           );
//           if(changeSuccess == true) {
//             contentInBox = Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   width: 50,
//                   height: 50,
//                   child: Center(
//                     child: Image.asset(Assets.img.ico_ch_70),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(L10n.finishSearchChannel, style: TextStyle(color: Colors.white, fontSize: Zeplin.size(28), fontFamily: Zeplin.robotoBold),)
//               ],
//             );
//           }else if(changeSuccess == false){
//             return Container();
//           }
//
//           return Container(
//             child: Center(
//               child: AnimatedBuilder(
//                   animation: _showController,
//                   builder: (context, child) {
//                     return Opacity(
//                         opacity: _showController.value,
//                         child: child
//                     );
//                   },
//                   child: Material(
//                     color: Colors.transparent,
//                     child: Container(
//                         decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: AssetImage(Assets.img.dim), fit: BoxFit.fill)),
//                         width: Zeplin.size(300),
//                         height: Zeplin.size(300),
//                         child: Center(
//                               child: contentInBox
//                             )),
//                       ))));
//         });
//   }
// }
//
