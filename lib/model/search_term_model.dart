

class SearchTermModel {
  int? rank;
  int? score;
  String? term;

  SearchTermModel.fromMap(Map<String, dynamic>? map) {
    if(map != null) {
      this.rank = map["rank"];
      this.score = map["score"];
      this.term = map["term"];
    }
  }
}