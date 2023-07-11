import 'dart:async';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
import 'package:square_web/bloc/chat_message_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/page/room/chat_page.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';

class ChatBar extends StatefulWidget {
  final ScrollDefault scrollDefault;
  final bool isMobileWeb;

  ChatBar(this.scrollDefault, { required this.isMobileWeb });

  @override
  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> with TickerProviderStateMixin {
  TextEditingDefault textEditDefault = TextEditingDefault();
  late RoomModel roomModel;
  late ChatMessageBloc messageBloc;
  late ChangeKeyboardTypeBloc changeKeyboardTypeBloc;

  Timer? sendTypingTimer;
  bool isSendTypingState = false;

  bool isActiveSendBtn = false;

  Timer? sendTermTimer;
  int sentMsgCount = 0;
  Timer? blockSendBtnTimer;
  bool isBlockedSendBtn = false;
  ScrollController scrollController = ScrollController();
  bool isMultiLine = false;

  late FocusNode keyboardFocus;
  int twiceSubmitTime = 0;
  bool isSubmit = false;

  void sendMessage() {
    SwitchBlocState emoticonShowState = BlocManager.getBloc<ShowEmoticonExampleBloc>()!.state;

    if ((textEditDefault.isComposing == false || textEditDefault.controller.text.trim().isEmpty) && !(emoticonShowState is SwitchBlocOnState)) return;

    widget.scrollDefault.controller.jumpTo(0);
    textEditDefault.getOnPressedSubmit(emoticonShowState is SwitchBlocOnState)?.call();
    isMultiLine = false;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      textEditDefault.controller.clear();
      isSubmit = false;
      setState(() {});
    });
  }

  KeyEventResult mobileOnKeyEvent(FocusNode node, KeyEvent event) {

    if(event is KeyDownEvent && isMultiLine == false && (event.physicalKey == PhysicalKeyboardKey.enter || event.physicalKey == PhysicalKeyboardKey.numpadEnter || event.logicalKey.keyId == 4294967309)) {
      isMultiLine = true;
      setState(() {});
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult desktopOnKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {

      // message send
      if (twiceSubmitTime != event.timeStamp.inMilliseconds && (event.physicalKey == PhysicalKeyboardKey.enter || event.physicalKey == PhysicalKeyboardKey.numpadEnter) && !HardwareKeyboard.instance.physicalKeysPressed.any((el) => <PhysicalKeyboardKey>{
        PhysicalKeyboardKey.shiftLeft,
        PhysicalKeyboardKey.shiftRight,
        PhysicalKeyboardKey.controlLeft,
        PhysicalKeyboardKey.controlRight,
        PhysicalKeyboardKey.altLeft,
        PhysicalKeyboardKey.altRight,
      }.contains(el))) {
        twiceSubmitTime = event.timeStamp.inMilliseconds;
        sendMessage();

        return KeyEventResult.handled;
      }

      //shift enter 인 경우
      if (twiceSubmitTime != event.timeStamp.inMilliseconds && (event.physicalKey == PhysicalKeyboardKey.enter || event.physicalKey == PhysicalKeyboardKey.numpadEnter) && HardwareKeyboard.instance.physicalKeysPressed.any((el) => <PhysicalKeyboardKey>{
        PhysicalKeyboardKey.shiftLeft,
        PhysicalKeyboardKey.shiftRight,
      }.contains(el))) {
        twiceSubmitTime = event.timeStamp.inMilliseconds;
        setState(() {
          isMultiLine = true;
        });

        return KeyEventResult.ignored;
      }

      // //control or alt enter 인 경우
      // if (twiceSubmitTime != event.timeStamp.inMilliseconds && event.physicalKey == PhysicalKeyboardKey.enter && HardwareKeyboard.instance.physicalKeysPressed.any((el) => <PhysicalKeyboardKey>{
      //   PhysicalKeyboardKey.controlLeft,
      //   PhysicalKeyboardKey.controlRight,
      //   PhysicalKeyboardKey.altLeft,
      //   PhysicalKeyboardKey.altRight,
      // }.contains(el))) {
      //
      //   return KeyEventResult.handled;
      // }
      return KeyEventResult.ignored;
    }

    if(event is KeyRepeatEvent) {
      if (twiceSubmitTime != event.timeStamp.inMilliseconds && (event.physicalKey == PhysicalKeyboardKey.enter || event.physicalKey == PhysicalKeyboardKey.numpadEnter) && !HardwareKeyboard.instance.physicalKeysPressed.any((el) => <PhysicalKeyboardKey>{
        PhysicalKeyboardKey.shiftLeft,
        PhysicalKeyboardKey.shiftRight,
        PhysicalKeyboardKey.controlLeft,
        PhysicalKeyboardKey.controlRight,
        PhysicalKeyboardKey.altLeft,
        PhysicalKeyboardKey.altRight,
      }.contains(el))) {
        twiceSubmitTime = event.timeStamp.inMilliseconds;
        sendMessage();

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();

    keyboardFocus = FocusNode(onKeyEvent: widget.isMobileWeb ? mobileOnKeyEvent : desktopOnKeyEvent);

    messageBloc = BlocProvider.of(context);
    changeKeyboardTypeBloc = BlocProvider.of(context);

    roomModel = messageBloc.model;

    textEditDefault.init("messege", this, onPressedSubmit: () {
      if (isBlockedSendBtn) return;

      checkBlockSendBtn();
      _startSendTermTimer();
      SwitchBlocState state = BlocManager.getBloc<ShowEmoticonExampleBloc>()!.state;
      if (state is SwitchBlocOnState) {
        _handleTextSubmitted(textEditDefault.resultText, emoticonId: state.param);
        BlocManager.getBloc<ShowEmoticonExampleBloc>()!.add(OffEvent());
      } else {
        _handleTextSubmitted(textEditDefault.resultText);
      }
      isMultiLine = false;

      sendTypingTimer?.cancel();

      if(!widget.isMobileWeb && changeKeyboardTypeBloc.state is EmoticonTypeState) {
        changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.none));
      }

    }, onChanged: (String text) {
      isSendTypingState = false;

      if ((sendTypingTimer == null || !sendTypingTimer!.isActive) && !(roomModel.isAiChat == true)) {
        _startTimerPeriodic(0);
      }

      if(text.isEmpty) {
        if (roomModel.isTwin && !(roomModel.isAiChat == true))
          RoomManager().typingForTwinRoom(roomModel.roomId!, false);
        sendTypingTimer?.cancel();

        isMultiLine = false;
      }
    });

    if(widget.isMobileWeb) {
      keyboardFocus.addListener(() {
        LogWidget.debug("Has focus: ${keyboardFocus.hasFocus}");
        if (keyboardFocus.hasFocus)
          changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.none));
      });
    }

    scrollController.addListener(addListenerScroll);
  }

  void addListenerScroll() {
    if (isMultiLine == false && scrollController.position.maxScrollExtent > 0) {
      isMultiLine = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    sendTypingTimer?.cancel();
    blockSendBtnTimer?.cancel();
    sendTermTimer?.cancel();
  }

  void _startTimerPeriodic(int sec) {
    sendTypingTimer = Timer.periodic(Duration(seconds: sec), (Timer timer) async {
      if (roomModel.isTwin && isSendTypingState == false) {
        isSendTypingState = true;
        RoomManager().typingForTwinRoom(roomModel.roomId!, true);
        timer.cancel();
      }

      if (sec == 0) {
        timer.cancel();
        _startTimerPeriodic(sendTypingTime);
      }
    });
  }

  void _startSendTermTimer() {
    if (sendTermTimer == null || sendTermTimer!.isActive == false) {
      sendTermTimer = Timer(Duration(seconds: sendTermSeconds), () {
        sentMsgCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(top: Zeplin.size(10)),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: Zeplin.size(15, isPcSize: true)),
          if (widget.isMobileWeb && isMultiLine == true)
            IconButton(
              icon: Icon46(Assets.img.ico_46_arro),
              onPressed: () => setState(() {
                isMultiLine = false;
              }),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              splashRadius: 20,
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: Zeplin.size(8)),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon46(Assets.img.ico_46_camera_gy),
                    onPressed: callCamera,
                    padding: EdgeInsets.fromLTRB(0, 0, Zeplin.size(7), 0),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: Icon46(Assets.img.ico_46_picture_gy),
                    onPressed: () async {
                      final List<XFile>? images = await ImagePicker().pickMultiImage();
                      if (images!.length > maxSendImageCount) {

                        SquareDefaultDialog.showSquareDialog(
                            title: L10n.common_52_limitSendImage,
                            content: RichText(
                              text: TextSpan(
                                  children: StringUtil.parseColorText(L10n.common_53_limitSendImageContent(maxSendImageCount), CustomColor.azureBlue, boldToAccent: false, fontSize: Zeplin.size(26)),
                                  style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                              ),
                              textAlign: TextAlign.center,
                            ),
                            button1Text: L10n.common_02_confirm
                        );
                        return;
                      }

                      FullScreenSpinner.show(context);
                      messageBloc.add(SendImageMessage(images: images));
                    },
                    padding: EdgeInsets.fromLTRB(Zeplin.size(7), 0, Zeplin.size(15, isPcSize: true), 0),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CustomColor.paleGrey,
                borderRadius: BorderRadius.circular(13.0)
              ),
              child: TextFormField(
                focusNode: keyboardFocus,
                scrollController: scrollController,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                controller: textEditDefault.controller,
                style: chatTextFieldStyle,
                textInputAction: TextInputAction.none,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                cursorWidth: 3,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: false,
                onChanged: textEditDefault.onChanged,
                onTap: () {
                  if(widget.isMobileWeb)
                    changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.none));
                  addListenerScroll.call();
                },
                onFieldSubmitted: (_) {
                  if(isSubmit == true)
                    textEditDefault.controller.clear();
                },
                maxLength: maxTextLength,
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  suffixIcon: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: BlocBuilder(
                            bloc: changeKeyboardTypeBloc,
                            builder: (context, state) {
                              if(state is EmoticonTypeState) {
                                return Icon46(Assets.img.ico_46_imti, color: CustomColor.azureBlue);
                              }
                              return Icon46(Assets.img.ico_46_imti);
                            },
                          ),
                        ),
                        onTap: () {
                          if (changeKeyboardTypeBloc.state is EmoticonTypeState) {
                            changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.none));
                          } else {
                            changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.emoticon));

                            if(widget.isMobileWeb)
                              FocusScope.of(context).unfocus();
                          }
                        }),
                  ),
                  counterText: "",
                  hintText: L10n.chat_room_01_01_message_user,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: Zeplin.size(28)),
                  contentPadding: EdgeInsets.only(left: Zeplin.size(29), top: Zeplin.size(34), bottom: Zeplin.size(20)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counter: isMultiLine ? Container(
                    decoration: BoxDecoration(
                      color: CustomColor.paleGrey,
                      borderRadius: BorderRadius.circular(13.0)
                    ),
                    padding: EdgeInsets.only(bottom: Zeplin.size(10)),
                    alignment: Alignment.centerLeft,
                    child: Text("${textEditDefault.resultText.length}/$maxTextLength", style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(14, isPcSize: true), fontWeight: FontWeight.w500)),
                  ) : null,
                ),
              ),
            ),
          ),
          SizedBox(width: Zeplin.size(14)),
          BlocConsumer<ShowEmoticonExampleBloc, SwitchBlocState>(
              bloc: BlocManager.getBloc(),
              listener: (context, state) {
                if(state is SwitchBlocOnState) {
                  keyboardFocus.requestFocus();
                }
              },
              builder: (context, state) {
                return _buildSendWidget(state);
              }
          ),
          SizedBox(width: Zeplin.size(19)),
        ],
      ),
    );
  }

  void callCamera() async {
    if(widget.isMobileWeb) {
      final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
      Uint8List? bytes = await photo?.readAsBytes();
      if (bytes != null) cropImage(bytes);

      return;
    }

    HomeNavigator.push(RoutePaths.common.camera, popAction: (value) {
      if (value != null) {
        cropImage(value as Uint8List);
      }
    });
  }

  void checkBlockSendBtn() {
    if (sentMsgCount > maxSentMsgCount && isBlockedSendBtn == false) {
      SquareDefaultDialog.showSquareDialog(
        showShadow: true,
        title: L10n.popup_07_block_input_title,
        content: Text(L10n.popup_08_block_input_content,
          style: TextStyle(fontSize: Zeplin.size(13, isPcSize: true),
              fontWeight: FontWeight.w500,
              color: CustomColor.grey4
          ),),
        button1Text: L10n.common_02_confirm,
      );

      isBlockedSendBtn = true;
      blockSendBtnTimer = Timer(Duration(seconds: blockSenBtnSeconds), () {
        isBlockedSendBtn = false;
        sentMsgCount = 0;
        if (mounted) setState(() {});
      });
    }
    sentMsgCount += 1;
  }

  void cropImage(Uint8List bytes) {
    HomeNavigator.push(RoutePaths.common.crop, arguments: {
      "bytes": bytes,
      "cropType": CropType.message,
      "isCameraBeforePage": true
    }, popAction: (value) async {
      FullScreenSpinner.hide();

      if (value == true) {
        callCamera();
        return;
      }
      if (value != null)
        messageBloc.add(SendImageMessage(bytes: (value as Map)["bytes"] as Uint8List));
    });
  }

  Widget _buildSendWidget(SwitchBlocState emoticonShowState) {
    isActiveSendBtn = isBlockedSendBtn == false && !(emoticonShowState is SwitchBlocOffState && textEditDefault.isComposing == false);

    return TextFieldTapRegion(
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: Zeplin.size(43, isPcSize: true),
        height: Zeplin.size(31, isPcSize: true),
        child: PebbleRectButton(
          onPressed: isActiveSendBtn ? () {
            sendMessage();
          } : null,
          backgroundColor: isActiveSendBtn ? CustomColor.azureBlue : CustomColor.paleGrey,
          borderColor: isActiveSendBtn ? CustomColor.azureBlue : CustomColor.paleGrey,
          child: Text(L10n.chat_room_02_01_send, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Zeplin.size(12, isPcSize: true)))
        )
      ),
    );
  }

  void _handleTextSubmitted(String text, {String? emoticonId}) async {
    isSubmit = true;
    if (emoticonId != null) {
      messageBloc.add(SendEmoticonMessage(emoticonId, text));
    } else {
      messageBloc.add(SendTextMessage(text));
    }
  }
}