import 'dart:convert';

import 'single_episode.dart';

class Show {
  String? title;
  int? year;
  Ids? ids;
  String? tagline;
  String? overview;
  DateTime? firstAired;
  Airs? airs;
  int? runtime;
  String? certification;
  String? network;
  String? country;
  DateTime? updatedAt;
  dynamic trailer;
  String? homepage;
  String? status;
  double? rating;
  int? votes;
  int? commentCount;
  List<String>? languages;
  List<String>? availableTranslations;
  List<String>? genres;
  int? airedEpisodes;

  Show({
    this.title,
    this.year,
    this.ids,
    this.tagline,
    this.overview,
    this.firstAired,
    this.airs,
    this.runtime,
    this.certification,
    this.network,
    this.country,
    this.updatedAt,
    this.trailer,
    this.homepage,
    this.status,
    this.rating,
    this.votes,
    this.commentCount,
    this.languages,
    this.availableTranslations,
    this.genres,
    this.airedEpisodes,
  });

  factory Show.fromRawJson(String str) => Show.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Show.fromJson(Map<String, dynamic> json) => Show(
        title: json["title"],
        year: json["year"],
        ids: json["ids"] == null ? null : Ids.fromJson(json["ids"]),
        tagline: json["tagline"],
        overview: json["overview"],
        firstAired: json["first_aired"] == null ? null : DateTime.parse(json["first_aired"]),
        airs: json["airs"] == null ? null : Airs.fromJson(json["airs"]),
        runtime: json["runtime"],
        certification: json["certification"],
        network: json["network"],
        country: json["country"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        trailer: json["trailer"],
        homepage: json["homepage"],
        status: json["status"],
        rating: json["rating"],
        votes: json["votes"],
        commentCount: json["comment_count"],
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        availableTranslations: json["available_translations"] == null ? [] : List<String>.from(json["available_translations"]!.map((x) => x)),
        genres: json["genres"] == null ? [] : List<String>.from(json["genres"]!.map((x) => x)),
        airedEpisodes: json["aired_episodes"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "year": year,
        "ids": ids?.toJson(),
        "tagline": tagline,
        "overview": overview,
        "first_aired": firstAired?.toIso8601String(),
        "airs": airs?.toJson(),
        "runtime": runtime,
        "certification": certification,
        "network": network,
        "country": country,
        "updated_at": updatedAt?.toIso8601String(),
        "trailer": trailer,
        "homepage": homepage,
        "status": status,
        "rating": rating,
        "votes": votes,
        "comment_count": commentCount,
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
        "available_translations": availableTranslations == null ? [] : List<dynamic>.from(availableTranslations!.map((x) => x)),
        "genres": genres == null ? [] : List<dynamic>.from(genres!.map((x) => x)),
        "aired_episodes": airedEpisodes,
      };
}

class Airs {
  String? day;
  String? time;
  String? timezone;

  Airs({
    this.day,
    this.time,
    this.timezone,
  });

  factory Airs.fromRawJson(String str) => Airs.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Airs.fromJson(Map<String, dynamic> json) => Airs(
        day: json["day"],
        time: json["time"],
        timezone: json["timezone"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "time": time,
        "timezone": timezone,
      };
}