// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:square_web/bloc/bloc.dart';
// import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
// import 'package:square_web/bloc/openchat/openchat_message_bloc.dart';
// import 'package:square_web/constants/assets.dart';
// import 'package:square_web/constants/constants.dart';
// import 'package:square_web/model/scroll_default.dart';
// import 'package:square_web/model/text_editing_default.dart';
// import 'package:square_web/page/chat_page.dart';
// import 'package:square_web/service/bloc_manager.dart';
// import 'package:square_web/service/openchat_manager.dart';
// import 'package:square_web/widget/button.dart';
// import 'package:square_web/widget/dialog/square_report_dialog.dart';
// import 'package:square_web/widget/shape_borders.dart';
//
// class ChatBarForOpenChat extends StatefulWidget {
//   final FocusNode? focusNode;
//   final ScrollDefault scrollDefault;
//
//   ChatBarForOpenChat(this.focusNode, this.scrollDefault);
//
//   @override
//   _ChatBarForOpenChatState createState() => _ChatBarForOpenChatState();
// }
//
// class _ChatBarForOpenChatState  extends State<ChatBarForOpenChat> with TickerProviderStateMixin{
//   TextEditingDefault _textEditDefault = TextEditingDefault();
//   ScrollController scrollController = ScrollController();
//   ChatTextOverBloc? chatTextOverBloc;
//   late OpenChatMessageBloc messageBloc;
//   late ChangeKeyboardTypeBloc changeKeyboardTypeBloc;
//   bool chatTextOverEnable = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     chatTextOverBloc = BlocProvider.of(context);
//     messageBloc = BlocProvider.of(context);
//     changeKeyboardTypeBloc = BlocProvider.of(context);
//
//
//     _textEditDefault.init("messege", this, onPressedSubmit: () {
//       SwitchBlocState state = BlocManager.getBloc<ShowEmoticonExampleBloc>()!.state;
//       if(state is SwitchBlocOnState) {
//         _handleTextSubmitted(_textEditDefault.resultText, emoticonId: state.param);
//         BlocManager.getBloc<ShowEmoticonExampleBloc>()!.add(OffEvent());
//       }else{
//         _handleTextSubmitted(_textEditDefault.resultText);
//
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           widget.focusNode!.unfocus();
//           _textEditDefault.controller.clear();
//           widget.focusNode!.requestFocus();
//         });
//       }
//       if(chatTextOverBloc!.state is SwitchBlocOnState)
//         chatTextOverBloc!.add(OffEvent());
//     }, onChanged: (String text) {
//       //LogWidget.debug("${textEditDefault.controller.text}");
//     });
//
//     scrollController.addListener(() {
//       if (chatTextOverBloc!.state is SwitchBlocOffState) {
//         if (scrollController.position.maxScrollExtent > 0) {
//           chatTextOverBloc!.add(OnEvent());
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _textEditDefault.controller.dispose();
//     scrollController.dispose();
//
//   }
//
//   String getHintText() {
//     return L10n.inputMessage;
//   }
//
//   List<Text> getWeightedText(String text) {
//     String lead = text.substring(0, text.indexOf('['));
//     String inner = text.substring(text.indexOf('[')+1, text.indexOf(']'));
//     String tail = text.substring(text.indexOf(']')+1, text.length);
//
//     return [
//       Text(lead, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),),
//       Text(inner, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontFamily: Zeplin.robotoBold, decoration: TextDecoration.underline),),
//       Text(tail, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),),
//     ];
//   }
//
//   // 다른 이용자들의 신고로 참여제한됩니다. 문구
//
//   Widget getChatRestrictedWidget() {
//     return GestureDetector(
//       onTap: () {
//         if(OpenChatManager().isRestricted()) {
//           SquareOpenChatDialog.showRestrictedReason();
//         } else {
//           changeKeyboardTypeBloc
//               .add(ChangeKeyboardTypeForOpenChat(keyboardType: KeyboardType.none, focusNode: widget.focusNode));
//         }
//       },
//       child: Container(
//         margin: EdgeInsets.only(left: Zeplin.size(19), right: Zeplin.size(34)),
//         padding: EdgeInsets.only(top: Zeplin.size(19), left: Zeplin.size(29), bottom: Zeplin.size(19), right: Zeplin.size(63)),
//         decoration: ShapeDecoration(
//             shape: Pebble4DividedBorder(
//               color: Colors.transparent,
//               strokeWidth: 1.0,
//             ),
//             color: CustomColor.paleGrey),
//         child: Row(
//           children: getWeightedText(L10n.chatRestricted(OpenChatManager().myChannel?.restrictInfo?.restrictPeriod.periodStr ?? "0")),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return BlocBuilder<ChatTextOverBloc, SwitchBlocState>( //최하단으로 보내는 화살표용
//         bloc: chatTextOverBloc,
//         builder: (context, state) {
//           bool isRestricted = OpenChatManager().isRestricted();
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               SizedBox(width: Zeplin.size(19)),
//               if (state is SwitchBlocOnState)
//                 Opacity(
//                   opacity: 0.5,
//                   child: IconButton(
//                     icon: Icon46(Assets.img.ico_46_right_arrow_gray, color: CustomColor.stormGrey),
//                     onPressed: () {
//                       FocusScope.of(context).unfocus();
//                       chatTextOverBloc!.add(OffEvent());
//                       changeKeyboardTypeBloc.add(
//                           ChangeKeyboardTypeForOpenChat(
//                               keyboardType: isRestricted ? KeyboardType.restricted : KeyboardType.none,
//                               focusNode: widget.focusNode));
//                     },
//                     padding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     splashRadius: 20,
//                   ),
//                 ),
//               Flexible(
//                 fit: FlexFit.loose,
//                 child:
//                   isRestricted ? getChatRestrictedWidget() :
//                   Stack(
//                   alignment: Alignment.bottomRight,
//                   children: [
//                     TextField(
//                       controller: _textEditDefault.controller,
//                       onTap: () {
//                       },
//                       focusNode: widget.focusNode,
//                       style: chatTextStyle,
//                       textInputAction: TextInputAction.send,
//                       minLines: 1,
//                       maxLines: state is SwitchBlocOnState ? 3 : 1,
//                       onSubmitted: _textEditDefault.onSubmitted,
//                       onChanged: _textEditDefault.onChanged,
//                       scrollController: scrollController,
//                       onEditingComplete: () {},
//                       decoration: InputDecoration(
//                         hintText: getHintText(),
//                         hintStyle: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500),
//                         border: Pebble4DividedInputBorder(color: Colors.transparent, strokeWidth: 1.0),
//                         focusedBorder: Pebble4DividedInputBorder(color: Colors.transparent, strokeWidth: 1.0),
//                         contentPadding: EdgeInsets.only(top: Zeplin.size(19), left: Zeplin.size(29), bottom: Zeplin.size(19), right: Zeplin.size(63)),
//                         isDense: true,
//                         filled: true,
//                         fillColor: CustomColor.paleGrey,
//                       ),
//                     ),
//                     IconButton(
//                         visualDensity: VisualDensity.compact,
//                         padding: EdgeInsets.only(right: 5),
//                         icon: Icon46(Assets.img.ico_46_imti),
//                         onPressed: () {
//                           // LogWidget.debug("click emoticon");
//                           changeKeyboardTypeBloc.add(ChangeKeyboardTypeForOpenChat(keyboardType: KeyboardType.emoticon, focusNode: widget.focusNode));
//                         })
//                   ],
//                 ),
//               ),
//               SizedBox(width: Zeplin.size(14)),
//               BlocBuilder<ShowEmoticonExampleBloc, SwitchBlocState>(
//                   bloc: BlocManager.getBloc(),
//                   builder: (context, state) {
//                     return _buildSendWidget(state);
//                   }
//               ),
//               SizedBox(width: Zeplin.size(19)),
//             ],
//           );
//         }
//     );
//   }
//
//
//   Widget _buildSendWidget(SwitchBlocState emoticonShowState) {
//     return _textEditDefault.isComposing || (emoticonShowState is SwitchBlocOnState) ? Container(
//         width: Zeplin.size(95),
//         height: Zeplin.size(67),
//         child : Transform.translate(
//           offset: Offset(0, -Zeplin.size(8)),
//           child: PebbleRectButton(
//               onPressed: () {
//                 widget.scrollDefault.controller.jumpTo(0);
//                 _textEditDefault.getOnPressedSubmit(emoticonShowState is SwitchBlocOnState)?.call();
//                 chatTextOverBloc!.add(OffEvent());
//               },
//               backgroundColor: CustomColor.azureBlue,
//               strokeWidth: 0,
//               child: Text(L10n.chat_room_02_01, style: TextStyle(color: Colors.white, fontFamily: Zeplin.robotoBold, fontSize: Zeplin.size(28)))),
//         )) : Container();
//   }
//
//   void _handleTextSubmitted(String text, {String? emoticonId}) async {
//     if(emoticonId != null) {
//       messageBloc.add(SendEmoticonMessage(emoticonId, text));
//     }else{
//       messageBloc.add(SendTextMessage(text));
//     }
//   }
// }
