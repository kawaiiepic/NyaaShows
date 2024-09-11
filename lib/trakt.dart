import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/data/data_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class TraktModel with ChangeNotifier {
  void auth(
    BuildContext context,
  ) async {
    var traktData = DataManager.traktData;
    traktData.retriveToken().then((_) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Trakt Auth'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('@${traktData.displayName}'),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          DataManager.traktData.revolkToken();
                        },
                        child: const Text('Disconnect Trakt')),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                      },
                      child: const Text("Cancel"))
                ],
              ));
    }).onError((_, except) async {
      final url = Uri.https('api.trakt.tv', '/oauth/device/code');
      var response = await http.post(url, body: {
        'client_id': await rootBundle.loadString('keys/trakt_client_id.key')
      });

      print(response.body);
      if (response.statusCode == 200 && context.mounted) {
        Map json = jsonDecode(response.body);

        String deviceCode = "";
        String userCode = "";
        String verificationUrl = "";
        int expiresIn = -1;
        int interval = -1;
        json.forEach((key, value) {
          switch (key) {
            case 'device_code':
              deviceCode = value;
            case 'user_code':
              userCode = value;
            case 'verification_url':
              verificationUrl = value;
            case 'expires_in':
              expiresIn = value;
            case 'interval':
              interval = value;
          }
        });

        var timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
          //TODO: Implement ExpiresIn and Interval.
          var hasAccessToken = false;

          final url = Uri.https('api.trakt.tv', '/oauth/device/token');
          var response = await http.post(url, body: {
            'code': deviceCode,
            'client_id':
                await rootBundle.loadString('keys/trakt_client_id.key'),
            'client_secret': await rootBundle.loadString('keys/traktSecret')
          });

          if (response.statusCode == 200) {
            hasAccessToken = true;
            print("Acess Token!");
            print(response.body);
            Map json = jsonDecode(response.body);
            String accessToken = "";
            String tokenType = "";
            int expiresIn = -1;
            String refreshToken = "";
            String scope = "";
            int createdAt = -1;

            json.forEach((key, value) {
              switch (key) {
                case 'access_token':
                  accessToken = value;
                case 'token_type':
                  tokenType = value;
                case 'expires_in':
                  expiresIn = value;
                case 'refresh_token':
                  refreshToken = value;
                case 'scope':
                  scope = value;
                case 'created_at':
                  createdAt = value;
              }
            });

            if (accessToken.isNotEmpty) // TODO: Check all variables
            {
              DataManager.traktData.storeToken(accessToken, tokenType,
                  expiresIn, refreshToken, scope, createdAt);
            }
            timer.cancel();
          } else {
            print('Access Token failed, ${response.statusCode}');
          }
        });

        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Trakt Auth'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () async {
                            if (!await launchUrl(
                              Uri.parse(verificationUrl),
                              mode: LaunchMode.platformDefault,
                              browserConfiguration:
                                  const BrowserConfiguration(showTitle: true),
                            )) {
                              throw Exception('Could not launch website');
                            }
                          },
                          child: const Text('Trakt Activate Page.')),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Code: '),
                            SelectableText(userCode)
                          ]),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                          timer.cancel();
                        },
                        child: const Text("Cancel"))
                  ],
                ));
      }
    });
  }
}

class Trakt with ChangeNotifier {


}

Show showFromJson(String str) => Show.fromJson(json.decode(str));

String showToJson(Show data) => json.encode(data.toJson());

class Show {
  int plays;
  DateTime lastWatchedAt;
  DateTime lastUpdatedAt;
  dynamic resetAt;
  ShowClass show;
  List<Season> seasons;

  Show({
    required this.plays,
    required this.lastWatchedAt,
    required this.lastUpdatedAt,
    required this.resetAt,
    required this.show,
    required this.seasons,
  });

  factory Show.fromJson(Map<String, dynamic> json) => Show(
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
        lastUpdatedAt: DateTime.parse(json["last_updated_at"]),
        resetAt: json["reset_at"],
        show: ShowClass.fromJson(json["show"]),
        seasons:
            List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
        "last_updated_at": lastUpdatedAt.toIso8601String(),
        "reset_at": resetAt,
        "show": show.toJson(),
        "seasons": List<dynamic>.from(seasons.map((x) => x.toJson())),
      };
}

class Season {
  int number;
  List<Episode> episodes;

  Season({
    required this.number,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        number: json["number"],
        episodes: List<Episode>.from(
            json["episodes"].map((x) => Episode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
      };
}

class Episode {
  int number;
  int plays;
  DateTime lastWatchedAt;

  Episode({
    required this.number,
    required this.plays,
    required this.lastWatchedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        number: json["number"],
        plays: json["plays"],
        lastWatchedAt: DateTime.parse(json["last_watched_at"]),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "plays": plays,
        "last_watched_at": lastWatchedAt.toIso8601String(),
      };
}

class ShowClass {
  String title;
  int year;
  Ids ids;

  ShowClass({
    required this.title,
    required this.year,
    required this.ids,
  });

  factory ShowClass.fromJson(Map<String, dynamic> json) => ShowClass(
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

class Ids {
  int trakt;
  String slug;
  int tvdb;
  String? imdb;
  int? tmdb;
  dynamic tvrage;

  Ids({
    required this.trakt,
    required this.slug,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
    required this.tvrage,
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"],
        slug: json["slug"],
        tvdb: json["tvdb"],
        imdb: json["imdb"],
        tmdb: json["tmdb"],
        tvrage: json["tvrage"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "slug": slug,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
        "tvrage": tvrage,
      };
}



