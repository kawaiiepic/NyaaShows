import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyaashows/utils/exceptions.dart';

import 'json/images.dart';

class TMDB {
  static Future<String> poster(String id) async {
    final url = Uri.https('api.themoviedb.org', '/3/tv/$id/images', {'language': 'en'});
    var response = await get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4OTA3MDBmYWY5ZDZmYzMwMWMxM2Y0MWUzMTIxZDU1YSIsIm5iZiI6MTcyOTg1OTY4OC4yNjU2MTYsInN1YiI6IjVmNTIwM2YzYjIzNGI5MDAzNzE4YjMzNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.k3JK9-Uv_Wd5Fk9zeEyUagSDxEWWvpWqmw9PU5Lulho'
      },
    );

    if (response.statusCode == 200) {
      var images = Images.fromJson(jsonDecode(response.body));
      if (images.posters != null && images.posters!.isNotEmpty) {
        return 'https://image.tmdb.org/t/p/original${images.posters![0].filePath!}';
      } else {
        return Future.error(TMDBMissingPoster());
      }
    } else {
      return Future.error(UnknownStatusCode());
    }
  }
}
