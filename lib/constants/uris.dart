
class Uris {
  static const _AuthUriConst auth = const _AuthUriConst();
  static const _CommonUriConst common = const _CommonUriConst();
  static const _FriendUriConst friend = const _FriendUriConst();
  static const _ProfileUriConst profile = const _ProfileUriConst();
  static const _RoomUriConst room = const _RoomUriConst();
  static const _BlockChainUriConst blockcahin = const _BlockChainUriConst();
  static const _ContactsUriConst contacts = const _ContactsUriConst();
  static const _KlipUriConst klip = const _KlipUriConst();
  static const _SquareUriConst square = const _SquareUriConst();
  static const _KaikasUriConst kaikas = const _KaikasUriConst();
  static const _MetamaskUriConst metamask = const _MetamaskUriConst();
  static const _FeedbackUriConst feedback = const _FeedbackUriConst();
  static const _AiUriConst ai = const _AiUriConst();
}

class _AuthUriConst {
  const _AuthUriConst();
  final String signWithToken = "pepper_core://v4/auth/signWithToken";

  final String heartbeat = "pepper_core://v4/auth/heartbeat";

  final String tokenRefresh = "/v4/auth/token/refresh";
  final String sign = "/v4/auth/sign";
  final String verifyEmail = "/v4/auth/email/verify";
  final String resendVerifyEmail = "/v4/auth/email/verify/resend";
  final String wsResendVerifyEmail = "pepper_core://v4/auth/email/verify/resend";

  final String oneTimeSignIn = "/v4/auth/onetime/sign";
  final String createOneTimeSignCode = "/v4/auth/onetime/create";

  final String logout = "/v4/auth/logout";

  final String prepareWalletSignCode = "/v4/auth/wallet/prepare";
  final String checkWalletSigned = "/v4/auth/wallet";
}

class _CommonUriConst {
  const _CommonUriConst();

  final String isContainsBannedWord = "pepper_core://v2/common/isContainsBannedWord";
  final String uploadNftImage = "pepper_core://v4/common/uploadNftImage";
}

class _FriendUriConst {
  const _FriendUriConst();

  final String setTargetNickname = "pepper_core://v4/contacts/nickname/set";
  final String getProfile = "pepper_core://v4/contacts/profile/get";

  final String getTargetContacts = "pepper_core://v4/contacts/targets";
  final String searchPlayers = "pepper_core://v4/contacts/profile/search";
}

class _ProfileUriConst {
  const _ProfileUriConst();

  final String getContactByLink = "v4/link/chat";

  final String updateEtcInfo = "pepper_core://v4/me/profile/etc/update";
  final String uploadThumbnail = "pepper_core://v4/upload/thumbnail";
  final String getPlayerOnlineStatus = "pepper_core://v4/contacts/isOnline";

  final String updateProfileImg = "pepper_core://v4/me/profile/update/profileImg";

  final String setBlockOptions = "pepper_core://v4/me/block/set";
  final String refreshMyNftList = "pepper_core://v4/me/nft/refresh";

  final String getContactsList = "pepper_core://v4/me/contacts/list";
  final String addContacts = "pepper_core://v4/me/contacts/add";
  final String removeContacts = "pepper_core://v4/me/contacts/remove";
  final String blockContacts = "pepper_core://v4/me/contacts/block";
  final String unblockBlockedContacts = "pepper_core://v4/me/contacts/blocked/unblock";
  final String getBlockedContactsList = "pepper_core://v4/me/contacts/blocked/list";

  final String getRooms = "pepper_core://v4/me/room/list";
  final String getBlockedRooms = "pepper_core://v4/me/room/blocked/list";
  final String getArchivedRooms = "pepper_core://v4/me/room/archived/list";
  final String getMyEmoticons = "pepper_core://v4/me/emoticons";
  final String unreadCount = "pepper_core://v4/room/unreadCount";

  final String getMyNftList = "pepper_core://v4/me/nft/list";

  final String update = "pepper_core://v4/me/profile/update";

  final String getProfilePicture = "pepper_core://v4/contacts/profile/picture/get";

  final String isAiPlayer = "pepper_core://v4/contacts/isAiPlayer";
}

class _RoomUriConst {
  const _RoomUriConst();

  final String createTwinRoom = "pepper_core://v4/room/twin/create";
  final String get = "pepper_core://v4/room/twin/get";
  final String members = "pepper_core://v4/room/members";
  final String message = "pepper_core://v4/room/message";
  final String messages = "pepper_core://v4/room/messages";
  final String say = "pepper_core://v4/room/say";
  final String uploadVideo = "pepper_core://v4/upload/video";
  final String uploadImage = "pepper_core://v4/upload/image";

  final String typing = "pepper_core://v4/room/typing";
  final String unblockBlocked = "pepper_core://v4/me/room/blocked/unblock";

  final String archive = "pepper_core://v4/me/room/archive";
  final String unarchive = "pepper_core://v4/me/room/unarchive";
  final String unread = "pepper_core://v4/me/room/unread/get";
  final String resetAiHistory = "pepper_core://v4/room/ai/history/reset";
}

class _BlockChainUriConst {
  const _BlockChainUriConst();

  final ethereum = 'https://mainnet.infura.io/v3/';
  final rinkeby = 'https://rinkeby.infura.io/v3/';
  final goerli = 'https://goerli.infura.io/v3/';
  final klatyn = 'https://api.cypress.ozys.net:8651/';
  final Baobab = 'https://api.baobab.klaytn.net:8651/';
  final bora = 'https://public-node.api.boraportal.io/bora/mainnet/';
  final polygon = 'https://polygon-rpc.com';
  // final solana = 'https://mainnet.neonevm.org';
}

class _KlipUriConst {
  const _KlipUriConst();
  final api = 'a2a-api.klipwallet.com';

  final prepare = 'v2/a2a/prepare';
  final result = 'v2/a2a/result';

  final iosRequestDeepLink = 'kakaotalk://klipwallet/open?url=https://klipwallet.com/?target=/a2a?request_key=';
  final aosRequestDeepLink = 'intent://klipwallet/open?url=https://klipwallet.com/?target=/a2a?request_key=';
  final pcRequestLink = 'https://klipwallet.com/?target=/a2a?request_key=';
}

class _KaikasUriConst {
  const _KaikasUriConst();
  final chromeExtensionPage = 'https://chrome.google.com/webstore/detail/kaikas/jblndlipeogpafnldhgmapagcccfchpi';
  final kaikasBridge = 'https://app.kaikas.io/u/';
}

class _MetamaskUriConst {
  const _MetamaskUriConst();
  final metamaskDeeplink = 'https://metamask.app.link/dapp';

}

class _ContactsUriConst {
  const _ContactsUriConst();

  final String getSimpleProfile = "pepper_core://v4/contacts/profile/simple/get";
}

class _SquareUriConst {
  const _SquareUriConst();
  final String getSquareByLink = "v4/link/square";

  final String getSquareProfile = "pepper_square://v1/square/profile";
  final String getPlayerSquareList = "pepper_square://v1/square/list";
  final String getSquareList = "pepper_square://v1/square/list/get";
  final String searchSquareByName = "pepper_square://v1/square/search/name";
  final String searchSquareByAddress = "pepper_square://v1/square/search/address";
  final String getSquareForLink = "pepper_square://v1/square/link/get";
  final String getSquareMembers = "pepper_square://v1/square/members";
  final String searchSquareMembers = "pepper_square://v1/square/members/search";
  final String joinSquareChannel = "pepper_square://v1/channel/join";
  final String getChanelList = "pepper_square://v1/channel/list";
  final String getChanelMessages = "pepper_square://v1/channel/messages";
  final String getChanelMessage = "pepper_square://v1/channel/message";
  final String sayMessages = "pepper_square://v1/channel/say";
  final String reportMessage = "pepper_square://v1/channel/message/report";
  final String checkReportedMessage = "pepper_square://v1/channel/message/report/check";

  final String uploadSquareChatImage = "pepper_core://v4/upload/square/channel/image";

  final String getTrendingSquareList = "pepper_square://v1/square/trending/list";

  final String joinSquare = "pepper_square://v1/square/join";
  final String leaveSquare = "pepper_square://v1/square/leave";
  final String getSquare = "pepper_square://v1/square/get";
  final String resetAiHistory = "pepper_square://v1/channel/ai/history/reset";
  final String addSquare = "pepper_square://v1/square/create";
  final String updateSquare = "pepper_square://v1/square/update";
  final String uploadThumbnail = "pepper_core://v4/upload/square/user/th";
  final String getAiMember = "pepper_square://v1/square/aiMember/get";
}

class _FeedbackUriConst {
  const _FeedbackUriConst();

  final String reportProblem = "pepper_core://v4/feedback/report";
  final String suggest = "pepper_core://v4/feedback/suggest";
  final String uploadFeedbackFile = "pepper_core://v4/upload/feedback/file";
}

class _AiUriConst {
  const _AiUriConst();

  final String aiPlayerList = "pepper_core://v4/ai/player/list";
}