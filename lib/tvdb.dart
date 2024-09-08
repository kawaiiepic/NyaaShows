import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

String token = "";

void get_token() async {
  var url = Uri.https('api4.thetvdb.com/v4', '/login');
  var response = await http.get(url, headers: {
    'apikey': await rootBundle.loadString('keys/tvdb.key')
  });
}
