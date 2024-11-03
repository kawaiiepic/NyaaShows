// To parse this JSON data, do
//
//     final watched = watchedFromJson(jsonString);

import 'dart:convert';

import 'package:nyaashows/data/trakt/show.dart';


List<Watched> watchedFromJson(String str) => List<Watched>.from(json.decode(str).map((x) => Watched.fromJson(x)));

String watchedToJson(List<Watched> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Watched {
  int plays;
  DateTime lastWatchedAt;
  DateTime lastUpdatedAt;
  DateTime? resetAt;
  Show show;

  Watched({
    required this.plays,
    required this.lastWatchedAt,
    required this.lastUpdatedAt,
    required this.resetAt,
    required this.show,
  });

  factory Watched.fromJson(Map<String, dynamic> json) => Watched(
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
        lastUpdatedAt: DateTime.parse(json["last_updated_at"]),
        resetAt: json["reset_at"] == null ? null : DateTime.parse(json["reset_at"]),
        show: Show.fromJson(json["show"]),
      );

  Map<String, dynamic> toJson() => {
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
        "last_updated_at": lastUpdatedAt.toIso8601String(),
        "reset_at": resetAt?.toIso8601String(),
        "show": show.toJson(),
      };
}
