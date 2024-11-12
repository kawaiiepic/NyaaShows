import 'dart:convert';

import '../utils/ids.dart';

List<SeasonEpisodes> seasonEpisodesFromJson(String str) => List<SeasonEpisodes>.from(json.decode(str).map((x) => SeasonEpisodes.fromJson(x)));
String seasonEpisodesToJson(List<SeasonEpisodes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SeasonEpisodes {
  int season;
  int number;
  String title;
  Ids ids;

  SeasonEpisodes({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });

  factory SeasonEpisodes.fromJson(Map<String, dynamic> json) => SeasonEpisodes(
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
