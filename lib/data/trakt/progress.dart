import 'dart:convert';

TraktProgress traktProgressFromJson(String str) => TraktProgress.fromJson(json.decode(str));

String traktProgressToJson(TraktProgress data) => json.encode(data.toJson());

class TraktProgress {
  int aired;
  int completed;
  dynamic lastWatchedAt;
  dynamic resetAt;
  List<Season> seasons;
  List<dynamic> hiddenSeasons;
  NextEpisode? nextEpisode;
  dynamic lastEpisode;

  TraktProgress({
    required this.aired,
    required this.completed,
    required this.lastWatchedAt,
    required this.resetAt,
    required this.seasons,
    required this.hiddenSeasons,
    required this.nextEpisode,
    required this.lastEpisode,
  });

  factory TraktProgress.fromJson(Map<String, dynamic> json) {
    NextEpisode? nextEpisode;
    if (json["next_episode"] != null) {
      nextEpisode = NextEpisode.fromJson(json["next_episode"]);
    }

    return TraktProgress(
      aired: json["aired"],
      completed: json["completed"],
      lastWatchedAt: json["last_watched_at"],
      resetAt: json["reset_at"],
      seasons: List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      hiddenSeasons: List<dynamic>.from(json["hidden_seasons"].map((x) => x)),
      nextEpisode: nextEpisode,
      lastEpisode: json["last_episode"],
    );
  }

  Map<String, dynamic> toJson() => {
        "aired": aired,
        "completed": completed,
        "last_watched_at": lastWatchedAt,
        "reset_at": resetAt,
        "seasons": List<dynamic>.from(seasons.map((x) => x.toJson())),
        "hidden_seasons": List<dynamic>.from(hiddenSeasons.map((x) => x)),
        "next_episode": nextEpisode?.toJson(),
        "last_episode": lastEpisode,
      };
}

class NextEpisode {
  int season;
  int number;
  String title;
  Ids ids;

  NextEpisode({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });

  factory NextEpisode.fromJson(Map<String, dynamic> json) => NextEpisode(
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
  dynamic tvrage;

  Ids({
    required this.trakt,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
    required this.tvrage,
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"],
        tvdb: json["tvdb"],
        imdb: json["imdb"],
        tmdb: json["tmdb"],
        tvrage: json["tvrage"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
        "tvrage": tvrage,
      };
}

class Season {
  int number;
  dynamic title;
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
  dynamic lastWatchedAt;

  Episode({
    required this.number,
    required this.completed,
    required this.lastWatchedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        number: json["number"],
        completed: json["completed"],
        lastWatchedAt: json["last_watched_at"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "completed": completed,
        "last_watched_at": lastWatchedAt,
      };
}
