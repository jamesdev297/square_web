import 'dart:html';

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
import 'package:square_web/bloc/chat_message_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/emoticon_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/chat/chat_bar.dart';
import 'package:square_web/widget/chat/chat_header.dart';
import 'package:square_web/widget/chat/chat_skill_effect.dart';
import 'package:square_web/widget/chat/image_message.dart';
import 'package:square_web/widget/chat/no_chat_bar.dart';
import 'package:square_web/widget/chat/typing_chat_message.dart';
import 'package:square_web/widget/chat_go_bottom_button.dart';
import 'package:square_web/widget/custom_debounce.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/emoticon/desktop_emoticon_view.dart';
import 'package:square_web/widget/emoticon/example_emoticon_view.dart';
import 'package:square_web/widget/emoticon/pick_emoticon_grid.dart';
import 'package:square_web/widget/popup/square_pop_up_menu.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class ChatPage extends StatefulWidget with HomeWidget {
  final Key? key;
  final RoomModel roomModel;

  ChatPage({required this.roomModel, this.key}) : super(key: key);

  static String name = "ChatPage";

  @override
  String pageName() => name;

  @override
  State<StatefulWidget> createState() => ChatPageState();

  @override
  Future<void> onTopWidgetAction() async {
  }

  @override
  MenuPack get getMenuPack =>  MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepth;
}

enum KeyboardType {
  keyboard,
  emoticon,
  album,
  restricted,
  none,
}

class ChatPageState extends State<ChatPage> with TickerProviderStateMixin, WidgetsBindingObserver {

  final ScrollDefault _scrollDefault = ScrollDefault();
  late ChangeKeyboardTypeBloc changeKeyboardTypeBloc;
  late ChatMessageBloc _messageBloc;
  late String targetPlayerId;
  BoxConstraints? _boxConstraints;
  CustomDebounce _scrollEndDebounce = CustomDebounce(Duration(milliseconds: 700));
  CustomDebounce _scrollTopDebounce = CustomDebounce(Duration(milliseconds: 200));
  bool isWebPc = false;

  @override
  void initState() {
    super.initState();
    EmoticonManager().clearEmoticonSprite();
    ChatMessageManager().clearCache();
    ChatMessageManager().registerTickerProvider(this);

    if(widget.roomModel.roomId != null)
      BlocManager.getBloc<BlueDotBloc>()!.add(RemoveKey(naviCode: TabCode.chat, key: BlueDotKey.room(widget.roomModel.roomId!)));

    targetPlayerId = RoomManager().getTargetPlayerIdFromTwinRoomId(widget.roomModel.roomId!);

    WidgetsBinding.instance.addObserver(this);
    LogWidget.debug("CHATPAGE INIT / roomId: ${widget.roomModel.roomId} / roomName: ${widget.roomModel.searchName}");

    changeKeyboardTypeBloc = ChangeKeyboardTypeBloc();
    RoomManager().currentChatRoom = widget.roomModel;
    _messageBloc = ChatMessageBloc(widget.roomModel)..add(FetchMessage(true));
    RoomManager().currentMessageBloc = _messageBloc;

    LogWidget.debug("onPanelOpened");

    screenWidthNotifier.addListener(() {
      SquarePopUpMenu.hide;
    });

    LogWidget.debug("defaultTargetPlatform: ${defaultTargetPlatform}");
    isWebPc = kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux);
    if(isWebPc) {
      _boxConstraints = pcChatPageBoxConstraints;
    }

    _scrollDefault.init(onTop: () {
      if(isWebPc)
        _scrollTopDebounce(() {
          SquareTransition.skipToBuildSelectionArea.value = false;
        });
      _messageBloc.add(FetchMessage(false));
    });
  }

  @override
  void dispose() {
    changeKeyboardTypeBloc.close();
    _messageBloc.close();
    WidgetsBinding.instance.removeObserver(this);
    _scrollDefault.dispose();
    _scrollEndDebounce.dispose();
    _scrollTopDebounce.dispose();
    imageMsgCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatPageBloc, UpdateState>(
      bloc: BlocManager.getBloc(),
      builder: (context, state) {
        return Container(
          constraints: _boxConstraints,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Column(
                  children: [
                    ChatHeader(room: widget.roomModel, messageBloc: _messageBloc),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if(!changeKeyboardTypeBloc.isClosed) {
                            changeKeyboardTypeBloc.add(ChangeKeyboardType(keyboardType: KeyboardType.none));
                          }
                          HomeNavigator.tapOutSideOfTwoDepthPopUp();
                        },
                        child: BlocBuilder<ChatMessageBloc, MessageBlocState>(
                          bloc: _messageBloc,
                          builder: (context, state) {
                            LogWidget.debug("messageBlocState is $state");
                            if (state is MessageError) {
                              return Center(child: Text(L10n.common_58_service_error, textAlign: TextAlign.center));
                            }
                            if (state is MessageUninitialized) {
                              return Center(
                                child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size60),
                              );
                            }
                            if (state is MessageLoaded) {
                              LogWidget.debug("ChatPageInternalState MessageLoaded!");
                              List<MessageModel?> messageList = state.messages!.toList();

                              return DropZone(
                                onDrop: (List<File>? files) async {

                                  if(widget.roomModel.isBlocked || !(files?.isNotEmpty == true) || files?.where((e) => e.type.contains("image/") == true).toList().length == 0)
                                    return;

                                  if(files!.length > maxSendImageCount) {

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

                                  for(File file in files) {
                                    if(file.type.contains("image/")) {
                                      final reader = FileReader();
                                      reader.readAsArrayBuffer(file);
                                      await reader.onLoad.first;
                                      _messageBloc.add(SendImageMessage(bytes: reader.result as Uint8List, mimeType: file.type));
                                    }
                                  }
                                },
                                child: Stack(
                                  children: [
                                    NotificationListener<ScrollNotification>(
                                      onNotification: (scrollNotification) {
                                        if (scrollNotification is ScrollStartNotification) {
                                          if(isWebPc && SquareTransition.skipToBuildSelectionArea.value == false) {
                                            SquareTransition.skipToBuildSelectionArea.value = true;
                                          }
                                        } else if (scrollNotification is ScrollEndNotification) {

                                          if(isWebPc) {
                                            _scrollEndDebounce(() {
                                              if (SquareTransition.skipToBuildSelectionArea.value == true) {
                                                SquareTransition.skipToBuildSelectionArea.value = false;
                                              }
                                            });
                                          }
                                        }

                                        return false;
                                      },
                                      child: ListView.builder(
                                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                        controller: _scrollDefault.controller,
                                        reverse: true,
                                        itemBuilder: (context, index) {
                                          String? printedMsgTime;
                                          if(messageList[index]!.messageType != MessageType.typing &&
                                              (index == 0
                                                  || messageList[index - 1]!.sender!.playerId != messageList[index]!.sender!.playerId
                                                  || messageList[index - 1]!.messageType == MessageType.system
                                                  || messageList[index - 1]!.localTimeStr != messageList[index]!.localTimeStr
                                              )
                                          ) {
                                            printedMsgTime = messageList[index]!.localTimeStr;
                                          }

                                          bool printContact = false;
                                          if (index == messageList.length - 1
                                              || messageList[index + 1]!.sender!.playerId != messageList[index]!.sender!.playerId
                                              || messageList[index + 1]!.messageType == MessageType.system
                                              || messageList[index + 1]!.localTimeStr != messageList[index]!.localTimeStr) {
                                            printContact = true;
                                          }

                                          if(state.hasBottomReachedMax == false && index == messageList.length-1) {
                                            _messageBloc.add(FetchMessage(true));
                                          }

                                          return TypingChatMessage(
                                              key: ValueKey("${messageList[index]!.messageId}"),
                                              messageModel: messageList[index]!,
                                              vsyncTickerProvider: this, printedMessageTime: printedMsgTime, printContact: printContact, messageBloc: _messageBloc, rootWidget: widget);

                                        },
                                        itemCount: messageList.length,
                                        padding: EdgeInsets.only(
                                          bottom: Zeplin.size(16)),
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        Spacer(),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: Zeplin.size(19)),
                                            child: ChatGoLatestMessageButton(
                                              controller: _scrollDefault.controller,
                                              onTap: () {

                                                if(state.hasTopReachedMax == true) {
                                                  if(isWebPc) {
                                                    SquareTransition.skipToBuildSelectionArea.value = true;
                                                  }
                                                  _scrollDefault.controller.animateTo(0, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                }
                                                else {
                                                  _messageBloc.add(InitializeMessage());
                                                }
                                              }),
                                          ),
                                        ),

                                    DesktopEmoticonView(changeKeyboardTypeBloc: changeKeyboardTypeBloc),
                                    BlocBuilder<ShowEmoticonExampleBloc, SwitchBlocState>(
                                      bloc: BlocManager.getBloc<ShowEmoticonExampleBloc>(),
                                      builder: (context, state) {
                                        if(state is SwitchBlocOnState) {
                                          return Align(
                                              alignment: Alignment.bottomCenter,
                                              child: ExampleEmotionView(state.param)
                                          );
                                        }
                                        return Container();
                                      }
                                    ),
                                  ],
                                )

                                  ],
                                ),
                              );
                            }
                            return Container();
                          }
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: Zeplin.size(19)),
                      color: Colors.white,
                      child: BlocBuilder<ChangeKeyboardTypeBloc, ChangeKeyboardTypeState>(
                        bloc: changeKeyboardTypeBloc,
                        builder: (context, changeKeyboardTypeState) {

                          bool isMobile = screenWidthNotifier.value < maxWidthMobile;
                          List<Widget> children = [
                            widget.roomModel.isBlocked ? NoChatBar() :
                              MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: changeKeyboardTypeBloc),
                                  BlocProvider.value(value: _messageBloc),
                                ], child: ChatBar(_scrollDefault, isMobileWeb: DeviceUtil.isMobileWeb))
                          ];

                          if((changeKeyboardTypeState is EmoticonTypeState) && isMobile) {
                            children.add(Container(
                              padding: EdgeInsets.only(top: Zeplin.size(19)),
                              height: Zeplin.size(400),
                              child: PickEmoticonGrid(true)));
                          }
                          if(changeKeyboardTypeState is DefaultTypeState) {
                            children.add(Container(height: DeviceUtil.bottomPaddingHeight));
                          }

                          return Column(children: children);

                        },
                      ),
                    ),
                  ],
                ),
                ChatSkillEffect(),
              ],
            ),
          ),
        );
      }
    );
  }
}
