// To parse this JSON data, do
//
//     final hiddenItems = hiddenItemsFromJson(jsonString);

import 'dart:convert';

import 'single_episode.dart';

List<HiddenItems> hiddenItemsFromJson(String str) => List<HiddenItems>.from(json.decode(str).map((x) => HiddenItems.fromJson(x)));

String hiddenItemsToJson(List<HiddenItems> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HiddenItems {
  DateTime? hiddenAt;
  String? type;
  Show? show;

  HiddenItems({
    this.hiddenAt,
    this.type,
    this.show,
  });

  factory HiddenItems.fromJson(Map<String, dynamic> json) => HiddenItems(
        hiddenAt: json["hidden_at"] == null ? null : DateTime.parse(json["hidden_at"]),
        type: json["type"],
        show: json["show"] == null ? null : Show.fromJson(json["show"]),
      );

  Map<String, dynamic> toJson() => {
        "hidden_at": hiddenAt?.toIso8601String(),
        "type": type,
        "show": show?.toJson(),
      };
}

class Show {
  String? title;
  int? year;
  Ids? ids;

  Show({
    this.title,
    this.year,
    this.ids,
  });

  factory Show.fromJson(Map<String, dynamic> json) => Show(
        title: json["title"],
        year: json["year"],
        ids: json["ids"] == null ? null : Ids.fromJson(json["ids"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "year": year,
        "ids": ids?.toJson(),
      };
}