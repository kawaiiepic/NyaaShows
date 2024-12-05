// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart';
import 'package:nyaashows/trakt/json/sync/playback_progress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common.dart';
import '../utils/exceptions.dart';
import 'json/enum/search_type.dart';
import 'json/combined_show.dart';
import 'json/enum/media_type.dart';
import 'json/movies/extended_movie.dart';
import 'json/shows/extended_seasons.dart';
import 'json/shows/extended_show.dart';
import 'json/shows/season_episodes.dart';
import 'json/shows/episode.dart' as ShowsEpisode;
import 'json/shows/show.dart';
import 'json/shows/watched_progress.dart';
import 'json/sync/watched.dart';
import 'json/users/extended_profile.dart';
import 'json/users/hidden_items.dart';
import '../../trakt/json/search/search.dart' as json_search;

class TraktJson {
  static final bool _nextUpLoaded = false;
  static Future<List<Watched>> nextUpFuture = Future.value([]);
  static List<HiddenItems> _hiddenShows = [];
  static Future<List<PlaybackProgress>> playbackProgressFuture = Future.value([]);
  static final Map<String, Show> _shows = {};
  static final Map<String, ExtendedShow> _extendedShows = {};
  static final Map<String, ExtendedMovie> _extendedMovies = {};
  static final Map<String, Future<WatchedProgress>> progressFuture = {};
  static final Map<String, Future<ShowsEpisode.Episode>> _episodeFuture = {};
  static ExtendedProfile? _profile;
  static String? token;

  static Future<void> auth(BuildContext context) async {
    if (await hasAccessToken()) {
      showDialog(
          context: context,
          builder: (context) => PlatformAlertDialog(
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
              token = accessToken;

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
        playbackProgressFuture = Future.value([]);
        nextUpFuture = Future.value([]);
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
          body: jsonEncode(object));
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

  static Future<void> stopWatching(MediaType mediaType, double progress, String traktId) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      print('Stop watching, progress: $progress');

      Map<String, Object> object;
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
      print(json.encode(object));
      var response = await post(url,
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
            'trakt-api-version': '2'
          },
          body: json.encode(object));

      if (response.statusCode == 201) {
        print(response.body);
        if (progress >= 80) {
          removePlaybackItem(json.decode(response.body)['id']);
        }
      }
      print(response.statusCode);
      print('Stop Watching: ${response.body}');
    }
  }

  static Future<void> addHistory(MediaType mediaType, String id) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/sync/history');

      Map<String, List<Map<String, Map<String, String>>>> object;

      switch (mediaType) {
        case MediaType.episode:
          {
            object = {
              'episodes': [
                {
                  'ids': {'trakt': id}
                }
              ]
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
      var response = await post(url,
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $token',
            'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
            'trakt-api-version': '2'
          },
          body: json.encode(object));

      await Future.delayed(Duration(seconds: 5));

      nextUpFuture = Future.value([]);
    }
  }

  static Future<List<PlaybackProgress>> playbackProgress({bool forceReload = false}) async {
    if ((await playbackProgressFuture).isEmpty || forceReload) {
      Future<List<PlaybackProgress>> progress = _playbackProgress();

      return playbackProgressFuture = progress;
    } else {
      return playbackProgressFuture;
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

      switch (response.statusCode) {
        case 204:
          {
            print('Removed playback: $id');
            (await playbackProgressFuture).forEach(
              (playbackProgress) async {
                if (playbackProgress.id == id) {
                  (await playbackProgressFuture).remove(playbackProgress);
                }
              },
            );
          }

        case 404:
          Exception('Failed to remove playback');
      }
    }
  }

  static Future<List<json_search.SearchResults>> search(List<SearchType> type, String query) async {
    return accessToken().then((token) async {
      var url = Uri.https('api.trakt.tv', '/search/${type.asNameMap().keys.join(',')}', {'query': query});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      List<json_search.SearchResults> entries = [];

      if (response.statusCode == 200) {
        var int = 0;
        for (var boop in jsonDecode(response.body)) {
          if (int == 8) {
            // break;
          }
          json_search.SearchResults entry = json_search.SearchResults.fromJson(boop);
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

  static Future<ExtendedMovie> extendedMovieFromId(String id) async {
    if (_extendedMovies.containsKey(id)) {
      return _extendedMovies[id]!;
    } else {
      final ExtendedMovie extendedShow = await _extendedMovieFromId(id);
      return _extendedMovies[id] = extendedShow;
    }
  }

  static Future<ExtendedMovie> _extendedMovieFromId(String id) async {
    if (await hasAccessToken()) {
      final String token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/movies/$id', {'extended': 'full'});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      switch (response.statusCode) {
        case 200:
          {
            return ExtendedMovie.fromJson(jsonDecode(response.body));
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
    token = null;
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
    if (await hasAccessToken()) {
      final token = await accessToken();
      var url = Uri.https('api.trakt.tv', '/users/me', {'extended': 'full'});
      var response = await get(url, headers: {
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
      });

      if (response.statusCode == 200) {
        final profile = profileFromJson(response.body);

        return profile;
      } else {
        return Future.error(UnknownStatusCode());
      }
    } else {
      return Future.error(MissingTraktAccessToken);
    }

    // return Future.error(Exception('Failed to get users/me'));
  }

  static Future<List<Watched>> nextUp({forceReload = false}) async {
    if ((await nextUpFuture).isEmpty || forceReload) {
      Future<List<Watched>> shows = _nextUp();

      return nextUpFuture = shows;
    } else {
      return nextUpFuture;
    }
  }

  static Future<List<Watched>> _nextUp() async {
    if (await hasAccessToken()) {
      var token = await accessToken();

      var url = Uri.https('api.trakt.tv', '/sync/watched/shows', {'extended': 'full'});
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        var watched = watchedFromJson(response.body);

        List<Watched> shows = [];

        for (var show in watched) {
          int episodes = 0;
          for (var element in show.seasons) {
            episodes += element.episodes.length;
          }
          if (show.show.airedEpisodes! > episodes) {
            shows.add(show);
          }
        }
        return shows;
      } else {
        return Future.error(Exception('Unable to obtain Next Up'));
      }
    } else {
      return Future.error(MissingTraktAccessToken());
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

  static Future<WatchedProgress> watchedProgress(String id, {refresh = false}) async {
    if (progressFuture.containsKey(id) && refresh == false) {
      return progressFuture[id]!;
    } else {
      return progressFuture[id] = _watchedProgress(id);
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

  static Future<ShowsEpisode.Episode> episode(id, season, episode) async {
    if (_episodeFuture.containsKey(id)) {
      return _episodeFuture[id]!;
    } else {
      return _episodeFuture[id] = _episode(id, season, episode);
    }
  }

  static Future<ShowsEpisode.Episode> _episode(id, season, episode) async {
    if (await hasAccessToken()) {
      final token = await accessToken();
      final url = Uri.https('api.trakt.tv', '/shows/$id/seasons/$season/episodes/$episode');
      final response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
        'trakt-api-key': (await rootBundle.loadString('keys')).split(',')[0],
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        return ShowsEpisode.episodeFromJson(response.body);
      } else {
        return Future.error(UnknownStatusCode());
      }
    } else {
      return Future.error(MissingTraktAccessToken());
    }
  }
}
