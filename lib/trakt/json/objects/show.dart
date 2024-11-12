import 'dart:convert';

import '../utils/ids.dart';

Show showFromJson(String str) => Show.fromJson(json.decode(str));
String showToJson(Show data) => json.encode(data.toJson());

class Show {
  String title;
  int year;
  Ids ids;

  Show({
    required this.title,
    required this.year,
    required this.ids,
  });

  factory Show.fromJson(Map<String, dynamic> json) => Show(
        title: json["title"],
        year: json["year"],
        ids: Ids.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "year": year,
        "ids": ids.toJson(),
      };
}
