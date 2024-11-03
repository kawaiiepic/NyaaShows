// To parse this JSON data, do
//
//     final singleSeason = singleSeasonFromJson(jsonString);

import 'dart:convert';


import 'single_episode.dart';

SingleSeason singleSeasonFromJson(String str) =>
    SingleSeason.fromJson(json.decode(str));

String singleSeasonToJson(SingleSeason data) => json.encode(data.toJson());

class SingleSeason {
  int number;
  Ids ids;
  double rating;
  int votes;
  int episodeCount;
  int airedEpisodes;
  String title;
  String? overview;
  DateTime firstAired;
  String udpatedAt;
  String network;

  SingleSeason({
    required this.number,
    required this.ids,
    required this.rating,
    required this.votes,
    required this.episodeCount,
    required this.airedEpisodes,
    required this.title,
    required this.overview,
    required this.firstAired,
    required this.udpatedAt,
    required this.network,
  });

  factory SingleSeason.fromJson(Map<String, dynamic> json) => SingleSeason(
        number: json["number"],
        ids: Ids.fromJson(json["ids"]),
        rating: json["rating"],
        votes: json["votes"],
        episodeCount: json["episode_count"],
        airedEpisodes: json["aired_episodes"],
        title: json["title"],
        overview: json["overview"],
        firstAired: DateTime.parse(json["first_aired"]),
        udpatedAt: json["updated_at"],
        network: json["network"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "ids": ids.toJson(),
        "rating": rating,
        "votes": votes,
        "episode_count": episodeCount,
        "aired_episodes": airedEpisodes,
        "title": title,
        "overview": overview,
        "first_aired": firstAired.toIso8601String(),
        "updated_at": udpatedAt,
        "network": network,
      };
}
