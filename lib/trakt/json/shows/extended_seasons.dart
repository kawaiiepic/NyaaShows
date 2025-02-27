import 'dart:convert';

import '../utils/ids.dart';

List<ExtendedSeason> extendedSeasonsFromJson(String str) {
  List<ExtendedSeason> seasons = [];
  List<dynamic> json = jsonDecode(str);

  for (var entry in json) {
    DateTime firstAired;
    if (entry['first_aired'] == null) {
      firstAired = DateTime.parse('2012-02-27');
    } else {
      firstAired = DateTime.parse(entry["first_aired"]);
    }
    var season = ExtendedSeason(
      number: entry["number"],
      ids: Ids.fromJson(entry["ids"]),
      rating: entry["rating"],
      votes: entry["votes"],
      episodeCount: entry["episode_count"],
      airedEpisodes: entry["aired_episodes"],
      title: entry["title"],
      overview: entry["overview"] ?? '',
      firstAired: firstAired, // entry["first_aired"]
      updatedAt: entry["updated_at"],
      network: entry["network"],
    );
    seasons.add(season);
  }
  return seasons;
}

String extendedSeasonsToJson(List<ExtendedSeason> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExtendedSeason {
  int number;
  Ids ids;
  double rating;
  int votes;
  int episodeCount;
  int airedEpisodes;
  String title;
  String? overview;
  DateTime? firstAired;
  String updatedAt;
  String network;

  ExtendedSeason({
    required this.number,
    required this.ids,
    required this.rating,
    required this.votes,
    required this.episodeCount,
    required this.airedEpisodes,
    required this.title,
    required this.overview,
    required this.firstAired,
    required this.updatedAt,
    required this.network,
  });

  factory ExtendedSeason.fromJson(var json) {
    return ExtendedSeason(
      number: json["number"],
      // ids: Ids.fromJson(json["ids"]),
      ids: Ids.fromJson(json["ids"]),
      rating: json["rating"],
      votes: json["votes"],
      episodeCount: json["episode_count"],
      airedEpisodes: json["aired_episodes"],
      title: json["title"],
      overview: json["overview"],
      firstAired: DateTime.parse(json["first_aired"]),
      updatedAt: json["udpated_at"],
      network: json["network"],
    );
  }

  Map<String, dynamic> toJson() => {
        "number": number,
        "ids": ids.toJson(),
        "rating": rating,
        "votes": votes,
        "episode_count": episodeCount,
        "aired_episodes": airedEpisodes,
        "title": title,
        "overview": overview,
        "first_aired": firstAired?.toIso8601String(),
        "updated_at": updatedAt,
        "network": network,
      };
}
