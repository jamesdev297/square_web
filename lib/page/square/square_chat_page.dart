import 'dart:html';

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/bloc.dart';
import 'package:square_web/bloc/change_keyboard_type_bloc.dart';
import 'package:square_web/bloc/square/square_chat_message_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/page/room/chat_page.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/chat_message_manager.dart';
import 'package:square_web/service/emoticon_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/device_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/chat/chat_skill_effect.dart';
import 'package:square_web/widget/chat/image_message.dart';
import 'package:square_web/widget/chat/square_chat_bar.dart';
import 'package:square_web/widget/chat/typing_chat_message.dart';
import 'package:square_web/widget/chat_go_bottom_button.dart';
import 'package:square_web/widget/custom_debounce.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/emoticon/desktop_emoticon_view.dart';
import 'package:square_web/widget/emoticon/example_emoticon_view.dart';
import 'package:square_web/widget/emoticon/pick_emoticon_grid.dart';
import 'package:square_web/widget/square/square_chat_header.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';
import 'package:square_web/widget/toast/toast_overlay.dart';

class SquareChatPage extends StatefulWidget with HomeWidget {
  final Key? key;
  final SquareModel squareModel;
  final String channel = "0";

  final Set<OverlayEntry> overlays = {};
  static const double chatShowMaxRatio = 0.6;
  static const double chatShowMinRatio = 0.2;


  static String name = "SquareChatPage";

  @override
  String pageName() => name;

  SquareChatPage({required this.squareModel, this.key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SquareChatPageState();

  @override
  TabCode get targetNavigator => TabCode.full;

  //TODO overnavi 적용안됨. 확인해야함
  @override
  HomeWidgetLayer get homeWidgetLayer => HomeWidgetLayer.overNavi;

  @override
  MenuPack get getMenuPack =>
      MenuPack(
        // isShowLinearGradient: true,
        /*leftMenu: Button84Type02NS(
        child: Icon46(Assets.img.ico_46_arrow_bk),
        onPressed: () => HomeNavigator.pop()
    ),*/
      );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepth;
}

class SquareChatPageState extends State<SquareChatPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollDefault _scrollDefault = ScrollDefault();
  late ChangeKeyboardTypeBloc changeKeyboardTypeBloc;
  late SquareChatMessageBloc _messageBloc;
  MessageBlocState? lastLoadedState;
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

    RoomManager().currentChatRoom = null;

    changeKeyboardTypeBloc = ChangeKeyboardTypeBloc(initialState: MeModel().isRestrictedOnSquare ? RestrictedTypeState() : null);

    WidgetsBinding.instance.addObserver(this);
    LogWidget.debug("SQUARE CHATPAGE INIT / square ${widget.squareModel.squareName}");

    _messageBloc = SquareChatMessageBloc(widget.squareModel, widget.channel, changeKeyboardTypeBloc)
      ..add(FetchMessage(false));

    _scrollDefault.init(onLoadMore: () {
      _messageBloc.add(FetchMessage(false));
    }, onBottom: () {
      _messageBloc.add(FetchMessage(true));
    }, onTop: () {
      if(isWebPc)
        _scrollTopDebounce(() {
          SquareTransition.skipToBuildSelectionArea.value = false;
        });
    });

    LogWidget.debug("onPanelOpened");

    isWebPc = kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux);
    if(isWebPc) {
      _boxConstraints = pcChatPageBoxConstraints;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    changeKeyboardTypeBloc.close();
    _messageBloc.close();
    _scrollEndDebounce.dispose();
    _scrollTopDebounce.dispose();
    BlocManager.getBloc<ShowEmoticonExampleBloc>()!.add(OffEvent());
    imageMsgCache.clear();
    // RoomManager().reloadUpdatedRooms();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSideNavi = MediaQuery.of(context).size.width >= DeviceUtil.minSideNaviWidth;
    LogWidget.debug("square chat rebuild ${widget.squareModel}");

    return Container(
      constraints: _boxConstraints,
      color: Colors.white,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();

              if(!MeModel().isRestrictedOnSquare)
                changeKeyboardTypeBloc.add(
                    ChangeKeyboardType(keyboardType: KeyboardType.none));

              HomeNavigator.tapOutSideOfTwoDepthPopUp();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SquareChatHeader(isSideNavi: isSideNavi, squareModel: widget.squareModel, channel: widget.channel, parent: widget, leaveFunc: leaveFunc, messageBloc: _messageBloc),
                Expanded(
                  child: BlocBuilder<SquareChatMessageBloc, MessageBlocState>(
                      bloc: _messageBloc,
                      builder: (context, state) {
                        // LogWidget.debug("square messageBlocState is $state");
                        if (state is MessageError) {
                          if(lastLoadedState != null) {
                            state = lastLoadedState!;
                          } else {
                            return Center(
                              child: Text(L10n.common_58_service_error, textAlign: TextAlign.center),
                            );
                          }
                        }
                        if (state is MessageUninitialized) {
                          return Center(
                            child: SquareCircularProgressIndicator(
                                progressIndicatorSize: ProgressIndicatorSize.size60),
                          );
                        }
                        if (state is MessageLoaded) {
                          lastLoadedState = state;

                          // LogWidget.debug("SquareChatPageInternalState MessageLoaded!");
                          if(state.aiLimitReached != null) {
                            AiLimitReachedInfo aiLimitInfo = state.aiLimitReached!;
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              ToastOverlay.show(buildContext: context, rootWidget: this.widget,
                                  textColor: Colors.white,
                                  backgroundColor: CustomColor.darkGrey.withOpacity(0.7),
                                  duration: Duration(seconds: 2),
                                  text: "${L10n.square_01_46_ai_chat_limit_reached_toast} : ${aiLimitInfo.aiModel}");
                            });
                          }

                          List<MessageModel> messageList = state.sendingMessages!.toList() + state.messages!.toList();

                          return _buildDropZone(messageList);
                        }
                        return Container();
                      }),
                ),

                if(widget.squareModel.squareType == SquareType.nft || widget.squareModel.joined == true)
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(bottom: Zeplin.size(19)),
                    child: BlocBuilder<ChangeKeyboardTypeBloc, ChangeKeyboardTypeState>(
                      bloc: changeKeyboardTypeBloc,
                      builder: (context, changeKeyboardTypeState) {
                        bool isMobile = screenWidthNotifier.value < maxWidthMobile;
                        List<Widget> children = [];
                        if (!(changeKeyboardTypeState is RestrictedTypeState)) {
                          children.add(Container(
                              color: Colors.white,
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(value: changeKeyboardTypeBloc),
                                BlocProvider.value(value: _messageBloc),
                              ], child: SquareChatBar(_scrollDefault, widget.squareModel, widget.channel, isMobileWeb: DeviceUtil.isMobileWeb))));
                        }

                        if (changeKeyboardTypeState is RestrictedTypeState) {
                          children.add(
                              GestureDetector(
                                onTap: () {
                                  if (!MeModel().isRestrictedOnSquare) {
                                    changeKeyboardTypeBloc.add(
                                        ChangeKeyboardType(keyboardType: KeyboardType.none));
                                    return;
                                  }
                                  SquareManager().showRestrictedDialog();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Zeplin.size(17)),
                                  child: Container(
                                    height: Zeplin.size(80),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: Zeplin.size(26)),
                                    decoration: BoxDecoration(
                                        color: CustomColor.paleGrey, borderRadius: BorderRadius.circular(15)),
                                    child: Text(L10n.square_01_35_restricted_chat_bar_hint,
                                        style: TextStyle(color: Colors.grey, fontSize: Zeplin.size(28))),
                                  ),
                                ),
                              ));
                        }

                        if ((changeKeyboardTypeState is EmoticonTypeState) && isMobile) {
                          children.add(Container(
                              padding: EdgeInsets.only(top: Zeplin.size(19)),
                              height: Zeplin.size(400),
                              child: PickEmoticonGrid(true)));
                        }
                        if (changeKeyboardTypeState is DefaultTypeState) {
                          children.add(Container(height: DeviceUtil.bottomPaddingHeight));
                        }

                        return Column(children: children);
                      },
                    ),
                  )
                else
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        if(await SquareManager().joinSquare(widget.squareModel)) {
                          widget.squareModel.joined = true;
                          // widget.squareModel.memberCount = (widget.squareModel.memberCount ?? 0) + 1;
                          setState(() {});
                        }
                      },
                      child: Container(
                        color: CustomColor.paleGrey,
                        height: Zeplin.size(121) + DeviceUtil.bottomPaddingHeight,
                        child: Center(
                          child: Text(L10n.square_01_42_join),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          ChatSkillEffect(),
        ],
      ),
    );
  }

  void leaveFunc() async {
    if(await SquareManager().leaveSquare(widget.squareModel)) {
      widget.squareModel.joined = false;
      if(widget.squareModel.memberCount != null && widget.squareModel.memberCount! > 0)
        // widget.squareModel.memberCount = widget.squareModel.memberCount! -1;
      setState(() {});
    }
  }

  Widget _buildDropZone(List<MessageModel> messageList) {
    if(widget.squareModel.joined == true)
      return DropZone(
        onDrop: (List<File>? files) async {

          if (files == null || files.isEmpty)
            return;

          if (files.length > maxSendImageCount) {

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

          for (File file in files) {
            if (file.type.contains("image/")) {
              final reader = FileReader();
              reader.readAsArrayBuffer(file);
              await reader.onLoad.first;
              _messageBloc.add(SendImageMessage(bytes: reader.result as Uint8List));
            }
          }
        },
        child: _buildChatList(messageList),
      );

    return _buildChatList(messageList);
  }
  
  Widget _buildChatList(List<MessageModel> messageList) {
    
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              if(SquareTransition.skipToBuildSelectionArea.value == false) {
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
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: _scrollDefault.controller,
            reverse: true,
            children: messageItemList(messageList),
            padding: EdgeInsets.only(
                bottom: Zeplin.size(16)),
          ),
        ),
        // SquareModel.isAiChatSquare(widget.squareModel.squareId) ? AiChatStatusBar(widget.squareModel.squareId) : Container(),
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
                      if(isWebPc) {
                        SquareTransition.skipToBuildSelectionArea.value = true;
                      }

                      _scrollDefault.controller.animateTo(0, duration: Duration(milliseconds: 100), curve: Curves.linear);
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
    );
  }

  List<Widget> messageItemList(List<MessageModel> messageList) {

    List<Widget> messageItemList = [];

    for(int index = 0; index < messageList.length; index++) {
      String? printedMsgTime;
      if(messageList[index].messageType != MessageType.typing &&
          (index == 0
              || messageList[index - 1].sender!.playerId != messageList[index].sender!.playerId
              || messageList[index - 1].messageType == MessageType.system
              || messageList[index - 1].localTimeStr != messageList[index].localTimeStr
          )
      ) {
        printedMsgTime = messageList[index].localTimeStr;
      }

      bool printContact = false;
      if (index == messageList.length - 1
          || messageList[index + 1].sender!.playerId != messageList[index].sender!.playerId
          || messageList[index + 1].messageType == MessageType.system
          || messageList[index + 1].localTimeStr != messageList[index].localTimeStr) {
        printContact = true;
      }

      messageItemList.add(TypingChatMessage(
          key: ValueKey("${messageList[index].messageId}"),
          messageModel: messageList[index],
          vsyncTickerProvider: this, printedMessageTime: printedMsgTime, printContact: printContact, messageBloc: _messageBloc, rootWidget: widget));
    }

    return messageItemList;
  }

}



// class AiChatStatusBar extends StatefulWidget {
//   final String squareId;
//
//   const AiChatStatusBar(this.squareId, {
//   super.key,
//   });
//
//   @override
//   State<AiChatStatusBar> createState() => _AiChatStatusBarState();
// }
//
// class _AiChatStatusBarState extends State<AiChatStatusBar> with SingleTickerProviderStateMixin {
//   Timer? backgroundTimer;
//   Color backgroundColor = CustomColor.azureBlue;
//
//   @override
//   void dispose() {
//     backgroundTimer?.cancel();
//     backgroundTimer = null;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ValueNotifier<AiChatSquareStatus?> status = SquareManager().getAiChatSquareStatus(widget.squareId);
//     return ValueListenableBuilder<AiChatSquareStatus?>(valueListenable: status, builder: ((context, value, child) {
//       if(value == AiChatSquareStatus.RUNNING) {
//         backgroundTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//           if(backgroundColor == CustomColor.azureBlue) {
//             backgroundColor = Colors.lightBlueAccent;
//           } else {
//             backgroundColor = CustomColor.azureBlue;
//           }
//           if(backgroundTimer == null) return ;
//           if(mounted) {
//             setState(() {
//
//             });
//           }
//         });
//
//         return Align(
//             alignment: Alignment.topCenter,
//             child: Container(
//               height: 40,
//               child: Stack(
//                 children: [
//                   Positioned.fill(child: AnimatedContainer(
//                     duration: Duration(seconds: 1),
//                     color: backgroundColor,
//                   )),
//                   Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Chat GPT is thinking about the answer...", style: TextStyle(color: Colors.white),),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ));
//       }
//       return Container();
//     }));
//   }
// }
