import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/main.dart';
import 'package:path_provider/path_provider.dart';

import '../trakt/json/enum/media_type.dart';
import '../utils/common.dart';
import 'tvdb_json.dart';

class TVDB {
  static Map<String, Uint8List> imageData = {};

  static Future<String> accessToken() async {
    NyaaShows.log('TVDB accessToken involked.');
    // TODO: Save token to a local variable.
    final file = await Common.dirJson('tvdb');

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
            'apikey': (await rootBundle.loadString('keys')).split(',')[2],
          }));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        file.writeAsString(jsonEncode(json["data"]));
      }

      return Future<String>.value("");
    });
  }

  static Future<String> showIcon(String id) async {
    final url = Uri.https('api4.thetvdb.com', '/v4/series/$id/artworks');
    var response = await get(
      url,
      headers: {'accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer ${await accessToken()}'},
    );

    if (response.statusCode == 200) {
      var artwork = TvdbArtwork.fromJson(jsonDecode(response.body));
      return artwork.data.image;
    } else {
      return Future.error(Exception('Failed getting icon'));
    }
  }

  static Future<Uint8List> artwork(MediaType mediaType, String tvdb) async {
    if (imageData.containsKey(tvdb)) {
      return Future.value(imageData[tvdb]);
    }
    return imageData[tvdb] = await _artwork(tvdb);
  }

  static Future<Uint8List> _artwork(String tvdb) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/cache/tvdb/$tvdb.jpg');

    var exists = await file.exists();

    if (exists) {
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

      if (response.statusCode == 200) {
        var artwork = TvdbArtwork.fromJson(jsonDecode(response.body));
        var art = await get(Uri.parse(artwork.data.image));
        file.createSync(recursive: true);
        file.writeAsBytes(art.bodyBytes);

        return art.bodyBytes;
      } else {
        throw ('Artwork unknown statusCode');
      }
    }

    throw Future.error(Exception());
  }
}
