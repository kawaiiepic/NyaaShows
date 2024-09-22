import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/data/tvdb.dart';
import 'package:nyaashows/main.dart';
import 'package:path_provider/path_provider.dart';

class TVDB {
  Map<int, Uint8List> imageData = {};

  Future<String> accessToken() async {
    // TODO: Save token to a local variable.
    final file = await NyaaShows.dataManager.dataFile('tvdb');

    return file.exists().then((_) async {
      //TODO: Check if tvdb token is expired!
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      Future<String> val = Future<String>.value(json["token"]);
      return val;
    }).onError((_, except) async {
      final url = Uri.https('api4.thetvdb.com', '/v4/login');

      var response = await post(url,
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

  Future<String?> showIcon(int id) async {
    final url = Uri.https('api4.thetvdb.com', '/v4/series/$id/artworks');
    var response = await get(
      url,
      headers: {'accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer ${await accessToken()}'},
    );

    if (response.statusCode == 200) {
      var artwork = TvdbArtwork.fromJson(jsonDecode(response.body));
      return artwork.data.image;
    } else {
      return null;
    }
  }

  Future<Uint8List?> artwork(int tvdb) async {
    if (imageData.containsKey(tvdb)) {
      return Future.value(imageData[tvdb]);
    }

    return _artwork(tvdb);
  }

  Future<Uint8List?> _artwork(int tvdb) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/cache/shows/$tvdb.jpg');

    return await file.exists().then((exists) async {
      if (exists == true) {
        return file.readAsBytes().then((Uint8List bytes) {
          imageData[tvdb] = bytes;
          return bytes;
        });
      } else {
        final url = Uri.https('api4.thetvdb.com', '/v4/series/$tvdb/artworks');
        var response = await get(
          url,
          headers: {'accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer ${await accessToken()}'},
        );

        print(response.statusCode);
        if (response.statusCode == 200) {
          var artwork = TvdbArtwork.fromJson(jsonDecode(response.body));
          var art = await get(Uri.parse(artwork.data.image));
          file.createSync(recursive: true);
          file.writeAsBytes(art.bodyBytes);

          return file.readAsBytes().then((bytes) {
            imageData[tvdb] = bytes;
            return bytes;
          });
        }
      }
    });
  }
}
