// To parse this JSON data, do
//
//     final episodesFromSeason = episodesFromSeasonFromJson(jsonString);

import 'dart:convert';

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

class Ids {
  int trakt;
  int tvdb;
  String imdb;
  int tmdb;

  Ids({
    required this.trakt,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"],
        tvdb: json["tvdb"],
        imdb: json["imdb"],
        tmdb: json["tmdb"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
      };
}
