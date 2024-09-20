// To parse this JSON data, do
//
//     final singleEpisode = singleEpisodeFromJson(jsonString);

import 'dart:convert';

SingleEpisode singleEpisodeFromJson(String str) => SingleEpisode.fromJson(json.decode(str));

String singleEpisodeToJson(SingleEpisode data) => json.encode(data.toJson());

class SingleEpisode {
  int number;
  Map<String, int> ids;
  int rating;
  int votes;
  int episodeCount;
  int airedEpisodes;
  String title;
  String overview;
  DateTime firstAired;
  String udpatedAt;
  String network;

  SingleEpisode({
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

  factory SingleEpisode.fromJson(Map<String, dynamic> json) => SingleEpisode(
        number: json["number"],
        ids: Map.from(json["ids"]).map((k, v) => MapEntry<String, int>(k, v)),
        rating: json["rating"],
        votes: json["votes"],
        episodeCount: json["episode_count"],
        airedEpisodes: json["aired_episodes"],
        title: json["title"],
        overview: json["overview"],
        firstAired: DateTime.parse(json["first_aired"]),
        udpatedAt: json["udpated_at"],
        network: json["network"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "ids": Map.from(ids).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "rating": rating,
        "votes": votes,
        "episode_count": episodeCount,
        "aired_episodes": airedEpisodes,
        "title": title,
        "overview": overview,
        "first_aired": firstAired.toIso8601String(),
        "udpated_at": udpatedAt,
        "network": network,
      };
}
