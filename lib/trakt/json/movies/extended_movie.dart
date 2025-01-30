// To parse this JSON data, do
//
//     final extendedMovie = extendedMovieFromJson(jsonString);

import 'dart:convert';

import '../utils/ids.dart';

ExtendedMovie extendedMovieFromJson(String str) => ExtendedMovie.fromJson(json.decode(str));

String extendedMovieToJson(ExtendedMovie data) => json.encode(data.toJson());

class ExtendedMovie {
  String title;
  int? year;
  Ids ids;
  String? tagline;
  String overview;
  DateTime? released;
  int runtime;
  String? country;
  DateTime updatedAt;
  dynamic trailer;
  String? homepage;
  String? status;
  double rating;
  int votes;
  int commentCount;
  List<String> languages;
  List<String> availableTranslations;
  List<String> genres;
  String? certification;

  ExtendedMovie({
    required this.title,
    required this.year,
    required this.ids,
    required this.tagline,
    required this.overview,
    required this.released,
    required this.runtime,
    required this.country,
    required this.updatedAt,
    required this.trailer,
    required this.homepage,
    required this.status,
    required this.rating,
    required this.votes,
    required this.commentCount,
    required this.languages,
    required this.availableTranslations,
    required this.genres,
    required this.certification,
  });

  factory ExtendedMovie.fromJson(Map<String, dynamic> json) => ExtendedMovie(
        title: json["title"],
        year: json["year"],
        ids: Ids.fromJson(json["ids"]),
        tagline: json["tagline"],
        overview: json["overview"],
        released: json["released"] != null ? DateTime.parse(json["released"]) : null,
        runtime: json["runtime"],
        country: json["country"],
        updatedAt: DateTime.parse(json["updated_at"]),
        trailer: json["trailer"],
        homepage: json["homepage"],
        status: json["status"],
        rating: json["rating"],
        votes: json["votes"],
        commentCount: json["comment_count"],
        languages: List<String>.from(json["languages"].map((x) => x)),
        availableTranslations: List<String>.from(json["available_translations"].map((x) => x)),
        genres: List<String>.from(json["genres"].map((x) => x)),
        certification: json["certification"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "year": year,
        "ids": ids.toJson(),
        "tagline": tagline,
        "overview": overview,
        "released": released != null ? "${released!.year.toString().padLeft(4, '0')}-${released!.month.toString().padLeft(2, '0')}-${released!.day.toString().padLeft(2, '0')}" : null,
        "runtime": runtime,
        "country": country,
        "updated_at": updatedAt.toIso8601String(),
        "trailer": trailer,
        "homepage": homepage,
        "status": status,
        "rating": rating,
        "votes": votes,
        "comment_count": commentCount,
        "languages": List<dynamic>.from(languages.map((x) => x)),
        "available_translations": List<dynamic>.from(availableTranslations.map((x) => x)),
        "genres": List<dynamic>.from(genres.map((x) => x)),
        "certification": certification,
      };
}