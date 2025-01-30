import 'dart:convert';

import '../shows/show.dart';

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