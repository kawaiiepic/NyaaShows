// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/trakt/json/sync/playback_progress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common.dart';
import '../utils/exceptions.dart';
import 'json/enum/search_type.dart';
import 'json/combined_show.dart';
import 'json/enum/media_type.dart';
import 'json/shows/extended_seasons.dart';
import 'json/shows/extended_show.dart';
import 'json/shows/season_episodes.dart';
import 'json/shows/show.dart';
import 'json/shows/watched_progress.dart';
import 'json/sync/watched.dart';
import 'json/users/extended_profile.dart';
import 'json/users/hidden_items.dart';
import '../../trakt/json/search/search.dart' as json_search;

class TraktJson {
  static bool _nextUpLoaded = false;
  static Future<List<CombinedShow>> _nextUpFuture = Future.value([]);
  static List<HiddenItems> _hiddenShows = [];
  static Future<List<PlaybackProgress>> _playbackProgressFuture = TraktJson._playbackProgress();
  static final Map<String, Show> _shows = {};
  static final Map<String, ExtendedShow> _extendedShows = {};
  static final Map<String, WatchedProgress> _progress = {};
  static ExtendedProfile? _profile;
  static String? token;

  static Future<void> auth(BuildContext context) async {
    if (await hasAccessToken()) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('trakt settings'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('@Placeholder'),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          revolkToken();
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
    } else {
      final url = Uri.https('api.trakt.tv', '/oauth/device/code');
      var response = await post(url, body: {'client_id': (await rootBundle.loadString('keys')).split(',')[0]});

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

        final completer = Completer<bool>();
        var timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
          //TODO: Implement ExpiresIn and Interval.
          var hasAccessToken = false;

          final url = Uri.https('api.trakt.tv', '/oauth/device/token');
          var response = await post(url, body: {
            'code': deviceCode,
            'client_id': (await rootBundle.loadString('keys')).split(',')[0],
            'client_secret': (await rootBundle.loadString('keys')).split(',')[1]
          });

          if (response.statusCode == 200) {
            hasAccessToken = true;
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
              final file = await Common.dirJson('trakt');

              Map<String, dynamic> data = {
                'access_token': accessToken,
                'token_type': tokenType,
                'expires_in': expiresIn,
                'refresh_token': refreshToken,
                'scope': scope,
                'created_at': createdAt
              };

              file.writeAsString(jsonEncode(data));

              // DataManager.traktData.storeToken(accessToken, tokenType, expiresIn, refreshToken, scope, createdAt);
              Navigator.pop(context, 'Submit');
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            }
            timer.cancel();
          } else {
            print('Access Token failed, ${response.statusCode}');
          }
        });

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('(Re-)Authenticate trakt'),
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

        final result = await completer.future;
        print("Results obtained!");
      }
    }
  }

  static Future<void> startWatching(MediaType mediaType, Object object) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/scrobble/start');
      var response = await post(url,
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
            'trakt-api-version': '2'
          },
          body: json.encode(object));
    }
  }

  static Future<void> pauseWatching(MediaType mediaType, Object object) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/scrobble/pause');
      await post(url,
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
            'trakt-api-version': '2'
          },
          body: json.encode(object));
    }
  }

  static Future<void> stopWatching(MediaType mediaType, int progress, String traktId) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      print('Stop watching, progress: $progress');

      var object;
      switch (mediaType) {
        case MediaType.episode:
          {
            if (progress >= 80) {
              // removePlaybackItem(traktId);
            }
            object = {
              "progress": progress,
              "episode": {
                "ids": {"trakt": traktId}
              }
            };
          }
        case MediaType.movie:
        // TODO: Handle this case.
        case MediaType.show:
        // TODO: Handle this case.
        case MediaType.season:
        // TODO: Handle this case.
        case MediaType.person:
        // TODO: Handle this case.
        case MediaType.user:
        // TODO: Handle this case.
      }

      var url = Uri.https('api.trakt.tv', '/scrobble/stop');
      await post(url,
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
            'trakt-api-version': '2'
          },
          body: json.encode(object));
    }
  }

  static Future<List<PlaybackProgress>> playbackProgress({forceReload = false}) async {
    if ((await _playbackProgressFuture).isEmpty || forceReload) {
      print('Changed _playbackProgressFuture');
      Future<List<PlaybackProgress>> progress = _playbackProgress();

      return _playbackProgressFuture = progress;
    } else {
      return _playbackProgressFuture;
    }
  }

  static Future<List<PlaybackProgress>> _playbackProgress() async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/sync/playback');
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      switch (response.statusCode) {
        case 200:
          {
            List<PlaybackProgress> progress = playbackProgressFromJson(response.body);
            return progress;
          }
        default:
          return Future.error(UnknownStatusCode());
      }
    } else {
      return Future.error(MissingTraktAccessToken);
    }
  }

  static Future<void> removePlaybackItem(int id) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/sync/playback/$id');
      var response = await delete(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      print(response.statusCode + id);

      switch (response.statusCode) {
        case 204:
          {
            print('Removed playback: $id');
            playbackProgress(forceReload: true);
          }

        case 404:
          Exception('Failed to remove playback');
      }
    }
  }

  static Future<List<json_search.Search>> search(SearchType type, String query) async {
    return accessToken().then((token) async {
      var url = Uri.https('api.trakt.tv', '/search/show', {'query': query});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      List<json_search.Search> entries = [];

      if (response.statusCode == 200) {
        var int = 0;
        for (var boop in jsonDecode(response.body)) {
          if (int == 4) {
            break;
          }
          json_search.Search entry = json_search.Search.fromJson(boop);
          entries.add(entry);
          int++;
        }
        return entries;
      }
      throw Future.error(Exception());
    });
  }

  static Future<Show> showFromId(String id) async {
    if (_shows.containsKey(id)) {
      return _shows[id]!;
    } else {
      final Show show = await _showFromId(id);
      return _shows[id] = show;
    }
  }

  static Future<Show> _showFromId(String id) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/shows/$id', {'extended': 'full'});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      switch (response.statusCode) {
        case 200:
          {
            var show = Show.fromJson(jsonDecode(response.body));
            return show;
          }
        default:
          return Future.error(UnknownStatusCode());
      }
    } else {
      return Future.error(MissingTraktAccessToken);
    }
  }

  static Future<ExtendedShow> extendedShowFromId(String id) async {
    if (_extendedShows.containsKey(id)) {
      return _extendedShows[id]!;
    } else {
      final ExtendedShow extendedShow = await _extendedShowFromId(id);
      return _extendedShows[id] = extendedShow;
    }
  }

  static Future<ExtendedShow> _extendedShowFromId(String id) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/shows/$id', {'extended': 'full'});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      switch (response.statusCode) {
        case 200:
          {
            var show = ExtendedShow.fromJson(jsonDecode(response.body));
            return show;
          }
        default:
          return Future.error(UnknownStatusCode());
      }
    } else {
      return Future.error(MissingTraktAccessToken);
    }
  }

  static Future<void> revolkToken() async {
    final file = await Common.dirJson('trakt');
    file.exists().then((value) => file.delete());
  }

  static Future<String> retriveToken() async {
    final file = await Common.dirJson('trakt');

    return file.exists().then((value) async {
      // Check if access_token is expired!
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      Future<String> val = Future<String>.value("");
      json.forEach((key, value) async {
        if (key == "access_token") {
          val = Future.value(value as String);
        }
      });

      return await val;
    });
  }

  static Future<String> _accessToken() async {
    final file = await Common.dirJson('trakt');
    final exists = await file.exists();
    if (exists) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());

      token = json['access_token'];

      return token!;
    } else {
      return Future.error(Exception('Missing trakt file'));
    }
  }

  static Future<String> accessToken() async {
    print('Trakt api call!');
    if (token != null) {
      return token!;
    } else {
      return _accessToken();
    }
  }

  static Future<bool> hasAccessToken() {
    final file = Common.dirJson('trakt');

    return file.then((file) async {
      if (await file.exists()) {
        return true;
      } else {
        return false;
      }
    });
  }

  static Future<ExtendedProfile> userProfile() async {
    if (_profile == null) {
      return _profile = await _userProfile();
    } else {
      return _profile!;
    }
  }

  static Future<ExtendedProfile> _userProfile() async {
    final token = await accessToken();
    var url = Uri.https('api.trakt.tv', '/users/me', {'extended': 'full'});
    var response = await get(url, headers: {
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
    });

    if (response.statusCode == 200) {
      final profile = profileFromJson(response.body);

      return profile;
    }

    return Future.error(Exception('Failed to get users/me'));
  }

  static Future<List<CombinedShow>> nextUp({page = 0, forceReload = false}) async {
    if ((await _nextUpFuture).isEmpty || forceReload) {
      Future<List<CombinedShow>> shows = _nextUp(page: page);

      return _nextUpFuture = shows;
    } else {
      return _nextUpFuture;
    }
  }

  static Future<List<CombinedShow>> _nextUp({page = 0}) async {
    print('Next Up');
    var token = await accessToken();
    //TODO: Implement Hidden Shows. https://trakt.docs.apiary.io/#reference/users/hidden-items/get-hidden-items
    var url = Uri.https('api.trakt.tv', '/sync/watched/shows', {'extended': 'noseasons'});
    var response = await get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      // print(jsonDecode(response.body)[0]);
      var watched = watchedFromJson(response.body);
      var hidden = (await hiddenShows());

      List<CombinedShow> shows = [];

      var startInt = 20 * page; // 1st page (0-9), 2nd page (10-19)
      var endInt = startInt + 19;
      var currentInt = 0;

      for (var show in watched) {
        var traktId = show.show.ids!.trakt;
        var skip = false;

        for (var hide in hidden) {
          if (hide.show!.ids!.trakt == show.show.ids!.trakt) {
            skip = true;
          }
        }

        if (skip) {
          continue;
        }

        var url2 = Uri.https('api.trakt.tv', '/shows/$traktId/progress/watched');
        var response2 = await get(url2, headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
          'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
          'trakt-api-version': '2'
        });

        if (response2.statusCode == 200) {
          var watchedProgress = watchedProgressFromJson(response2.body);
          if (watchedProgress.aired != watchedProgress.completed && watchedProgress.nextEpisode != null) {
            if (currentInt >= startInt && currentInt <= endInt) {
              shows.add(CombinedShow(show: show.show, watchedProgress: watchedProgress));
            } else if (currentInt > endInt) {
              break;
            }
            currentInt++;
          }
        }
      }
      return shows;
    } else {
      return Future.error(Exception('Unable to obtain Next Up'));
    }
  }

  static Future<List<HiddenItems>> hiddenShows() async {
    if (_hiddenShows.isNotEmpty) {
      return _hiddenShows;
    } else {
      return _hiddenShows = await __hiddenShows();
    }
  }

  static Future<List<HiddenItems>> __hiddenShows() async {
    print('Hidden Shows');
    var token = (await accessToken());
    var url = Uri.https('api.trakt.tv', '/users/hidden/progress_watched', {'type': 'show'});
    var response = await get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      var hiddenItems = hiddenItemsFromJson(response.body);
      return hiddenItems;
    } else {
      return Future.error(Exception());
    }
  }

  static Future<WatchedProgress> watchedProgress(String id) async {
    if (_progress.containsKey(id)) {
      return _progress[id]!;
    } else {
      return _progress[id] = await _watchedProgress(id);
    }
  }

  static Future<WatchedProgress> _watchedProgress(String id) async {
    final token = await accessToken();
    var url = Uri.https('api.trakt.tv', '/shows/$id/progress/watched');
    var response = await get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      final progress = watchedProgressFromJson(response.body);
      return progress;
    } else {
      return Future.error(Exception('Failed to get shows"s progress.'));
    }
  }

  static Future<List<ExtendedSeason>> seasonsFromId(id) async {
    print('SeasonsFromID');
    final token = await accessToken();
    final url = Uri.https('api.trakt.tv', '/shows/$id/seasons', {'extended': 'full'});
    final response = await get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      List<ExtendedSeason> seasons = extendedSeasonsFromJson(response.body);
      return seasons;
    } else {
      return Future.error(Exception('Failed obtaining seasons'));
    }
  }

  static Future<List<SeasonEpisodes>> seasonEpisodes(id, season) async {
    print('Season Episodes');
    print('ID: $id & Season: $season');
    final token = await accessToken();
    final url = Uri.https('api.trakt.tv', '/shows/$id/seasons/$season');
    final response = await get(url, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
      'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      return seasonEpisodesFromJson(response.body);
    } else {
      return Future.error(Exception());
    }
  }
}
