import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/feedback/suggest_model.dart';
import 'package:square_web/model/text_editing_default.dart';
import 'package:square_web/service/profile_manager.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/text_field/edit_profile_text_field.dart';
import 'package:square_web/widget/text_field/feedback_text_form_field.dart';

class SuggestPage extends StatefulWidget with HomeWidget {
  final StreamController checkStream;
  final Function? showPage;

  SuggestPage({required this.checkStream, this.showPage, Key? key}) : super(key: key);

  @override
  _SuggestPageState createState() => _SuggestPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "SuggestPage";

  @override
  bool get isInternalImplement => true;
}

class _SuggestPageState extends State<SuggestPage> {

  List<PlatformFile> selectedFileList = [];

  TextStyle _titleTextStyle = TextStyle(color: CustomColor.darkGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26));
  TextStyle _validTextStyle = TextStyle(color: CustomColor.wrongInputRed, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24));
  TextEditingDefault _emailTextEditDefault = TextEditingDefault();
  TextEditingDefault _summarizeTextEditDefault = TextEditingDefault();
  TextEditingDefault _descriptionTextEditDefault = TextEditingDefault();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _summarizeFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();

  bool isValidEmail = true;
  bool isValidEmailFormat = true;
  bool isValidSummarize = true;
  bool isValidDescription = true;

  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();

    initTextEditDefault(_emailTextEditDefault, "email");
    initTextEditDefault(_summarizeTextEditDefault, "summarize");
    initTextEditDefault(_descriptionTextEditDefault, "description");

    initFocusNode(_emailFocusNode);
    initFocusNode(_summarizeFocusNode);
    initFocusNode(_descriptionFocusNode);

    streamSubscription = widget.checkStream.stream.listen((event) {
      if(event["name"] == "suggest") {
        event["result"].complete(checkLeave());
      } else if(event["name"] == "suggest-submit") {
        submit();
      }
    });

    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.showPage?.call(0);
      }
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  void initFocusNode(FocusNode focusNode) {
    focusNode.addListener(() => setState(() {}));
  }

  void initTextEditDefault(TextEditingDefault textEditingDefault, String name) {
    textEditingDefault.init(name, this,
      onPressedSubmit: () async {},
      onChanged: (String text) {

        if(name == "email") {
          isValidEmail = true;
          isValidEmailFormat = true;
        } else if(name == "description") {
          isValidDescription = true;
        } else if(name == "summarize") {
          isValidSummarize = true;
        }

        textEditingDefault.resultText = text;

        widget.checkStream.add({
          "name" : "suggest-isActiveSubmit",
          "value" : isActiveSubmit()
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: Zeplin.size(48 + 34),),
          /*Padding(
            padding: EdgeInsets.symmetric(vertical: Zeplin.size(32), horizontal: Zeplin.size(24)),
            child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(child: Center(child: Icon46(Assets.img.ico_46_arrow_bk)),
                      onTap: () {
                        if(checkLeave() == true) {
                          SquareDefaultDialog.showSquareDialog(
                              title: L10n.feedback_01_discard,
                              content: Text(L10n.popup_12_feedback_leave
                                  , style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                                  , textAlign: TextAlign.center),
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
                    ),
                  ),
                  Spacer(),
                  Text(L10n.feedback_01_suggest, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () => submit(),
                        child: Center(child: Text(L10n.feedback_01_submit, style: TextStyle(fontSize: Zeplin.size(26), fontWeight: FontWeight.w500, color: isActiveSubmit() ? CustomColor.azureBlue : CustomColor.taupeGray)))),
                  )
                ]
            ),
          ),*/
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: Zeplin.size(60)),
                FocusTraversalGroup(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                        child: Row(
                          children: [
                            Text(L10n.feedback_01_email, style: _titleTextStyle),
                            SizedBox(width: Zeplin.size(10)),
                            Icon14(Assets.img.ico_10_im),
                            Spacer(),
                            if(isValidEmail == false)
                              Text(L10n.feedback_01_please_fill_out, style: _validTextStyle)
                            else if(isValidEmailFormat == false)
                              Text(L10n.feedback_01_please_valid_email, style: _validTextStyle)
                          ],
                        ),
                      ),
                      SizedBox(height: Zeplin.size(20)),
                      FocusTraversalOrder(
                        order: NumericFocusOrder(1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: EditProfileTextField(
                            textEditingDefault: _emailTextEditDefault,
                            maxLength: 254,
                            hintText: L10n.feedback_01_email_hint,
                            focusNode: _emailFocusNode,
                          ),
                        ),
                      ),
                      SizedBox(height: Zeplin.size(40)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                        child: Row(
                          children: [
                            Text(L10n.feedback_01_description, style: _titleTextStyle),
                            SizedBox(width: Zeplin.size(10)),
                            Icon14(Assets.img.ico_10_im),
                            Spacer(),
                            if(isValidSummarize == false)
                              Text(L10n.feedback_01_please_fill_out, style: _validTextStyle)
                            else if(isValidDescription == false)
                              Text(L10n.feedback_01_description_error, style: _validTextStyle)
                          ],
                        ),
                      ),
                      SizedBox(height: Zeplin.size(20)),
                      FocusTraversalOrder(
                        order: NumericFocusOrder(2),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                          child: FeedbackTextFormField(
                            summarizeEditingDefault: _summarizeTextEditDefault,
                            descriptionEditingDefault: _descriptionTextEditDefault,
                            summarizeFocusNode: _summarizeFocusNode,
                            descriptionFocusNode: _descriptionFocusNode,
                            isValid: isValidDescription,
                          ),
                        )
                      )
                    ]
                  ),
                ),
                SizedBox(height: Zeplin.size(16)),
                Container(
                  height: Zeplin.size(160),
                  padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Row(children: selectedFileList.map((e) => SelectedImage(file: e, removeFunc: removeSelectedImage)).toList()),

                      if(selectedFileList.length < feedbackMaxImageCount)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: allowedExtensions);

                              if(result == null) {
                                return;
                              }

                              List<PlatformFile> files = result.files;

                              if(selectedFileList.length + files.length > feedbackMaxImageCount) {
                                SquareDefaultDialog.showSquareDialog(
                                  title: L10n.feedback_01_upload_failed,
                                  content: RichText(
                                    text: TextSpan(
                                      children: StringUtil.parseColorText(L10n.feedback_01_upload_failed_content, CustomColor.azureBlue, boldToAccent: false, fontSize: Zeplin.size(26)),
                                      style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  button1Text: L10n.feedback_01_close
                                );
                                return;
                              }

                              double size = 0;
                              for(PlatformFile file in files+selectedFileList) {
                                size += ImageUtil.getSizeMB(file.size);
                              }

                              if(size > feedbackMaxImageSizeMB) {
                                SquareDefaultDialog.showSquareDialog(
                                  title: L10n.feedback_01_upload_failed,
                                  content: RichText(
                                    text: TextSpan(
                                      children: StringUtil.parseColorText(L10n.feedback_01_upload_failed_content2(size.toStringAsFixed(2)), CustomColor.azureBlue, boldToAccent: false, fontSize: Zeplin.size(26)),
                                      style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  button1Text: L10n.feedback_01_close
                                );
                                return;
                              }

                              selectedFileList.addAll(files);
                              setState(() {});

                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: Zeplin.size(10)),
                                width: Zeplin.size(146),
                                height: Zeplin.size(146),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Zeplin.size(26)),
                                  border: Border.all(
                                    width: 1,
                                    color: CustomColor.borderGrey2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon46(Assets.img.ico_46_plus_gy),
                                    SizedBox(height: Zeplin.size(4)),
                                    Text("${selectedFileList.length}/$feedbackMaxImageCount", style: TextStyle(letterSpacing: 1.2, color: CustomColor.paleGreyDarkL, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))),
                                  ],
                                )
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  bool checkLeave() {
    return _emailTextEditDefault.resultText.isNotEmpty || _summarizeTextEditDefault.resultText.isNotEmpty
        || _descriptionTextEditDefault.resultText.isNotEmpty || selectedFileList.isNotEmpty;
  }
  
  bool isActiveSubmit() {
    String email = _emailTextEditDefault.resultText;
    return email.isNotEmpty && StringUtil.isValidEmailFormat(email) && _descriptionTextEditDefault.resultText.length >= feedbackDescriptionMinLength && _summarizeTextEditDefault.resultText.isNotEmpty;
  }

  void submit() async {
    String email = _emailTextEditDefault.resultText;
    if(email.length == 0) {
      isValidEmail = false;
    }

    if(!StringUtil.isValidEmailFormat(email)) {
      isValidEmailFormat = false;
    }

    String description = _descriptionTextEditDefault.resultText;
    if(description.length < feedbackDescriptionMinLength) {
      isValidDescription = false;
    }

    String summarize = _summarizeTextEditDefault.resultText;
    if(summarize.length == 0) {
      isValidSummarize = false;
    }

    if(isValidEmail == false || isValidEmailFormat == false || isValidDescription == false || isValidSummarize == false) {
      setState(() {});
      return;
    }

    FullScreenSpinner.show(context);

    List<String> fileLinkList = await ProfileManager().uploadFileList(selectedFileList);
    SuggestModel suggestModel = SuggestModel(email, summarize, description, fileLinkList: fileLinkList);
    String? feedbackId = await ProfileManager().suggestBySendFeedback(suggestModel);

    if(feedbackId != null) {
      LogWidget.debug("suggest feedback success!!!");

      SquareDefaultDialog.showSquareDialog(
        title: L10n.feedback_01_thank_you,
        content: RichText(
          text: TextSpan(
            children: StringUtil.parseColorText(L10n.popup_12_feedback_content(feedbackId), CustomColor.azureBlue, boldToAccent: false, fontSize: Zeplin.size(26)),
            style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26))
          ),
          textAlign: TextAlign.center,
        ),
        button1Text: L10n.feedback_01_close
      );

      widget.showPage?.call(0);
    } else {
      LogWidget.debug("suggest feedback fail!!!");
    }

    FocusManager.instance.primaryFocus?.unfocus();
    FullScreenSpinner.hide();
  }

  void removeSelectedImage(PlatformFile file) {
    selectedFileList.remove(file);
    setState(() {});
  }
}

class SelectedImage extends StatelessWidget {
  final PlatformFile file;
  final Function(PlatformFile) removeFunc;
  const SelectedImage({Key? key, required this.file, required this.removeFunc}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool isImage = allowedImageExtensions.contains(file.extension?.toLowerCase());

    return Container(
      height: Zeplin.size(160),
      width: Zeplin.size(160),
      margin: EdgeInsets.only(right: Zeplin.size(10)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: Zeplin.size(146),
              width: Zeplin.size(146),
              decoration: BoxDecoration(
                color: CustomColor.paleGrey,
                borderRadius: BorderRadius.circular(Zeplin.size(26))
              ),
              child: Center(child: isImage ? Image.memory(file.bytes!, fit: BoxFit.cover, width: Zeplin.size(120), height: Zeplin.size(120)) : Image.asset(Assets.img.ico_86_camera, width: Zeplin.size(86), height: Zeplin.size(86)))
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => removeFunc.call(file),
                child: Icon40(Assets.img.ico_40_x_gy_2))
            )
          )
        ],
      ),
    );
  }
}

