import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/page/square/square_chat_page.dart';
import 'package:square_web/page/square/square_member_home.dart';
import 'package:square_web/page/profile/player_profile_page_home.dart';
import 'package:square_web/page/room/chat_page.dart';

import 'assets.dart';

const String appTitle = "SQUARE";

const String linkChatKey = "c";
const String linkSquareKey = "y";
const String verifyEmailKey = 'v';
const String brandKey = "w";

const String copyTextKey = "copyText";
const String linkMessageFailed = "failed";
const String linkMessageNull = "null";

class PageType {
  static bool isChatPage(HomeWidget? homeWidget) {
    if (homeWidget == null) return false;
    return homeWidget.pageType == ChatPage;
  }

  static bool isSquarePage(HomeWidget? homeWidget) {
    if (homeWidget == null) return false;
    return homeWidget.pageType == SquareChatPage;
  }

  static bool isPlayerProfilePage(HomeWidget? homeWidget) {
    if (homeWidget == null) return false;
    return homeWidget.pageType == PlayerProfilePageHome;
  }

  static bool isSquareMemberPage(HomeWidget? homeWidget) {
    if (homeWidget == null) return false;
    return homeWidget.pageType == SquareMemberHome;
  }

}

class AnalyticsConfig {
  static String keywordPrefix = "KEYWORD-";
  static String walletPrefix = "WALLET-";
  static String squareIdPrefix = "SQUARE-";
  static String walletTypePrefix = "WALLET_TYPE-";

  static String joinSquare = 'join_square';
  static String searchPlayer = 'search_player';
  static String searchSquare = 'search_square';
  static String viewPlayerProfile = 'view_player_profile';
  static String addPlayerToContacts = 'add_player_to_contacts';
  static String showSquareDialog = 'show_square_dialog';
  static String login = 'login';


  static String paramName(String name, String eventName) {
    return name + "__${eventName}";
  }

  static String squareId(String src) {
    return Config.zone + ":" + squareIdPrefix + src;
  }

  static String? walletType(String? src) {
    if(src == null) return null;
    return Config.zone + ":" + walletTypePrefix + src;
  }

  static String keyword(String src) {
    return Config.zone + ":" + keywordPrefix + src;
  }

  static String wallet(String src) {
    return Config.zone + ":" + walletPrefix + src;
  }
}

class ChatSkill {
  static List<String> rocketSkillPattern = [
    "shoot"
  ];
  static int rocketSkillDuration = 1000;
  static int rocketSkillMidDuration = 450;
}

class PageSize {
  static double defaultPageWidth = Zeplin.size(740);
  static EdgeInsetsGeometry defaultTwoDepthPopUpPadding = EdgeInsets.symmetric(vertical: Zeplin.size(18), horizontal: Zeplin.size(22));
  static double myPageHeight = Zeplin.size(590);
  static double profilePageHeight = Zeplin.size(1296);
  static double squareProfilePageHeight = Zeplin.size(1496);
  static EdgeInsetsGeometry defaultOverlayPadding =
      EdgeInsets.symmetric(vertical: Zeplin.size(100), horizontal: Zeplin.size(100));
  static double defaultOverlayMaxWidth = Zeplin.size(960);
  static double defaultOverlayMaxHeight = Zeplin.size(1170);
}

// Spacing
const double spaceXS = 2.0;
const double spaceS = 4.0;
const double spaceM = 8.0;
const double spaceL = 16.0;
const double spaceML = 24.0;
const double spaceXL = 32.0;

// websocket timeout milliseconds
const int wsTimeoutMs = 2000;

const int int64MaxValue = 9007199254740992; // this value is for web; for app : 9223372036854775807;

final TextStyle greyText =
    TextStyle(fontSize: Zeplin.size(24), color: CustomColor.blueyGrey, fontWeight: FontWeight.w500);
final TextStyle systemMessageGreyDefaultStyle =
    TextStyle(color: CustomColor.paleGreyDarkL, fontSize: Zeplin.size(11, isPcSize: true), fontWeight: FontWeight.w500);
final TextStyle systemMessageTimeStyle =
    TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(22), fontWeight: FontWeight.w500);

enum TabCode {
  chat,
  square,
  contacts,
  more,
  full,
}

final Random random = Random();

final TextStyle chatTextStyle = TextStyle(color: Colors.black, fontSize: Zeplin.size(28), fontWeight: FontWeight.w400, letterSpacing: 0.3, height: 1.4);
final TextStyle chatTextFieldStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400);
final TextStyle chatLinkTextStyle = TextStyle(color: CustomColor.azureBlue, fontSize: Zeplin.size(28), fontWeight: FontWeight.w400, decoration: TextDecoration.underline);
final TextStyle deletedChatTextStyle =
    TextStyle(fontWeight: FontWeight.w500, color: CustomColor.blueyGrey, fontSize: Zeplin.size(26));

const curveSizeS = 0.15;
const curveSizeM = 0.17;
const curveSizeL = 0.2;

class Zeplin {
  static Zeplin? _instance;

  static void init(double devicePixelRatio, double screenWidth, double screenHeight) {
    if (_instance != null) return;

    // double sizeFactor = devicePixelRatio < 3 ? 0.53 : 0.6;
    // _instance = Zeplin(sizeFactor);
    // _instance = Zeplin(0.53);
    _instance = Zeplin(sizeFactor);
  }

  static double get sizeFactor => _instance?._sizeFactor ?? 0.53;
  static const String robotoRegular = "Roboto";
  static const String robotoMedium = "Roboto";
  static const String robotoBold = "Roboto";

  double _sizeFactor;

  Zeplin(double sizeFactor) : this._sizeFactor = sizeFactor;

  // zeplin font size * sizeFactor
  static double size(double zeplinSize, {bool isPcSize = false}) => (isPcSize ? zeplinSize : zeplinSize * sizeFactor);

  static TextStyle textStyle({
    double? fontSize,
    Color? color,
    String? fontFamily,
    bool bold = false,
    bool inherit = true,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize != null ? Zeplin.size(fontSize).floorToDouble() : null,
      color: color,
      fontFamily: fontFamily != null ? fontFamily : "Roboto",
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      inherit: inherit,
      decoration: decoration,
    );
  }
}

const int paletteColor = 180;

const int thumbnailMaxWidth = 300;

const int thumbnailMaxHeight = 700;

const double imageMessageMaxWidth = 500;
const double imageMessageMinWidth = 200;
const double imageMessageMaxHeight = 500;
const double imageMessageMinHeight = 200;


enum SkillType {
  heart,
  rocket,
  ice,
  dung,
  laser,
}

class SquareTransition {
  static Curve twoDepthPopUpTransitionCurve = Cubic(0.44, 0.0, 0.56, 1.0);
  static int slideUpDuration = 250;
  static int defaultDuration = 200;
  static ValueNotifier<bool> skipToBuildSelectionArea = ValueNotifier(false);
}

const squarePlayerId = "SQUARE";
//const squareAlarmPlayerId = "SQUAREAlarm";
//const squareAlarmNickname = "욜알림";
// const String squareAlarmRoomClose5Min = "squareAlarmRoomClose5Min";
// const String squareAlarmRoomClose = "squareAlarmRoomClose";

class CustomColor {
  static const Color paleGreyDarkL = Color(0xFFA1A2A7);
  static const Color paleGrey = Color(0xFFF3F4F7);
  static const Color paleGreyDark = Color.fromRGBO(222, 223, 224, 1);
  static const Color azureBlue = Color.fromRGBO(31, 141, 240, 1);
  static const Color lemon = Color.fromRGBO(255, 254, 84, 1);
  static const Color lemonDark = Color.fromRGBO(219, 218, 68, 1);
  static const Color kakaoYellow = Color.fromRGBO(254, 229, 0, 1);
  static const Color outlineGrey = Color.fromRGBO(161, 162, 167, 1);
  static const Color chatImageBorderGrey = Color.fromRGBO(190, 193, 198, 1);
  static const Color settingBackGrey = Color.fromRGBO(238, 240, 243, 1);
  static const Color blueyGrey = Color.fromRGBO(161, 162, 167, 1);
  static const Color backgroundYellow = Color.fromRGBO(255, 254, 84, 0.6);
  static const Color backgroundYellowNoneOpacity = Color.fromRGBO(255, 254, 84, 1);
  static const Color deleteRed = Color.fromRGBO(236, 85, 105, 1);
  static const Color backgroundRocketSkill = Color.fromRGBO(101, 223, 255, 1);
  static const Color backgroundIceSkill = Color.fromRGBO(255, 252, 41, 1);
  static const Color backgroundLaserSkill = Color.fromRGBO(166, 255, 202, 1);
  static const Color backgroundDungSkill = Color.fromRGBO(206, 255, 77, 1);
  static const Color backgroundHeartSkill = Color.fromRGBO(255, 165, 244, 1);
  static const Color coolGrey = Color.fromRGBO(157, 160, 163, 1);
  static const Color lightGrey = Color.fromRGBO(214, 214, 214, 1);
  static const Color lightGrey2 = Color.fromRGBO(216, 216, 216, 1);
  static const Color unselectedTextGrey = Color.fromRGBO(160, 160, 160, 1);
  static const Color cloudyBlue = Color.fromRGBO(190, 193, 198, 1);
  static const Color paleBlue = Color.fromRGBO(228, 230, 233, 1);
  static const Color paleGreyTwo = Color.fromRGBO(247, 247, 250, 1);
  static const Color ceruleanBlue40 = Color.fromRGBO(0, 102, 215, 0.4);
  static const Color gptBlue = Color.fromRGBO(2, 50, 103, 1);
  static const Color lightBlue = Color.fromRGBO(123, 194, 248, 1);
  static const Color paleLilac = Color.fromRGBO(227, 227, 227, 1);
  static const Color iceBlue = Color.fromRGBO(238, 240, 243, 1);
  static const Color lightRed = Color.fromRGBO(255, 118, 136, 1);
  static const Color yellow = Color.fromRGBO(255, 242, 15, 1);
  static const Color purpleishBlue = Color.fromRGBO(112, 68, 232, 1);
  static const Color skyBlue = Color.fromRGBO(137, 214, 251, 1);
  static const Color stormGrey = Color.fromRGBO(80, 80, 80, 1);
  static const Color darkGrey = Color(0xFF161819);
  static const Color brownGrey = Color.fromRGBO(127, 127, 127, 1);
  static const Color carnation = Color.fromRGBO(255, 118, 136, 1);
  static const Color lightGreyBlue = Color.fromRGBO(178, 178, 181, 1);
  static const Color dimColor = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color dimColor2 = Color.fromRGBO(0, 0, 0, 0.6);
  static const Color waterMelon = Color.fromRGBO(235, 85, 105, 1);
  static const Color redHighlight = Color.fromRGBO(237, 133, 146, 1);
  static const Color slateGrey = Color.fromRGBO(105, 107, 110, 1);
  static const Color lightNavy = Color.fromRGBO(21, 42, 107, 1);
  static const Color red = Color.fromRGBO(235, 64, 52, 1);
  static const Color dandelion = Color.fromRGBO(252, 228, 8, 1);
  static const Color openChatRoomBackgroundColor = Color.fromRGBO(215, 239, 255, 1.0);
  static const Color dartMint = Color.fromRGBO(63, 200, 88, 1.0);
  static const Color purple = Color.fromRGBO(141, 83, 255, 1.0);
  static const Color grey1 = Color.fromRGBO(225, 225, 225, 1.0);
  static const Color grey2 = Color.fromRGBO(243, 243, 243, 1.0);
  static const Color grey3 = Color.fromRGBO(243, 244, 247, 1.0);
  static const Color grey4 = Color.fromRGBO(133, 134, 139, 1.0);
  static const Color lightBlue2 = Color.fromRGBO(0, 141, 248, 1.0);
  static const Color iceGrey = Color.fromRGBO(241, 242, 242, 1.0);
  static const Color borderGrey = Color.fromRGBO(217, 217, 217, 1.0);
  static const Color taupeGray = Color(0xFF85868B);
  static const Color linkWater = Color.fromRGBO(222, 238, 253, 1.0);
  static const Color veryLightGrey = Color.fromRGBO(227, 227, 227, 1.0);
  static const Color brightBlue = Color(0xFFE8F3FD);
  static const Color silverWhite = Color(0xFFDADBDD);
  static const Color laserLemon = Color(0xFFE5E44B);
  static const Color grey = Color(0xFFDADBDF);
  static const Color klipBlue = Color(0xFF216FEA);
  static const Color kaikasBlue = Color(0xFF3366FF);
  static const Color textFieldBorderGrey = Color.fromRGBO(226, 227, 230, 0.5);
  static const Color wrongInputRed = Color(0xFFEC5569);
  static const Color borderGrey2 = Color(0xFFD6D6D6);
  static const Color dividerGrey = Color(0xFFE3E3E3);
  static const Color focusGrey = Color(0xFFEAEBEE);
  static const Color scrollGrey = Color(0xFFECECED);

}

TextStyle centerTitleTextStyle =
    TextStyle(fontSize: Zeplin.size(34), fontWeight: FontWeight.w500, color: CustomColor.darkGrey);

class L10nContainer {
  static AppLocalizations? _appLocalization;

  static AppLocalizations? get appLocalization => _appLocalization;

  static void setContext(BuildContext context) => _appLocalization = AppLocalizations.of(context);
}

final AppLocalizations L10n = L10nContainer.appLocalization!;

class PrefsKey {
  //player
  static const String recentSearchPlayer = 'recentSearchPlayer';

  //square
  static const String recentSearchSquareList = 'recentSearchedSquares';

  //language
  static const String language = 'language';
}

const playerSettingDelayMills = 400;

class SquarePlatform {
  static bool useReqJson = true;
}

final int maxTempSaveCount = 10;

class Chain {
  static int loadNftRetryDelaySeconds = 3;
  static ChainNetType defaultChain = ChainNetType.ethereum;

  static String get defaultChainName => defaultChain.fullName;
  static Set<ChainNetType> supportedChainName = {
    ChainNetType.ethereum,
    ChainNetType.klaytn,
    ChainNetType.rinkeby
  };
  static int notSupportChainErrorCode = 501;

  static String getSelectedChainNetTypeKey(String playerId) {
    return "lastSelectedChainNetType:${playerId}";
  }
}

enum NftQueueStatus {
  running, finishing, done, error;

  static bool isRunning(NftQueueStatus? status) =>
    status == running || status == finishing;
}

class EmoticonConfig {
  static Paint paint = Paint();
  static double chatEmoticonSize = 100;
  static double exampleEmoticonSizeForMobile = 130;
  static double exampleEmoticonSizeForDesktop = 100;
  static double defaultEmoticonImageSize = 1024;
  static double defaultEmoticonInterval = 60;
  static double emoticonPackImageSize = Zeplin.size(70, isPcSize: true);
  static double emoticonPackPaddingSize = Zeplin.size(13, isPcSize: true);
  static int defaultEmoticonPackColumn = 4;
  static int defaultEmoticonRepeatCnt = 4;

}

enum HomeWidgetLayer { underNavi, onSlidePanel, overNavi }

final ERC_721_ABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function balanceOf(address) view returns (uint)",
  "function tokenURI(uint tokenId) view returns (string)",
  "function tokenOfOwnerByIndex(address owner, uint index) view returns (uint)",
  "function mint(address account, uint tokenId, string tokenURI)"
];

final ERC_1155_ABI = [
  "function balanceOf(address owner, uint id) view returns (uint)",
  "function burn(address account, uint tokenId, uint value)",
  "function uri(uint tokenId) view returns (string)",
];

enum RelationshipStatus { normal, removed, blocked }

final walletAddressRegExp = RegExp(r'^0x[a-fA-F0-9]{40}$');

final int nicknameMaxLength = 20;
final int sendTypingTime = 9;
final int receiveTypingTime = 11;

enum TwinChatDropdownType { chat, block }

enum TwinChatPopupType { blockContact, archiveRoom, close }

enum SquarePopupType { link, close, token }

final maxWidthMobile = 768;
final maxWidthTablet = 1024;
final maxTextLength = 800;
final searchLoadingMilliseconds = 50;
final walletLength = 42;
final maxSendImageCount = 4;
final sendTermSeconds = 2;
final maxSentMsgCount = 5;
final blockSenBtnSeconds = 15;

class SquareStyle {
  static TextStyle pageTitleTextStyle = TextStyle(fontWeight: FontWeight.w500, color: CustomColor.darkGrey, fontSize: Zeplin.size(34));

  static EdgeInsetsGeometry pageTopPadding = const EdgeInsets.only(top: 70);
}

class SquareDefaultProfileImage {
  static final AssetImage assetImage = AssetImage(Assets.img.profile_image_default);
}

enum OrderType { name, online, memberCount }

enum Status { active, inactive, withdraw, notSignedUp, archived }
enum MemberStatus { joined, left, restricted, pending, ai }

const supportSquareEmail = "support@square.test";

const feedbackMaxImageSizeMB = 25;
const feedbackMaxImageCount = 4;
const allowedExtensions = ["jpeg", "png", "bmp", "gif", "jpg", "avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv"];
const allowedImageExtensions = ["jpeg", "png", "bmp", "gif", "jpg"];
const feedbackDescriptionMinLength = 50;

class MobileBrowser {
  static final metaMask = "MetaMask";
  static final kaikas = "Kaikas";
  static final kakaotalk = "KakaoTalk";
}

class SnsLink {
  static final twitter = "https://twitter.com";
  static final line = "https://liff.line.me";
  static final telegram = "https://t.me/";
  static final kakao = "http://pf.kakao.com/";
  static final discord = "https://discord.gg/";
}

const maxNftImageSize = 6;
const nft = "nft";

class IpfsService {

  static List<IpfsServiceId> ipfsServiceList = [IpfsServiceId.dweb_link, IpfsServiceId.ipfs_io];

}

enum IpfsServiceId {
  dweb_link,
  ipfs_io,
  cloudflare_ipfs
}

enum SquareType {
  nft, token, etc, user
}


enum RoomFolder {
  chat, archives, block
}

enum ContactsFolder {
   contacts, blocked
}

enum SquareFolder {
  public, secret
}

const bool showSetLang = false;

enum SupportedLang {
  ko, en
}

const double maxWidthChatPage = 800;

const pcChatPageBoxConstraints = BoxConstraints(maxWidth: maxWidthChatPage);

const limitCheckpoint = 2;

const Map<String, String> aiModelExceedNoticeMap = {
    "ko": "내일 이어서 대화하실 수 있습니다. ({model}: 일 {limit}회 대화 제공)",
    "en": "You can continue the chat tomorrow. ({model}: {limit} chats per day)",
    "jp": "明日も会話を続けることができます。 ({model}: 1日{limit}回会話)"
};

String aiModelExceedNotice(String lang, String model, int limit) {
  if(!aiModelExceedNoticeMap.containsKey(lang)) {
    lang = Config.defaultLang;
  }
  return aiModelExceedNoticeMap[lang]!.replaceFirst("{model}", model).replaceFirst("{limit}", limit.toString());
}
