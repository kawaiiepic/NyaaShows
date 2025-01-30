// To parse this JSON data, do
//
//     final searchResults = searchResultsFromJson(jsonString);

import 'dart:convert';

import '../utils/ids.dart';

List<SearchResults> searchResultsFromJson(String str) => List<SearchResults>.from(json.decode(str).map((x) => SearchResults.fromJson(x)));

String searchResultsToJson(List<SearchResults> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchResults {
  String type;
  double score;
  Movie? movie;
  Movie? show;
  Episode? episode;
  Person? person;
  ListClass? list;

  SearchResults({
    required this.type,
    required this.score,
    this.movie,
    this.show,
    this.episode,
    this.person,
    this.list,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) => SearchResults(
        type: json["type"],
        score: json["score"]?.toDouble(),
        movie: json["movie"] == null ? null : Movie.fromJson(json["movie"]),
        show: json["show"] == null ? null : Movie.fromJson(json["show"]),
        episode: json["episode"] == null ? null : Episode.fromJson(json["episode"]),
        person: json["person"] == null ? null : Person.fromJson(json["person"]),
        list: json["list"] == null ? null : ListClass.fromJson(json["list"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "score": score,
        "movie": movie?.toJson(),
        "show": show?.toJson(),
        "episode": episode?.toJson(),
        "person": person?.toJson(),
        "list": list?.toJson(),
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

class ListClass {
  String name;
  String description;
  String privacy;
  String shareLink;
  String type;
  bool displayNumbers;
  bool allowComments;
  String sortBy;
  String sortHow;
  DateTime createdAt;
  DateTime updatedAt;
  int itemCount;
  int commentCount;
  int likes;
  ListIds ids;
  User user;

  ListClass({
    required this.name,
    required this.description,
    required this.privacy,
    required this.shareLink,
    required this.type,
    required this.displayNumbers,
    required this.allowComments,
    required this.sortBy,
    required this.sortHow,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCount,
    required this.commentCount,
    required this.likes,
    required this.ids,
    required this.user,
  });

  factory ListClass.fromJson(Map<String, dynamic> json) => ListClass(
        name: json["name"],
        description: json["description"],
        privacy: json["privacy"],
        shareLink: json["share_link"],
        type: json["type"],
        displayNumbers: json["display_numbers"],
        allowComments: json["allow_comments"],
        sortBy: json["sort_by"],
        sortHow: json["sort_how"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        itemCount: json["item_count"],
        commentCount: json["comment_count"],
        likes: json["likes"],
        ids: ListIds.fromJson(json["ids"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "privacy": privacy,
        "share_link": shareLink,
        "type": type,
        "display_numbers": displayNumbers,
        "allow_comments": allowComments,
        "sort_by": sortBy,
        "sort_how": sortHow,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "item_count": itemCount,
        "comment_count": commentCount,
        "likes": likes,
        "ids": ids.toJson(),
        "user": user.toJson(),
      };
}

class ListIds {
  int trakt;
  String slug;

  ListIds({
    required this.trakt,
    required this.slug,
  });

  factory ListIds.fromJson(Map<String, dynamic> json) => ListIds(
        trakt: json["trakt"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "slug": slug,
      };
}

class User {
  String username;
  bool private;
  String name;
  bool vip;
  bool vipEp;
  UserIds ids;

  User({
    required this.username,
    required this.private,
    required this.name,
    required this.vip,
    required this.vipEp,
    required this.ids,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        private: json["private"],
        name: json["name"],
        vip: json["vip"],
        vipEp: json["vip_ep"],
        ids: UserIds.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "private": private,
        "name": name,
        "vip": vip,
        "vip_ep": vipEp,
        "ids": ids.toJson(),
      };
}

class UserIds {
  String slug;

  UserIds({
    required this.slug,
  });

  factory UserIds.fromJson(Map<String, dynamic> json) => UserIds(
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
      };
}

class Movie {
  String title;
  int? year;
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

class Person {
  String name;
  PersonIds ids;

  Person({
    required this.name,
    required this.ids,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        name: json["name"],
        ids: PersonIds.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "ids": ids.toJson(),
      };
}

class PersonIds {
  String slug;

  PersonIds({
    required this.slug,
  });

  factory PersonIds.fromJson(Map<String, dynamic> json) => PersonIds(
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
      };
}
