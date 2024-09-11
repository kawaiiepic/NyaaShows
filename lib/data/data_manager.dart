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
  Future<Map<String, Uint8List>> imageData = Future.value({});

  void auth() {}

  void loadArtworks() {
    DataManager.traktData.showData.then((value) {
      Map<String, Uint8List> images = {};
      for (var value in value) {
        retrieveArtwork(value.show.ids.tvdb).then((image) {
          print("Null");
          if (image != null) {
            print("Added");
            images[value.show.ids.tvdb.toString()] = image;
          }
        });
      }
      imageData = Future.value(images);
    });
  }

  Future<Uint8List?> retrieveArtwork(int id) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/cache/shows/$id.jpg');

    file.exists().then((value) {
      return file.readAsBytes();
      // return Future.value(image);
    }).onError((error, _) async {
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
        file.writeAsBytesSync(art.bodyBytes);
        return Future.value(art.bodyBytes);
      }

      throw Exception('No artwork found!');
    });

    return null;
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
      for (Map<String, dynamic> json in json) {
        Show show = Show.fromJson(json);
        // var show = showFromJson(json.toString());
        // print('Show: ${show.show.ids.tmdb}');
        shows.add(show);
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

  // Future<List<History>> fetchHistory() async {
  //   var url = Uri.https('api.trakt.tv', '/sync/watched/shows');
  //   var response = await http.get(url, headers: {
  //     'Content-type': 'application/json',
  //     'Authorization': 'Bearer ${retriveToken()}',
  //     'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
  //     'trakt-api-version': '2'
  //   });

  //   if (response.statusCode == 200) {
  //     List<dynamic> json = jsonDecode(response.body);
  //     final file = await NyaaShows.dataManager.dataFile('history');
  //     file.writeAsString(response.body);
  //     historyData.clear();
  //     for (Map<String, dynamic> json in json) {
  //       var history = History.fromJson(json);

  //       historyData.add(history);
  //       developer.log(history.episode.toString());
  //     }
  //     notifyListeners();
  //   }
  //   return Future.value(historyData);
  // }
}
