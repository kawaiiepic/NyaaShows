// Import the test package and Counter class
import 'dart:async';
import 'dart:convert';

import 'package:nyaashows/main.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Real-Debrid testing', () async {
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

      print(
          'Connect the app with real-debrid at: $verificationUrl with code: [$userCode]');
      var timer = Timer.periodic(const Duration(seconds: 10), (timer) async {});
      var hasAccessToken = false;

      final url = Uri.https('api.real-debrid.com', '/oauth/v2/token',
          {'client_id': 'X245A4XAIBGVM', 'code': deviceCode});
      var post = await http.post(url);

      if (post.statusCode == 200) {
        hasAccessToken = true;
        Map json = jsonDecode(post.body);
        String clientId = json[0];
        String clientSecret = json[1];

        final file = await NyaaShows.dataManager.dataFile('real-debrid');

        Map<String, dynamic> data = {
          'client_id': clientId,
          'client_second': clientSecret
        };

        file.writeAsString(jsonEncode(data));

        timer.cancel();
      } else {
        print('Still waiting for access code');
      }
    }
  });
}
