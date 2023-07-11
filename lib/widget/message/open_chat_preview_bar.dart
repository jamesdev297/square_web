// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:square_web/bloc/openchat/openchat_channel_bloc.dart';
// import 'package:square_web/bloc/openchat/openchat_channel_bloc_event.dart';
// import 'package:square_web/bloc/openchat/openchat_channel_bloc_state.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/constants/route_paths.dart';
// import 'package:square_web/home/navigator/home_navigator.dart';
// import 'package:square_web/model/contact/contact_model.dart';
// import 'package:square_web/model/me_model.dart';
// import 'package:square_web/model/message/message_model.dart';
// import 'package:square_web/service/bloc_manager.dart';
// import 'package:square_web/service/openchat_manager.dart';
// import 'package:square_web/widget/button.dart';
// import 'package:square_web/widget/pebble_widget.dart';
// import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
//
// class OpenChatPreviewBar extends StatefulWidget {
//   const OpenChatPreviewBar({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<OpenChatPreviewBar> createState() => _OpenChatPreviewBarState();
// }
//
// class _OpenChatPreviewBarState extends State<OpenChatPreviewBar> {
//   static const int RETRY_DELAY = 2000;
//
//   String get openChatRoomTitle => "${L10n.openChatPreviewTitle} ${OpenChatManager().myChannel?.title}";
//   bool expanded = false;
//   bool retryToJoin = false;
//   int nextRetryTime = 0;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Widget _buildRoomTileText() {
//     return Text(
//       openChatRoomTitle,
//       style: TextStyle(fontSize: Zeplin.size(22), fontWeight: FontWeight.w500, color: CustomColor.blueyGrey),
//       overflow: TextOverflow.ellipsis,
//     );
//   }
//
//   Widget _buildChatMessageText(OpenChatMsgModel msg) {
//     return FutureBuilder(
//       future: msg.sender!.loadComplete!.future,
//       builder: (context, snapshot) {
//         String? nickname;
//         if(msg.messageType != MessageType.system)
//           nickname = msg.sender!.nickname ??
//               ContactModelPool().getPlayerNickNameWithMe(msg.sender!.playerId);
//
//         return Text.rich(
//           TextSpan(
//             children: [
//               if(nickname != null)
//                 TextSpan(text: "$nickname : ",
//                     style: TextStyle(color: MeModel().isMe(msg.sender!.playerId) ? CustomColor.azureBlue : Colors.black)),
//               TextSpan(text: msg.getSubtitle(), style: nickname == null ? TextStyle(color: CustomColor.blueyGrey) : null)
//             ],
//             style: TextStyle(fontSize: Zeplin.size(22), fontWeight: FontWeight.w500, color: Colors.black)
//           ),
//           overflow: TextOverflow.ellipsis,
//         );
//       }
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if(retryToJoin) {
//           int now = DateTime.now().millisecondsSinceEpoch;
//           if(now > nextRetryTime) {
//             BlocManager.getBloc<OpenChatChannelBloc>()?.add(JoinChannel());
//             nextRetryTime = now + RETRY_DELAY; //2초후 재시도 가능
//           }
//         } else {
//           HomeNavigator.push(RoutePaths.openchat.open);
//         }
//       },
//       child: Container(
//           margin: EdgeInsets.only(top: Zeplin.size(20)),
//           height: Zeplin.size(expanded ? 184 : 70),
//           child: PebbleRectWithSuffix(
//               padding: EdgeInsets.zero,
//               icon: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       if(retryToJoin) {
//                         return;
//                       } else {
//                         setState(() {
//                           expanded = !expanded;
//                         });
//                         // TODO 수동 intercept 범위 변환은 우선 사용하지않는다.
//                         // BlocManager.getBloc<PointerInterceptBloc>()!.add(
//                         //     ChangeHomeTopMenuRender(homeTopSubHeight: expanded ? 114 : 50));
//                       }
//                     },
//                     child: Container(
//                         padding: EdgeInsets.only(
//                             right: Zeplin.size(24),
//                             top: Zeplin.size(13),
//                             left: Zeplin.size(24)),
//                         color: Colors.transparent,
//                         child: SizedBox(
//                             width: Zeplin.size(24),
//                             child: Center(
//                               child: Transform.rotate(
//                                   angle: expanded ? pi : 0,
//                                   child: Icon46(
//                                     Assets.img.ico_h_24_arr_gray_down,
//                                     ratio: 0.5,
//                                   )),
//                             ))),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding:
//                     EdgeInsets.only(left: Zeplin.size(24), top: Zeplin.size(17), right: Zeplin.size(68), bottom: Zeplin.size(17)),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       BlocBuilder<OpenChatChannelBloc, OpenChatChannelBlocState>(
//                         bloc: BlocManager.getBloc(),
//                         builder: (context, state) {
//                           if (state is OpenChatJoining) {
//                             return Center(child: SquareCircularProgressIndicator());
//                           } else if (state is OpenChatFailedToJoin) {
//                             retryToJoin = true;
//                             return Text(L10n.channelJoinFailed,
//                                 style: TextStyle(fontSize: Zeplin.size(22), fontWeight: FontWeight.w500, color: Colors.black));
//                           } else if (state is OpenChatJoined) {
//                             retryToJoin = false;
//                             List<OpenChatMsgModel> messages = OpenChatManager().chatMsgCache.toList();
//                             if (expanded) {
//                               return Expanded(
//                                 child: messages.length == 0 ? _buildRoomTileText() : ListView.builder(
//                                   padding: EdgeInsets.zero,
//                                   reverse: true,
//                                   itemBuilder: (context, index) => Padding(
//                                     padding: EdgeInsets.symmetric(vertical: Zeplin.size(3)),
//                                     child: _buildChatMessageText(messages[index]),
//                                   ),
//                                   itemCount: messages.length,
//                                 ),
//                               );
//                             } else {
//                               return Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Expanded(
//                                     child: messages.length == 0 ? _buildRoomTileText()
//                                       : _buildChatMessageText(messages.first)
//                                   )
//                                 ],
//                               );
//                             }
//                           }
//                           return Container();
//                         })]),
//               ),
//               painter: PebbleRectFillPainter(
//                   color: Colors.white.withOpacity(0.9),
//                   stroke: true,
//                   strokePaint: Paint()
//                     ..color = CustomColor.lightGrey
//                     ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
//                     ..style = PaintingStyle.stroke
//                     ..strokeWidth = 2.0,
//                   curveSize: 0.14))),
//     );
//   }
// }
