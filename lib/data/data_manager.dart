import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/data/trakt/profile.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/episodes_page.dart';
import 'package:nyaashows/pages/player.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/data/tvdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DataManager {
  static TraktData traktData = TraktData();
  static TVDB tvdbData = TVDB();

  Future<File> dataFile(String name) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$name.json');
  }
}

class TVDB with ChangeNotifier {
  Future<Map<int, Uint8List>> imageData = Future.value({});

  void auth() {}

  Future<Uint8List> retrieveArtwork(int id) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/cache/shows/$id.jpg');

    imageData.then((value) {
      if (value.containsKey(id)) {
        return value[id];
      }
    });

    if (file.existsSync()) {
      imageData.then((value) {
        value[id] = file.readAsBytesSync();
      });
      return file.readAsBytesSync();
    } else {
      final url = Uri.https('api4.thetvdb.com', '/v4/series/$id/artworks');
      var response = await http.get(
        url,
        headers: {'accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer ${await retrieveToken()}'},
      );

      if (response.statusCode == 200) {
        var artwork = TvdbArtwork.fromJson(jsonDecode(response.body));
        var art = await get(Uri.parse(artwork.data.image));
        file.createSync(recursive: true);

        imageData.then((value) {
          value[id] = file.readAsBytesSync();
        });

        file.writeAsBytesSync(art.bodyBytes);
        return Future.value(art.bodyBytes);
      }

      throw Exception('No artwork found!');
    }
  }

  Future<String> retrieveToken() async {
    // TODO: Save token to a local variable.
    final file = await NyaaShows.dataManager.dataFile('tvdb');

    return file.exists().then((_) async {
      //TODO: Check if tvdb token is expired!
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      Future<String> val = Future<String>.value(json["token"]);
      return val;
    }).onError((_, except) async {
      final url = Uri.https('api4.thetvdb.com', '/v4/login');

      var response = await http.post(url,
          headers: {'accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({
            'apikey': await rootBundle.loadString('keys/tvdb.key'),
          }));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        final file = await NyaaShows.dataManager.dataFile('tvdb');
        file.writeAsString(jsonEncode(json["data"]));
      }

      return Future<String>.value("");
    });
  }
}

class TraktData {
  Future<List<Show>> showData = Future.value([]);

  void storeToken(String accessToken, String tokenType, int expiresIn, String refreshToken, String scope, int createdAt) async {
    final file = await NyaaShows.dataManager.dataFile('user');

    Map<String, dynamic> data = {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'scope': scope,
      'created_at': createdAt
    };

    file.writeAsString(jsonEncode(data));
  }

  Future<void> revolkToken() async {
    final file = await NyaaShows.dataManager.dataFile('user');
    file.exists().then((value) => file.delete());
  }

  Future<String> retriveToken() async {
    final file = await NyaaShows.dataManager.dataFile('user');

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

  setShows() async {
    showData = _retrieveShows();
  }

  Future<List<Show>> _retrieveShows() async {
    final file = await NyaaShows.dataManager.dataFile('shows');

    return file.exists().then((value) async {
      List<dynamic> json = jsonDecode(await file.readAsString());
      List<Show> shows = [];
      int count = 0;
      for (Map<String, dynamic> json in json) {
        Show show = Show.fromJson(json);
        if (count >= 10) {
          continue;
        } else {
          shows.add(show);
        }

        count++;
        // showData.add(show);
      }

      showData = Future.value(shows);

      return await showData;
    }).onError((error, ex) {
      return fetchShows();
    });
  }

  Future<List<Show>> fetchShows() async {
    retriveToken().then((value) async {
      developer.log('Fetching Shows.');
      var url = Uri.https('api.trakt.tv', '/sync/watched/shows');
      var response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        List<dynamic> json = jsonDecode(response.body);

        final file = await NyaaShows.dataManager.dataFile('shows');
        file.writeAsString(jsonEncode(json));
        await setShows();
        return showData;
      }
    });
    return Future.value(showData);
  }

  Future<TraktProgress?> showProgress(id) async {
    TraktProgress? progress;
    await retriveToken().then((value) async {
      var url = Uri.https('api.trakt.tv', '/shows/$id/progress/watched');
      var response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        progress = traktProgressFromJson(response.body);
      }
    });
    return progress;
  }
}

class RealDebridAPI {
  late Timer timer;
  late String userCode;

  Future<void> login(BuildContext context) async {
    final url = Uri.https('api.real-debrid.com', '/oauth/v2/device/code', {'client_id': 'X245A4XAIBGVM', 'new_credentials': 'yes'});
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      String deviceCode = "";
      String userCode = "";
      String verificationUrl = "";
      String directVerificationUrl = "";
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
          case 'direct_verification_url':
            directVerificationUrl = value;
        }
      });

      this.userCode = userCode;
      var hasAccessToken = false;

      NyaaShows.log('Connect the app with real-debrid at: $verificationUrl with code: [$userCode]');
      timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final url = Uri.https('api.real-debrid.com', '/oauth/v2/device/credentials', {'client_id': 'X245A4XAIBGVM', 'code': deviceCode});
        var get = await http.get(url);

        if (get.statusCode == 200) {
          Map json = jsonDecode(get.body);

          String clientId = "";
          String clientSecret = "";

          json.forEach((key, value) {
            switch (key) {
              case 'client_id':
                clientId = value;
                break;
              case 'client_secret':
                clientSecret = value;
                break;
            }
          });

          final url = Uri.https('api.real-debrid.com', '/oauth/v2/token');
          var post = await http.post(url,
              body: {'client_id': clientId, 'client_secret': clientSecret, 'code': deviceCode, 'grant_type': 'http://oauth.net/grant_type/device/1.0'});

          if (post.statusCode == 200) {
            hasAccessToken = true;

            String accessToken = "";
            int expiresIn = 0;
            String tokenType = "";
            String refreshToken = "";

            Map json = jsonDecode(post.body);

            json.forEach((key, value) {
              switch (key) {
                case 'access_token':
                  accessToken = value;
                  break;
                case 'expires_in':
                  expiresIn = value;
                  break;
                case 'token_type':
                  tokenType = value;
                  break;
                case 'refresh_token':
                  refreshToken = value;
                  break;
              }
            });

            final file = await NyaaShows.dataManager.dataFile('real-debrid');

            Map<String, dynamic> data = {
              'access_token': accessToken,
              'expires_in': expiresIn.toString(),
              'token_type': tokenType,
              'refresh_token': refreshToken
            };

            file.writeAsString(jsonEncode(data));

            if (context.mounted) {
              Navigator.pop(context);
            }
            timer.cancel();
          }
        } else {
          NyaaShows.log('Still waiting for access code');
        }
      });
    }
  }

  void loginPopup(BuildContext context) async {
    await accessToken().then((value) async {
      if (context.mounted) {
        if (value != null) {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Trakt Auth'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Username'),
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text('Revolk Real-Debrid')),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                          },
                          child: const Text("Cancel"))
                    ],
                  )).onError((_, except) {});
        } else {
          await login(context);
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Auth'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () async {
                              if (!await launchUrl(
                                Uri.parse('https://real-debrid.com/device'),
                                mode: LaunchMode.platformDefault,
                                browserConfiguration: const BrowserConfiguration(showTitle: true),
                              )) {
                                throw Exception('Could not launch website');
                              }
                            },
                            child: const Text('Activate Page.')),
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
      }
    }).onError((_, except) {});
  }

  Future<String?> accessToken() async {
    final file = await NyaaShows.dataManager.dataFile('real-debrid');
    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      return json['access_token'];
    }

    return null;
  }

  Future<List?> availableHosts() async {
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/availableHosts');
    var response = await http.get(url, headers: {'Authorization': 'Bearer W2IZWZOKMCTEKZO36JXALP2UXYNQ4QDFZR2YMALEIGYSV2IBD32A'});
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json;
    }
    return null;
  }

  Future<Map<dynamic, dynamic>?> addMagnet({required String magnet, required BuildContext context, required TorrentEpisode torrentEpisode}) async {
    await accessToken().then(
      (value) async {
        if (value != null) {
          final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/addMagnet');
          var response = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'magnet': magnet});

          if (response.statusCode == 201) {
            developer.log('addMagnet');
            Map<String, dynamic> json = jsonDecode(response.body);
            var id = json["id"];
            checkMagnet(id, context, torrentEpisode: torrentEpisode);
          } else if (response.statusCode == 401) {
            developer.log('Access Token expired!');
          }
        }
      },
    );
    return null;
  }

  Future<void> checkMagnet(String id, BuildContext context, {required TorrentEpisode torrentEpisode}) async {
    if (context.mounted) {
      await accessToken().then((value) async {
        final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
        var get = await http.get(url, headers: {'Authorization': 'Bearer $value'});
        Map<String, dynamic> decode = jsonDecode(get.body);

        switch (decode['status']) {
          case 'waiting_files_selection':
            await selectFiles(id, decode, context, torrentEpisode: torrentEpisode);
            print('awaiting selection');
            break;
          case 'downloaded':
            var link = (decode['links'] as List<dynamic>).first;
            unrestrickLink(link: link, context: context, torrentEpisode: torrentEpisode);
            print('Downloaded!!!');
            break;
          case 'queued':
            timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
              final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
              var get = await http.get(url, headers: {'Authorization': 'Bearer $value'});
              Map<String, dynamic> status = jsonDecode(get.body);
              print('Still waiitng');
              NyaaShows.log(status.toString());
              if (status['status'] == 'downloaded') {
                print("Finished Downloading");
                var link = (decode['links'] as List<dynamic>).first;
                unrestrickLink(link: link, context: context, torrentEpisode: torrentEpisode);
                timer.cancel();
              }
            });
        }

        // print(decode);
      });
    }
  }

  Future<void> checkTorrents() async {
    accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents');
      var get = await http.get(url, headers: {'Authorization': 'Bearer $value'});
      print(get.statusCode);
      print(get.body);
    });
  }

  Future<void> selectFiles(String id, Map<String, dynamic> json, BuildContext context, {required TorrentEpisode torrentEpisode}) async {
    await accessToken().then((value) async {
      List<dynamic> files = json["files"];
      List<int> ids = [];

      // String season = progress.nextEpisode!.season.toString();
      // String episode = progress.nextEpisode!.number.toString();
      // String episodeName = progress.nextEpisode!.title;

      for (var file in files) {
        var id0 = file["id"];
        String path = file["path"];
        var bytes = file["bytes"];
        var selected = file["selected"];
        if (path.contains(RegExp(r'^.*\.(mp4|mkv|wmv|avi)$'))) {
          //TODO: Check if it's the right episode.
          var seaNum = torrentEpisode.seasonId;
          var epNum = torrentEpisode.episodeId;
          NyaaShows.log('Trying RegExp: $path');
          if (path.contains(RegExp('s([0]$seaNum|$seaNum)', caseSensitive: false))) {
            NyaaShows.log('Season entry got');
            if (path.contains(RegExp('e([0]$seaNum|$seaNum)', caseSensitive: false))) {
              NyaaShows.log('Episode entry got');
              ids.add(id0);
            }
          }
          // if (path.contains(torrentEpisode.seasonName) && path.contains(torrentEpisode.episodeName)) {
          //   ids.add(id0);
          //   print(path);
          // }
        }
      }

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'files': ids.join(',')});
      print(ids.join(','));
      print(post.body);
      if (post.statusCode == 204) {
        // checkTorrents();
        checkMagnet(id, context, torrentEpisode: torrentEpisode);
      }
    });
  }

  Future<Map<String, dynamic>?> unrestrickLink({required String link, required BuildContext context, required TorrentEpisode torrentEpisode}) async {
    accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'link': link});

      if (post.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(post.body);
        print(json);
        String video = json["download"];

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPlayer(
                      media: Media(video),
                      torrentEpisode: torrentEpisode,
                    )));
        return json;
      }
    });

    return null;
  }
}
