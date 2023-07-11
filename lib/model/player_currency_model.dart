
class PlayerCurrencyModel {
  String? playerId;
  String? currencyCode;
  int? freeAmount = 0;
  int? paidAmount = 0;

  PlayerCurrencyModel.fromMap(Map<String, dynamic> map) {
    playerId = map["playerId"];
    currencyCode = map["currencyCode"];
    freeAmount = map["freeAmount"];
    paidAmount = map["paidAmount"];
  }
}