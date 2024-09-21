// To parse this JSON data, do
//
//     final episodesFromSeason = episodesFromSeasonFromJson(jsonString);

import 'dart:convert';

import 'package:nyaashows/data/trakt/show.dart';

List<EpisodesFromSeason> episodesFromSeasonFromJson(String str) => List<EpisodesFromSeason>.from(json.decode(str).map((x) => EpisodesFromSeason.fromJson(x)));

String episodesFromSeasonToJson(List<EpisodesFromSeason> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EpisodesFromSeason {
  int season;
  int number;
  String title;
  Ids ids;

  EpisodesFromSeason({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });

  factory EpisodesFromSeason.fromJson(Map<String, dynamic> json) => EpisodesFromSeason(
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
