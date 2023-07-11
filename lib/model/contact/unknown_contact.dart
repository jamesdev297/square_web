import 'contact_model.dart';

class UnknownContact extends ContactModel {
  UnknownContact():super(playerId: "unknown"+DateTime.now().millisecondsSinceEpoch.toString(), nickname: "알 수 없는 사람");
}