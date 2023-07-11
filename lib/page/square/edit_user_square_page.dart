import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/ai/select_ai_player_bloc.dart';
import 'package:square_web/bloc/square/square_bloc.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/square/user_square_data.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/http_resource_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/square/edit_square_image.dart';
import 'package:square_web/widget/profile/profile_image.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/text_field/edit_profile_text_field.dart';

class EditUserSquarePage extends StatefulWidget with HomeWidget {
  final SquareModel squareModel;
  Function(int) onNext;

  EditUserSquarePage({Key? key, required this.squareModel, required this.onNext}) : super(key: key);

  @override
  _EditUserSquarePageState createState() => _EditUserSquarePageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    centerMenu: Text(L10n.ai_01_edit_ai_square, style: centerTitleTextStyle),
  );

  @override
  String pageName() => "EditSquarePage";

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;
}

class _EditUserSquarePageState extends State<EditUserSquarePage> {

  TextStyle _titleTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26));
  TextStyle _validTextStyle = TextStyle(color: CustomColor.wrongInputRed, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24));

  TextEditingDefault _squareNameTextEditDefault = TextEditingDefault();
  bool validSquareName = false;

  FocusNode squareNameFocusNode = FocusNode();

  late UserSquareData originData = UserSquareData.fromSquare(widget.squareModel);
  late UserSquareData updatedData = UserSquareData.fromSquare(widget.squareModel);
  final String squareName = "squareName";

  @override
  void initState() {
    initTextEditDefault(_squareNameTextEditDefault, squareName, updatedData.squareName!);
    super.initState();
  }

  void initTextEditDefault(TextEditingDefault textEditingDefault, String name, String value) {
    textEditingDefault.init(name, this,
      onPressedSubmit: () async {},
      onChanged: (String text) {
        textEditingDefault.resultText = text;
        updatedData.squareName = text;

        if(name == squareName) {
          validSquareName = false;
        }
      },
    );
    textEditingDefault.controller.text = value;
    textEditingDefault.onChanged(value);
    textEditingDefault.controller.selection = TextSelection.fromPosition(TextPosition(offset: textEditingDefault.controller.text.characters.length));

  }

  void onRandomize() {
    // updatedData.squareImgUrl = Config.randomProfileImgUrl;
    // updatedData.tempSquareImgData = null;
    // setState(() {});
  }


  @override
  void dispose() {
    squareNameFocusNode.dispose();
    _squareNameTextEditDefault.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: Zeplin.size(34), horizontal: Zeplin.size(25)),
              child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {

                          if(updatedData.squareName != originData.squareName || updatedData.tempSquareImgData?.isNotEmpty == true || updatedData.aiPlayerId != originData.aiPlayerId
                              || originData.squareImgUrl != updatedData.squareImgUrl) {
                            SquareDefaultDialog.showSquareDialog(
                                title: L10n.popup_02_edit_profile_title,
                                content: Text(L10n.popup_03_edit_profile_content),
                                button1Text: L10n.common_03_cancel,
                                button2Text: L10n.common_02_confirm,
                                button2Action: () {
                                  SquareDefaultDialog.closeDialog().call();
                                  HomeNavigator.pop();
                                }
                            );
                            return;
                          }

                          HomeNavigator.pop();
                        },
                        child: Icon46(Assets.img.ico_46_arrow_bk),
                      ),
                    ),
                    Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () {
                            if(!_squareNameTextEditDefault.isComposing) {
                              validSquareName = true;
                              setState(() {});
                              return;
                            }

                            onEdit();
                          },
                          child: Center(child: Text(L10n.common_63_save, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: CustomColor.azureBlue)))),
                    )
                  ]
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Center(child: EditSquareImage(squareImgUrl: updatedData.squareImgUrl, tempImageData: updatedData.tempSquareImgData, successFunc: (value) {
                    if(value == null) {
                      FullScreenSpinner.hide();
                      return;
                    }

                    if(value == false) {
                      updatedData.tempSquareImgData = null;
                    } else {
                      updatedData.tempSquareImgData = value['bytes'];
                    }

                    FullScreenSpinner.hide();
                    setState(() {});

                  }, onRandomize: onRandomize)),
                  SizedBox(height: Zeplin.size(60)),
                  FocusTraversalGroup(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: Row(
                            children: [
                              Text(L10n.ai_01_square_name, style: _titleTextStyle),
                              SizedBox(width: Zeplin.size(10)),
                              Icon14(Assets.img.ico_10_im),
                              Spacer(),
                              if(validSquareName == true)
                                Text(L10n.feedback_01_please_fill_out, style: _validTextStyle)
                            ],
                          ),
                        ),
                        SizedBox(height: Zeplin.size(20)),
                        FocusTraversalOrder(
                          order: NumericFocusOrder(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                            child: EditProfileTextField(
                              textEditingDefault: _squareNameTextEditDefault,
                              maxLength: 45,
                              hintText: "",
                              focusNode: squareNameFocusNode,
                            ),
                          ),
                        ),
                        SizedBox(height: Zeplin.size(40)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: Row(
                            children: [
                              Text(L10n.profile_square_ai_member, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(27), fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                       /* SizedBox(height: Zeplin.size(28)),
                        BlocBuilder<SelectAiPlayerBloc, SelectAiPlayerBlocState>(
                            bloc: widget.selectAiPlayerBloc,
                            builder: (context, state) {
                              if(state is SelectAiPlayerLoaded) {
                                updatedData.aiPlayerId = state.selectedAiPlayer.playerId;
                                return _buildSelectedAiPlayer(state.selectedAiPlayer);
                              }
                              return Container();
                            }
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAiPlayer(ContactModel aiPlayer) {
    return Container(
      color: Colors.white,
      height: Zeplin.size(128),
      padding: EdgeInsets.only(left: Zeplin.size(33), right: Zeplin.size(33), top: Zeplin.size(19), bottom: Zeplin.size(19)),
      child: Row(
        children: <Widget>[
          ProfileImage(contactModel: aiPlayer, size: 93, isEdit: false),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(aiPlayer.smallerName, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: CustomColor.darkGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      SizedBox(height: Zeplin.size(7)),
                      Text(aiPlayer.statusMessage ?? "", style: TextStyle(fontSize: Zeplin.size(24), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                SizedBox(
                  child: PebbleRectButton(
                    borderColor: CustomColor.azureBlue,
                    backgroundColor: CustomColor.azureBlue,
                    onPressed: () => widget.onNext.call(1),
                    child: Center(child: Text(L10n.ai_01_change, style: TextStyle(color: Colors.white, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500))),
                  ),
                  width: Zeplin.size(104),
                  height: Zeplin.size(60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onEdit() async {

    FullScreenSpinner.show(context);

    if(updatedData.tempSquareImgData != null) {
      await SquareManager().uploadThumbnailSquare(updatedData.squareId!, updatedData.tempSquareImgData!);
    } else if(updatedData.squareImgUrl != originData.squareImgUrl) {
      Uint8List? tempSquareImgData = await HttpResourceUtil.downloadBytes(updatedData.squareImgUrl!);
      await SquareManager().uploadThumbnailSquare(updatedData.squareId!, tempSquareImgData!);
    }

    bool result = await SquareManager().editUserSquare(updatedData.squareId!,
      squareName: updatedData.squareName != originData.squareName ? updatedData.squareName : null,
      aiPlayerId: updatedData.aiPlayerId != originData.aiPlayerId ? updatedData.aiPlayerId : null,
    );

    if(result == false) {
      LogWidget.error("edit user square err");
      FullScreenSpinner.hide();
      return;
    }

    HomeNavigator.pop();
    HomeNavigator.clearTwoDepthPopUp();
    RoomManager().popActionRoom();
    SquareListPageHome.isIconView = false;

    SquareModel? squareModel = await SquareManager().getSquare(updatedData.squareId!);

    FullScreenSpinner.hide();
    if(squareModel == null)
      return;

    BlocManager.getBloc<SecretSquareBloc>()?.add(InitSquare());
    HomeNavigator.push(RoutePaths.square.squareChat, arguments: squareModel);
  }
}
