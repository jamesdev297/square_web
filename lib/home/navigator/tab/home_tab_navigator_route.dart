import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:square_web/common/route/slide_route.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/page/common/camera_page.dart';
import 'package:square_web/page/common/view_full_image_page.dart';
import 'package:square_web/page/square/add_user_square_page_home.dart';
import 'package:square_web/page/square/edit_user_square_page_home.dart';
import 'package:square_web/page/square/square_chat_page.dart';
import 'package:square_web/page/square/square_list_page_home.dart';
import 'package:square_web/page/square/square_member_home.dart';
import 'package:square_web/page/square/square_search_page.dart';
import 'package:square_web/page/more/block_setting_page.dart';
import 'package:square_web/page/more/crop_image_page.dart';
import 'package:square_web/page/more/customer_support/faq_page.dart';
import 'package:square_web/page/more/customer_support/terms_of_service_page.dart';
import 'package:square_web/page/more/edit_profile_page.dart';
import 'package:square_web/page/more/my_nft_list_page.dart';
import 'package:square_web/page/profile/ai_square_profile_home.dart';
import 'package:square_web/page/profile/player_profile_page_home.dart';
import 'package:square_web/page/room/chat_page.dart';

class EmptyExpandTwoDepthWidget extends StatelessWidget with HomeWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TabCode>(valueListenable: HomeNavigator.currentTab, builder: (context, value, child) {
      if(value == TabCode.square) {
        return Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  SquareListPageHome.isIconView = true;
                  HomeNavigator.expandOneDepth(SquareListPageHome.isIconView);
                },
                child: Image.asset(Assets.img.ico_36_arrow_gy, width: Zeplin.size(100),),
              ),
            ),
          ),
        );
      }
      return Container();
    });
  }

  @override
  bool get isEmptyPage => true;

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepth;

  @override
  String pageName() => "EmptyExpandTwoDepthWidget";
}

class EmptyTwoDepthWidget extends StatelessWidget with HomeWidget {
  @override
  Widget build(BuildContext context) => Container();

  @override
  bool get isEmptyPage => true;

  @override
  double? get maxWidth => 0;

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepth;

  @override
  String pageName() => "EmptyTwoDepthWidget";
}

class TabNavigatorRoute {
  static Route<dynamic> getRoute(
      HomeWidget nextWidget, RouteSettings routeSetting) {
    return SlideRoute(
      builder: (context) => nextWidget,
      direction:
      (routeSetting.arguments as Map<String, dynamic>)["direction"],
      settings: RouteSettings(name: routeSetting.name, arguments: nextWidget),
    );
  }

  static HomeWidget getNextWidget(Uri uri, Object? arguments) {
    switch (uri.pathSegments.first) {
      case "common":
        return _processCommonNavigation(uri, arguments);
      case "room":
        return _processRoomNavigation(uri, arguments);
      case "chat":
        return _processChatNavigation(uri, arguments);
/*      case "openchat":
        return _processOpenChatNavigation(uri, arguments);*/
      case "contacts":
        return _processContactsNavigation(uri, arguments);
      case "profile":
        return _processProfileNavigation(uri, arguments);
      case "square":
        return _processSquareNavigation(uri, arguments);
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processRoomNavigation(Uri uri, Object? arguments) {
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processChatNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      case "open":
        return ChatPage(
          key: ValueKey("chat-${arguments is RoomModel ? arguments.roomId : 'null'}"),
          roomModel: arguments as RoomModel,
        );
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processOpenChatNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      // case "open":
      //   return OpenChatPage();
      // case "menu":
      //   return OpenChatRoomMenu();
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processSquareNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      case "chat":
        return SquareChatPage(squareModel: arguments as SquareModel, key: ValueKey("squareChat-${(arguments).squareId}"));
      case "members":
        SquareModel? square = (arguments as Map)['square'] as SquareModel;
        String channel = arguments['channel'];
        return SquareMemberHome(square, channel);
      case 'search':
        return SquareSearchPage();
      case "add":
        return AddUserSquarePageHome();
      case "edit":
        SquareModel square = (arguments as Map)['square'] as SquareModel;
        String aiPlayerId = arguments['aiPlayerId'];
        return EditUserSquarePageHome(squareModel: square, aiPlayerId: aiPlayerId);
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processContactsNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      // case "searchContacts":
      //   return SearchContactPage();
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processProfileNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      case "player":
        return PlayerProfilePageHome(arguments as String, key: ValueKey("PlayerProfilePage:${arguments}"),);
        break;
      case "aiSquare":
        Map<String, dynamic> arg = arguments as Map<String, dynamic>;
        return AiSquareProfileHome(arg["square"] as SquareModel, arg["channel"] as String, key: ValueKey("AiSquareProfilePage:${arguments}"),);
        break;
      // case "account":
      //   return MyProfileAccountPage();
      // case "inquire":
      //   return CsWebViewPage();
      // case "help":
      //   return HelpPage();
      // case "termsOfService":
      //   return TermsOfServicePage(agreementModel: arguments as AgreementModel?);
      // case "notice":
      //   return NoticePage();
      // case "alarmSetting":
      //   return AlarmSettingPage();
      case "myNftList":
        return MyNftListPage(
          successFunc: arguments as Function(dynamic)?
        );
      case "blockSetting":
        return BlockSettingPage();
      case "edit":
        return EditProfilePage();
      case "termsOfService":
        return TermsOfServicePage();
      case "faq":
        return FAQPage();
      // case "sendFeedback":
      //   return SendFeedbackPage();
      // case "suggest":
      //   return SuggestPage();
      // case "reportProblem":
      //   return ReportProblemPage();
    }
    return EmptyExpandTwoDepthWidget();
  }

  static HomeWidget _processCommonNavigation(Uri uri, Object? arguments) {
    switch (uri.pathSegments[1]) {
      case "fullImageView":
        return ViewFullImagePage((arguments as Map)["imageUrl"] as String,
            name: arguments["name"] as String?,
            msgSendTime: arguments["msgSendTime"] as int?,
            playerNftModel: arguments["playerNftModel"] as PlayerNftModel?);
      case "crop":
        return CropImagePage(imageBytes: (arguments as Map)["bytes"] as Uint8List,
          playerNftModel: (arguments)["nftModel"] as PlayerNftModel?,
          cropType: (arguments)["cropType"] as CropType,
          isCameraBeforePage: (arguments)["isCameraBeforePage"] as bool?,
          isNftListBeforePage: (arguments)["isNftListBeforePage"] as bool?,
        );
      // case "cropImage":
      //   return CropProfileImagePage(imageBytes: (arguments as Map)["bytes"] as Uint8List,
      //       playerNftModel: arguments["nftModel"] as PlayerNftModel?,
      //       isEditPage: arguments["isEditPage"] as bool?);
      case "camera":
        return CameraPage();
    }
    return EmptyExpandTwoDepthWidget();
  }
}
