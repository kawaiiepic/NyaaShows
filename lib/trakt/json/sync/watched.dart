// To parse this JSON data, do
//
//     final watched = watchedFromJson(jsonString);

import 'dart:convert';

import '../shows/extended_show.dart';

List<Watched> watchedFromJson(String str) => List<Watched>.from(json.decode(str).map((x) => Watched.fromJson(x)));

String watchedToJson(List<Watched> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Watched {
  int plays;
  DateTime lastWatchedAt;
  DateTime lastUpdatedAt;
  DateTime? resetAt;
  ExtendedShow show;
  List<Season> seasons;

  Watched({
    required this.plays,
    required this.lastWatchedAt,
    required this.lastUpdatedAt,
    required this.resetAt,
    required this.show,
    required this.seasons,
  });

  factory Watched.fromJson(Map<String, dynamic> json) => Watched(
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
        lastUpdatedAt: DateTime.parse(json["last_updated_at"]),
        resetAt: json["reset_at"] == null ? null : DateTime.parse(json["reset_at"]),
        show: ExtendedShow.fromJson(json["show"]),
        seasons: List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
        "last_updated_at": lastUpdatedAt.toIso8601String(),
        "reset_at": resetAt?.toIso8601String(),
        "show": show.toJson(),
        "seasons": List<dynamic>.from(seasons.map((x) => x.toJson())),
      };
}

class Season {
  int number;
  List<Episode> episodes;

  Season({
    required this.number,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        number: json["number"],
        episodes: List<Episode>.from(json["episodes"].map((x) => Episode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
      };
}

class Episode {
  int number;
  int plays;
  DateTime lastWatchedAt;

  Episode({
    required this.number,
    required this.plays,
    required this.lastWatchedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        number: json["number"],
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
      };
}
class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
