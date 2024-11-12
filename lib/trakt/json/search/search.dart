import '../utils/ids.dart';

class Search {
  String? type;
  dynamic score;
  Show? show;

  Search({this.type, this.score, this.show});

  Search.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
    show = json['show'] != null ? Show.fromJson(json['show']) : Show.fromJson(json['movie']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['score'] = score;
    if (show != null) {
      data['show'] = show!.toJson();
    }
    return data;
  }
}

class Show {
  String? title;
  int? year;
  Ids? ids;

  Show({this.title, this.year, this.ids});

  Show.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    year = json['year'];
    ids = json['ids'] != null ? Ids.fromJson(json['ids']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['year'] = year;
    if (ids != null) {
      data['ids'] = ids!.toJson();
    }
    return data;
  }
}
