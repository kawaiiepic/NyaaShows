import 'dart:convert';

import '../utils/ids.dart';

ShowWatchedProgress showWatchedProgressFromJson(String str) => ShowWatchedProgress.fromJson(json.decode(str));
String showWatchedProgressToJson(ShowWatchedProgress data) => json.encode(data.toJson());

class ShowWatchedProgress {
  int aired;
  int completed;
  DateTime? lastWatchedAt;
  String? resetAt;
  List<Season> seasons;
  List<HiddenSeason> hiddenSeasons;
  TEpisode? nextEpisode;
  TEpisode? lastEpisode;

  ShowWatchedProgress({
    required this.aired,
    required this.completed,
    required this.lastWatchedAt,
    required this.resetAt,
    required this.seasons,
    required this.hiddenSeasons,
    required this.nextEpisode,
    required this.lastEpisode,
  });

  factory ShowWatchedProgress.fromJson(Map<String, dynamic> json) => ShowWatchedProgress(
        aired: json["aired"],
        completed: json["completed"],
        lastWatchedAt: json.containsKey("last_watched_") ? DateTime.parse(json["last_watched_at"]) : null,
        resetAt: json["reset_at"],
        seasons: List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
        hiddenSeasons: List<HiddenSeason>.from(json["hidden_seasons"].map((x) => HiddenSeason.fromJson(x))),
        nextEpisode: json["next_episode"] == null ? null : TEpisode.fromJson(json["next_episode"]),
        lastEpisode: json["last_episode"] == null ? null : TEpisode.fromJson(json["last_episode"]),
      );
// TEpisode.fromJson(json["next_episode"])
  Map<String, dynamic> toJson() => {
        "aired": aired,
        "completed": completed,
        "last_watched_at": lastWatchedAt?.toIso8601String(),
        "reset_at": resetAt,
        "seasons": List<dynamic>.from(seasons.map((x) => x.toJson())),
        "hidden_seasons": List<dynamic>.from(hiddenSeasons.map((x) => x.toJson())),
        "next_episode": nextEpisode?.toJson(),
        "last_episode": lastEpisode?.toJson(),
      };
}

class HiddenSeason {
  int number;
  Ids ids;

  HiddenSeason({
    required this.number,
    required this.ids,
  });

  factory HiddenSeason.fromJson(Map<String, dynamic> json) => HiddenSeason(
        number: json["number"],
        ids: Ids.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "ids": ids.toJson(),
      };
}

class TEpisode {
  int season;
  int number;
  String title;
  Ids ids;

  TEpisode({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });

  factory TEpisode.fromJson(Map<String, dynamic> json) => TEpisode(
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

class Season {
  int number;
  String? title;
  int aired;
  int completed;
  List<Episode> episodes;

  Season({
    required this.number,
    required this.title,
    required this.aired,
    required this.completed,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        number: json["number"],
        title: json["title"],
        aired: json["aired"],
        completed: json["completed"],
        episodes: List<Episode>.from(json["episodes"].map((x) => Episode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "title": title,
        "aired": aired,
        "completed": completed,
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
      };
}

class Episode {
  int number;
  bool completed;
  DateTime? lastWatchedAt;

  Episode({
    required this.number,
    required this.completed,
    required this.lastWatchedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        number: json["number"],
        completed: json["completed"],
        lastWatchedAt: json["last_watched_at"] == null ? null : DateTime.parse(json["last_watched_at"]),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "completed": completed,
        "last_watched_at": lastWatchedAt?.toIso8601String(),
      };
}
