import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/data/trakt/all_seasons.dart';
import 'package:nyaashows/data/trakt/episodes_from_season.dart';
import 'package:nyaashows/data/trakt/profile.dart';
// import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/data/trakt/single_episode.dart';
import 'package:nyaashows/data/trakt/single_season.dart';
import 'package:nyaashows/data/trakt/watched.dart';
import 'package:nyaashows/data/trakt/watched_progress.dart' as watched_progress;
import 'package:nyaashows/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Trakt with ChangeNotifier {
  List<CombinedShow> _nextUpFuture = [];

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
                    Text('@Placeholder'),
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
      var response = await http.post(url, body: {'client_id': await rootBundle.loadString('keys/trakt_client_id.key')});

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
            'client_id': await rootBundle.loadString('keys/trakt_client_id.key'),
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
              DataManager.traktData.storeToken(accessToken, tokenType, expiresIn, refreshToken, scope, createdAt);
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
                              browserConfiguration: const BrowserConfiguration(showTitle: true),
                            )) {
                              throw Exception('Could not launch website');
                            }
                          },
                          child: const Text('Trakt Activate Page.')),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Code: '), SelectableText(userCode)]),
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

  Future<List<Season>> seasonsFromId({required id}) async {
    return accessToken().then((value) async {
      final url = Uri.https('api.trakt.tv', '/shows/$id/seasons', {'extended': 'full'});
      final response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        List<Season> seasons = seasonFromJson(response.body);
        return seasons;
      } else {
        return Future.value(null);
      }
      // return Future.value();
    });
  }

  Future<List<EpisodesFromSeason>> episodesFromSeason({required id, required season}) async {
    return accessToken().then((token) async {
      final url = Uri.https('api.trakt.tv', '/shows/$id/seasons/$season');
      final response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        List<EpisodesFromSeason> episodes = episodesFromSeasonFromJson(response.body);
        return episodes;
      } else {
        return Future.value(null);
      }
    });
  }

  Future<SingleEpisode> episodeFromNumber({required show, season = 0, required episode}) async {
    //TODO: Save episode images and data.
    late final SingleEpisode singleEpisode;
    await accessToken().then((value) async {
      final url = Uri.https('api.trakt.tv', '/shows/$show/seasons/$season/episodes/$episode');
      final response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        singleEpisode = singleEpisodeFromJson(response.body);
      }
    });
    return singleEpisode;
  }

  Future<SingleSeason?> seasonFromNumber({required show, required season}) async {
    //TODO: Save episode images and data.
    return accessToken().then((value) async {
      final url = Uri.https('api.trakt.tv', '/shows/$show/seasons/$season/info', {'extended': 'full'});
      final response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        var singleSeason = singleSeasonFromJson(response.body);
        return singleSeason;
      } else {
        return null;
      }
    });
  }

  Future<List<CombinedShow>?> nextUp({page = 0, forceReload = false}) async {
    if (_nextUpFuture.isEmpty || forceReload) {
      return _nextUp(page: page).then((shows) {
        if (shows != null) {
          _nextUpFuture = shows;
          return _nextUpFuture;
        } else {
          return null;
        }
      });
    } else {
      return _nextUpFuture;
    }
  }

  Future<List<CombinedShow>?> _nextUp({page = 0}) async { //TODO: Implement Hidden Shows. https://trakt.docs.apiary.io/#reference/users/hidden-items/get-hidden-items
    return accessToken().then((token) async {
      NyaaShows.log('[Next Up]');
      var url = Uri.https('api.trakt.tv', '/sync/watched/shows', {'extended': 'noseasons'});
      var response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        var watched = watchedFromJson(response.body);

        List<CombinedShow> shows = [];

        var startInt = 10 * page; // 1st page (0-9), 2nd page (10-19)
        var endInt = startInt + 9;
        var currentInt = 0;

        for (var show in watched) {
          var traktId = show.show.ids.trakt;

          var url2 = Uri.https('api.trakt.tv', '/shows/$traktId/progress/watched');
          var response2 = await http.get(url2, headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
            'trakt-api-version': '2'
          });

          if (response2.statusCode == 200) {
            var watchedProgress = watched_progress.watchedProgressFromJson(response2.body);
            if (watchedProgress.aired != watchedProgress.completed && watchedProgress.nextEpisode != null) {
              if (currentInt >= startInt && currentInt <= endInt) {
                shows.add(CombinedShow(show: show.show, watchedProgress: watchedProgress));
                NyaaShows.log(
                'In-Progress: ${show.show.title} | Next Up: ${watchedProgress.nextEpisode!.title} - ${watchedProgress.nextEpisode!.season}:${watchedProgress.nextEpisode!.number}');
              } else if (currentInt > endInt) {
                break;
              }
              currentInt++;
            }
          }
        }
        return shows;
      } else {
        return null;
      }
    });
  }

  Future<Profile?> userData() async {
    return accessToken().then((value) async {
      var url = Uri.https('api.trakt.tv', '/users/me', {'extended': 'full'});
      var response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        return profileFromJson(response.body);
      } else {
        return null;
      }
    });
  }

  Future<String> accessToken() async {
    final file = await NyaaShows.dataManager.dataFile('user');

    return file.exists().then((value) async {
      // Check if access_token is expired!
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      Future<String> val = Future<String>.value("");
      json.forEach((key, value) async {
        // developer.log('Key: $key, Value: $value');
        if (key == "access_token") {
          val = Future.value(value as String);
          // print("Access Token exists!");
          // print(value);
        }
      });

      return await val;
    });
  }
}

class CombinedShow {
  watched_progress.WatchedProgress watchedProgress;
  Show show;

  CombinedShow({required this.show, required this.watchedProgress});
}
