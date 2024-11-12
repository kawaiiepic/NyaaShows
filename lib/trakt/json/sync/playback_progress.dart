import 'dart:convert';

import '../utils/ids.dart';

List<PlaybackProgress> playbackProgressFromJson(String str) => List<PlaybackProgress>.from(json.decode(str).map((x) => PlaybackProgress.fromJson(x)));

String playbackProgressToJson(List<PlaybackProgress> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlaybackProgress {
  double progress;
  DateTime pausedAt;
  int id;
  String type;
  Movie? movie;
  Episode? episode;
  Movie? show;

  PlaybackProgress({
    required this.progress,
    required this.pausedAt,
    required this.id,
    required this.type,
    this.movie,
    this.episode,
    this.show,
  });

  factory PlaybackProgress.fromJson(Map<String, dynamic> json) => PlaybackProgress(
        progress: json["progress"]?.toDouble(),
        pausedAt: DateTime.parse(json["paused_at"]),
        id: json["id"],
        type: json["type"],
        movie: json["movie"] == null ? null : Movie.fromJson(json["movie"]),
        episode: json["episode"] == null ? null : Episode.fromJson(json["episode"]),
        show: json["show"] == null ? null : Movie.fromJson(json["show"]),
      );

  Map<String, dynamic> toJson() => {
        "progress": progress,
        "paused_at": pausedAt.toIso8601String(),
        "id": id,
        "type": type,
        "movie": movie?.toJson(),
        "episode": episode?.toJson(),
        "show": show?.toJson(),
      };
}

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
