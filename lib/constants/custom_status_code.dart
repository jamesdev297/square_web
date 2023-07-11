class CustomStatus {
  static const int WAIT_TO_EXPIRED = 220;
  static const int WAIT_FOR_CREATED = 221;
  
  //300~500 대는 http status code 를 피하기위해 미사용
  
  //auth error 60x
  static const int TOKEN_EXPIRED = 600;
  static const int PLAYER_NOT_ACTIVE = 602;
  static const int RESTRICTED_PLAYER = 603;
  static const int NO_PLAYER = 604;
  static const int ALREADY_RESTRICTED = 605;
  static const int VERIFY_EMAIL_SEND = 606;
  static const int NOT_EMAIL_VERIFIED = 607;
  static const int DUPLICATED_WALLET_CREATED = 608;
  static const int ALREADY_EXIST_PLAYER = 609;

  //friend error 62x
  static const int ALREADY_FRIEND_ADDED = 620;
  static const int NOT_ADDED_FRIEND = 621;

  //profile error 70x
  static const int ID_HAS_DEFAULT_ID = 700;
  static const int OVER_LENGTH_STATUS_MESSAGE = 701;
  
  //room error 80x
  static const int ROOM_ALREADY_EXIST = 800;

  //openchat error 82x
  static const int MEMBER_INSERT_FAILED = 820;
  static const int NOT_CURRENT_MEMBER = 821;

  //square error 85x
  static const int SQUARE_CHAT_NOT_SAID = 850;
  static const int NOT_IN_THE_SQUARE = 851;
  static const int NOT_EXIST_CHANNEL = 852;
  static const int SQUARE_RESTRICTED_PLAYER = 853;
  static const int SQUARE_LEFT_PLAYER = 854;

  static const int ALREADY_REPORTED_MESSAGE = 860;
  static const int EXCEED_ONE_DAY_REPORT_LIMIT = 861;

  //100x = purchase error code
  static const int NOT_ENOUGH_CURRENCY = 1000;
  static const int IS_CANCELED_PURCHASE = 1001;

  //kan error 20xx
  static const int ALREADY_EXIST_TITLE = 2000;
  static const int KAN_PRICE_CHANGED = 2001;
  static const int KAN_ALREADY_OWNED = 2002;
  static const int NO_KAN = 2004;
  static const int SOMEONE_ALREADY_POST_ART = 2005;

  //common errors 90xx
  static const int EXCEED_LIMIT = 9000;
  static const int HAS_BANNED_WORD = 9001;
  static const int TOO_FAST_REQUEST = 9002;
}