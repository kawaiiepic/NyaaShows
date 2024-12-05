import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:nyaashows/trakt/json/enum/media_type.dart';
import 'package:nyaashows/utils/exceptions.dart';
import 'package:path_provider/path_provider.dart';

import 'json/images.dart';

class TMDB {
  static Map<String, Future<Uint8List>> imageData = {};

  static Future<Uint8List> poster(MediaType mediaType, String id) {
    if (imageData.containsKey(id)) {
      return imageData[id]!;
    } else {
      return imageData[id] = _poster(mediaType, id);
    }
  }

  static Future<String> posterUrl(MediaType mediaType, String tmdb) async {
    Uri url = Uri();
    if (mediaType == MediaType.show) {
      url = Uri.https('api.themoviedb.org', '/3/tv/$tmdb/images', {'language': 'en'});
    } else if (mediaType == MediaType.movie) {
      url = Uri.https('api.themoviedb.org', '/3/movie/$tmdb/images', {'language': 'en'});
    }

    var response = await get(
      url,
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${await accessToken()}'},
    );

    if (response.statusCode == 200) {
      var images = Images.fromJson(jsonDecode(response.body));

      if (images.posters != null && images.posters!.isNotEmpty) {
        return 'https://image.tmdb.org/t/p/original${images.posters![0].filePath!}';
      } else {
        throw TMDBMissingPoster();
      }
    } else {
      throw Future.error(UnknownStatusCode());
    }
  }

  static Future<String> accessToken() async {
    print('TMDB accessToken');
    return Future.value((await rootBundle.loadString('keys')).split(',')[3]);
  }

  static Future<Uint8List> _poster(MediaType mediaType, String tmdb) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/cache/tmdb/$tmdb.jpg');

    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      return imageData[tmdb] = Future.value(bytes);
    } else {
      Uri url = Uri();
      if (mediaType == MediaType.show) {
        url = Uri.https('api.themoviedb.org', '/3/tv/$tmdb/images', {'language': 'en'});
      } else if (mediaType == MediaType.movie) {
        url = Uri.https('api.themoviedb.org', '/3/movie/$tmdb/images', {'language': 'en'});
      }

      var response = await get(
        url,
        headers: {'accept': 'application/json', 'Authorization': 'Bearer ${await accessToken()}'},
      );

      if (response.statusCode == 200) {
        var images = Images.fromJson(jsonDecode(response.body));

        if (images.posters != null && images.posters!.isNotEmpty) {
          print(images.posters?[0].filePath);
          var art = await get(Uri.parse('https://image.tmdb.org/t/p/original${images.posters![0].filePath!}'));
          print(images.posters![0].filePath!);
          file.createSync(recursive: true);
          file.writeAsBytes(art.bodyBytes);

          return art.bodyBytes;
        } else {
          return Future.error(Exception('Missing Poster'));
          throw TMDBMissingPoster();
        }
      } else {
        return Future.error(UnknownStatusCode());
      }
    }
  }
}
