// To parse this JSON data, do
//
//     final episode = episodeFromJson(jsonString);

import 'dart:convert';

import '../utils/ids.dart';

Episode episodeFromJson(String str) => Episode.fromJson(json.decode(str));

String episodeToJson(Episode data) => json.encode(data.toJson());

class Episode {
  int season;
  int number;
  String title;
  Ids ids;

  Episode({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        season: json["season"],
        number: json["number"],
        title: json["title"],
        ids: Ids.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "season": season,
        "number": number,
        "title": title,
        "ids": ids.toJson(),
      };
}