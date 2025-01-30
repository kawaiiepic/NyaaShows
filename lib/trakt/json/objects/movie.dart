import 'dart:convert';

import '../utils/ids.dart';

Movie movieFromJson(String str) => Movie.fromJson(json.decode(str));

String movieToJson(Movie data) => json.encode(data.toJson());

class Movie {
  String title;
  int year;
  Ids ids;

  Movie({
    required this.title,
    required this.year,
    required this.ids,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
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
