class RoutePaths {
  static const _CommonPathConst common = const _CommonPathConst();
  static const _ChatPathConst chat = const _ChatPathConst();
  static const _ProfilePathConst profile = const _ProfilePathConst();
  static const _SquarePathConst square = const _SquarePathConst();
}

class _CommonPathConst {
  const _CommonPathConst();

  final String fullImageView = "common/fullImageView";
  final String camera = "common/camera";
  final String crop = "common/crop";
}

class _ChatPathConst {
  const _ChatPathConst();

  final String open = "chat/open";
}


class _ProfilePathConst {
  const _ProfilePathConst();

  final String player = "profile/player";
  final String aiSquare = "profile/aiSquare";
  final String myNftList = "profile/myNftList";
  final String termsOfService = "profile/termsOfService";
  final String faq = "profile/faq";
  final String sendFeedback = "profile/sendFeedback";
  final String reportProblem = "profile/reportProblem";
  final String suggest = "profile/suggest";
}

class _SquarePathConst {
  const _SquarePathConst();

  final String squareChat = 'square/chat';
  final String squareMember = 'square/members';
  final String add = 'square/add';
  final String edit = 'square/edit';
}