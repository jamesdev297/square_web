
class ReportProblemModel {
  String topic;
  String email;
  String device;
  String summarize;
  String description;
  List<String>? fileLinkList;

  ReportProblemModel(this.topic, this.email, this.device, this.summarize, this.description, { this.fileLinkList });

}