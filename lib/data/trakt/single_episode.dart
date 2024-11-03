// To parse this JSON data, do
//
//     final singleEpisode = singleEpisodeFromJson(jsonString);

import 'dart:convert';

SingleEpisode singleEpisodeFromJson(String str) =>
    SingleEpisode.fromJson(json.decode(str));

String singleEpisodeToJson(SingleEpisode data) => json.encode(data.toJson());

class SingleEpisode {
  int season;
  int number;
  String title;
  Ids ids;
  dynamic numberAbs;
  String overview;
  DateTime firstAired;
  DateTime updatedAt;
  double rating;
  int votes;
  int commentCount;
  List<String> availableTranslations;
  int runtime;
  String episodeType;

  SingleEpisode({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
    required this.numberAbs,
    required this.overview,
    required this.firstAired,
    required this.updatedAt,
    required this.rating,
    required this.votes,
    required this.commentCount,
    required this.availableTranslations,
    required this.runtime,
    required this.episodeType,
  });

  factory SingleEpisode.fromJson(Map<String, dynamic> json) => SingleEpisode(
        season: json["season"],
        number: json["number"],
        title: json["title"],
        ids: Ids.fromJson(json["ids"]),
        numberAbs: json["number_abs"],
        overview: json["overview"],
        firstAired: DateTime.parse(json["first_aired"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        rating: json["rating"],
        votes: json["votes"],
        commentCount: json["comment_count"],
        availableTranslations:
            List<String>.from(json["available_translations"].map((x) => x)),
        runtime: json["runtime"],
        episodeType: json["episode_type"],
      );

  Map<String, dynamic> toJson() => {
        "season": season,
        "number": number,
        "title": title,
        "ids": ids.toJson(),
        "number_abs": numberAbs,
        "overview": overview,
        "first_aired": firstAired.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "rating": rating,
        "votes": votes,
        "comment_count": commentCount,
        "available_translations":
            List<dynamic>.from(availableTranslations.map((x) => x)),
        "runtime": runtime,
        "episode_type": episodeType,
      };
}

class Ids {
  int trakt;
  int? tvdb;
  String? imdb;
  int? tmdb;

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
