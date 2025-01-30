import 'dart:convert';

import '../utils/ids.dart';

Season seasonFromJson(String str) => Season.fromJson(json.decode(str));
String seasonToJson(Season data) => json.encode(data.toJson());

class Season {
  int number;
  Ids ids;

  Season({
    required this.number,
    required this.ids,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        number: json["number"],
        ids: Ids.fromJson(json['ids']),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "ids": ids.toJson(),
      };
}
