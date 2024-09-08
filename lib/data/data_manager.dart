import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/trakt.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DataManager {
  var traktToken = 0;
  var traktUsername = "mia";

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();

    return directory.path;
  }

  Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name.json');
  }

  void checkData() {
    if (true) {
      //TODO: Check the last time we've updated Trakt data. (1 day perferable)
    }
  }

  Future<File> writeHistory(List<dynamic> history) async {
    final file = await _localFile('history');

    // Write the file

    developer.log(file.absolute.path);

    return file.writeAsString(history.toString());
  }

  // Future<int> readCounter() async {
  //   try {
  //     final file = await _localFile;

  //     // Read the file
  //     final contents = await file.readAsString();

  //     return int.parse(contents);
  //   } catch (e) {
  //     // If encountering an error, return 0
  //     return 0;
  //   }
  // }
}

class TraktData {
  List<History> historyData = [];

  

  Future<List<History>> fetchHistory() async {
    var url = Uri.https('api.trakt.tv', '/users/miathetrain/history/');
    var response = await http.get(url, headers: {
      'Content-type': 'application/json',
      'trakt-api-key': await rootBundle.loadString('keys/trakt.key'),
      'trakt-api-version': '2'
    });

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      NyaaShows.dataManager.writeHistory(json);
      historyData.clear();
      for (Map<String, dynamic> json in json) {
        var history = History.fromJson(json);

        historyData.add(history);
        // notifyListeners();
      }
    }
    return Future.value(historyData);
  }
}
