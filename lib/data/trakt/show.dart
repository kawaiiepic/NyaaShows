import 'dart:convert';

Show showFromJson(String str) => Show.fromJson(json.decode(str));

String showToJson(Show data) => json.encode(data.toJson());

class Show {
  int plays;
  DateTime lastWatchedAt;
  DateTime lastUpdatedAt;
  dynamic resetAt;
  ShowClass show;
  List<Season> seasons;

  Show({
    required this.plays,
    required this.lastWatchedAt,
    required this.lastUpdatedAt,
    required this.resetAt,
    required this.show,
    required this.seasons,
  });

  factory Show.fromJson(Map<String, dynamic> json) => Show(
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
        lastUpdatedAt: DateTime.parse(json["last_updated_at"]),
        resetAt: json["reset_at"],
        show: ShowClass.fromJson(json["show"]),
        seasons: List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
        "last_updated_at": lastUpdatedAt.toIso8601String(),
        "reset_at": resetAt,
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

class ShowClass {
  String title;
  int year;
  Ids ids;

  ShowClass({
    required this.title,
    required this.year,
    required this.ids,
  });

  factory ShowClass.fromJson(Map<String, dynamic> json) => ShowClass(
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

class Ids {
  int? trakt;
  String? slug;
  int? tvdb;
  String? imdb;
  int? tmdb;
  dynamic tvrage;

  Ids({
    required this.trakt,
    required this.slug,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
    required this.tvrage,
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"],
        slug: json["slug"],
        tvdb: json["tvdb"],
        imdb: json["imdb"],
        tmdb: json["tmdb"],
        tvrage: json["tvrage"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "slug": slug,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
        "tvrage": tvrage,
      };
}
