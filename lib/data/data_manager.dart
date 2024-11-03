import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/main.dart';
import 'package:path_provider/path_provider.dart';

class DataManager {
  static TraktData traktData = TraktData();

  Future<File> dataFile(String name) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$name.json');
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

  // setShows() async {
  //   showData = _retrieveShows();
  // }

  // Future<List<Show>> _retrieveShows() async {
  //   final file = await NyaaShows.dataManager.dataFile('shows');

  //   return file.exists().then((value) async {
  //     List<dynamic> json = jsonDecode(await file.readAsString());
  //     List<Show> shows = [];
  //     int count = 0;
  //     for (Map<String, dynamic> json in json) {
  //       Show show = Show.fromJson(json);
  //       if (count >= 10) {
  //         continue;
  //       } else {
  //         shows.add(show);
  //       }

  //       count++;
  //       // showData.add(show);
  //     }

  //     showData = Future.value(shows);

  //     return await showData;
  //   }).onError((error, ex) {
  //     return fetchShows();
  //   });
  // }

  // Future<List<Show>> fetchShows() async {
  //   retriveToken().then((value) async {
  //     developer.log('Fetching Shows.');
  //     var url = Uri.https('api.trakt.tv', '/sync/watched/shows');
  //     var response = await http.get(url, headers: {
  //       'Content-type': 'application/json',
  //       'Authorization': 'Bearer $value',
  //       'trakt-api-key': await rootBundle.loadString('keys/trakt_client.key'),
  //       'trakt-api-version': '2'
  //     });

  //     if (response.statusCode == 200) {
  //       List<dynamic> json = jsonDecode(response.body);

  //       final file = await NyaaShows.dataManager.dataFile('shows');
  //       file.writeAsString(jsonEncode(json));
  //       await setShows();
  //       return showData;
  //     }
  //   });
  //   return Future.value(showData);
  // }

  Future<TraktProgress?> showProgress(id) async {
    TraktProgress? progress;
    await retriveToken().then((value) async {
      var url = Uri.https('api.trakt.tv', '/shows/$id/progress/watched');
      var response = await get(url, headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $value',
        'trakt-api-key': await rootBundle.loadString('keys/trakt_client.key'),
        'trakt-api-version': '2'
      });

      if (response.statusCode == 200) {
        progress = traktProgressFromJson(response.body);
        print(progress!.completed);
      }
    });
    return progress;
  }
}
