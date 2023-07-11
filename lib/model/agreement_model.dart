class AgreementModel {
  static late List<AgreementModel> agreementList;

  final String? agreementCode;
  final String? title;
  final String? myPageTitle;
  final String? contentUrl;
  final bool? required;
  bool? isChecked;

  AgreementModel({this.agreementCode, this.title, this.myPageTitle, this.contentUrl, this.required}) {
    isChecked = false;
    assert(title != null);
    assert(required != null);
  }
}