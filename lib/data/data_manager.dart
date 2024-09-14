import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/trakt.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/tvdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DataManager {
  static TraktData traktData = TraktData();
  static TVDB tvdbData = TVDB();

  Future<File> dataFile(String name) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$name.json');
  }

  void checkData() {
    if (true) {
      //TODO: Check the last time we've updated Trakt data. (1 day perferable).
      DataManager.traktData.userData();
      DataManager.tvdbData.retrieveToken();
    }
  }
}

class TVDB with ChangeNotifier {
  final Future<String> _token = Future.value("");
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
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await retrieveToken()}'
        },
      );

      print(response.statusCode);

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
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json'
          },
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
  String username = "";
  String displayName = "";
  bool vip = false;
  String profilePicture = "";

  // List<History> historyData = [];
  Future<List<Show>> showData = Future.value([]);

  void storeToken(String accessToken, String tokenType, int expiresIn,
      String refreshToken, String scope, int createdAt) async {
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

  void userData() async {
    retriveToken().then((value) async {
      var url = Uri.https('api.trakt.tv', '/users/me', {'extended': 'full'});
      var response = await http.get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        username = json["username"];
        displayName = json["name"];
        vip = json["vip"];
        profilePicture = json["images"]["avatar"]["full"];
      }
    });
  }

  setShows() async {
    showData = _retrieveShows();
  }

  Future<List<Show>> _retrieveShows() async {
    final file = await NyaaShows.dataManager.dataFile('shows');

    return file.exists().then((value) async {
      // developer.debugger(message: 'File exists');
      List<dynamic> json = jsonDecode(await file.readAsString());
      List<Show> shows = [];

      // showData.clear();
      int count = 0;
      for (Map<String, dynamic> json in json) {
        Show show = Show.fromJson(json);
        // var show = showFromJson(json.toString());
        // print('Show: ${show.show.ids.tmdb}');
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
      // print(ex.toString());
      // return Future.value(List.empty());
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
}

class RealDebridAPI {
  late Timer timer;
  late String userCode;
  Future<bool?> login(BuildContext context) async {
    final url = Uri.https('api.real-debrid.com', '/oauth/v2/device/code',
        {'client_id': 'X245A4XAIBGVM', 'new_credentials': 'yes'});
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

      print(
          'Connect the app with real-debrid at: $verificationUrl with code: [$userCode]');
      timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final url = Uri.https(
            'api.real-debrid.com',
            '/oauth/v2/device/credentials',
            {'client_id': 'X245A4XAIBGVM', 'code': deviceCode});
        var get = await http.get(url);

        if (get.statusCode == 200) {
          print('clientId and clientSecret');
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
          var post = await http.post(url, body: {
            'client_id': clientId,
            'client_secret': clientSecret,
            'code': deviceCode,
            'grant_type': 'http://oauth.net/grant_type/device/1.0'
          });

          print(post.statusCode);
          print(post.body);

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
          print('Still waiting for access code');
        }
      });
    }
  }

  void loginPopup(BuildContext context) async {
    await secret().then((value) async {
      if (context.mounted) {
        if (value != null) {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Trakt Auth'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Username'),
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
                                browserConfiguration:
                                    const BrowserConfiguration(showTitle: true),
                              )) {
                                throw Exception('Could not launch website');
                              }
                            },
                            child: const Text('Activate Page.')),
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
      }
    }).onError((_, except) {});
  }

  Future<Map<String, dynamic>?> secret() async {
    final file = await NyaaShows.dataManager.dataFile('real-debrid');

    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      return json;
    } else {
      return null;
    }
  }
}
