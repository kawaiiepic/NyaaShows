import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/main.dart';
import 'package:url_launcher/url_launcher.dart';

class RealDebrid {
  late Timer timer;
  late String userCode;

  Future<void> login(BuildContext context) async {
    final url = Uri.https('api.real-debrid.com', '/oauth/v2/device/code', {'client_id': 'X245A4XAIBGVM', 'new_credentials': 'yes'});
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

      NyaaShows.log('Connect the app with real-debrid at: $verificationUrl with code: [$userCode]');
      timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final url = Uri.https('api.real-debrid.com', '/oauth/v2/device/credentials', {'client_id': 'X245A4XAIBGVM', 'code': deviceCode});
        var get = await http.get(url);

        if (get.statusCode == 200) {
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
          var post = await http.post(url,
              body: {'client_id': clientId, 'client_secret': clientSecret, 'code': deviceCode, 'grant_type': 'http://oauth.net/grant_type/device/1.0'});

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
          NyaaShows.log('Still waiting for access code');
        }
      });
    }
  }

  void loginPopup(BuildContext context) async {
    await accessToken().then((value) async {
      if (context.mounted) {
        if (value != null) {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Trakt Auth'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Username'),
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
                    title: const Text('real-debrid authentication'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () async {
                              if (!await launchUrl(
                                Uri.parse('https://real-debrid.com/device'),
                                mode: LaunchMode.platformDefault,
                                browserConfiguration: const BrowserConfiguration(showTitle: true),
                              )) {
                                throw Exception('Could not launch website');
                              }
                            },
                            child: const Text('Activate Page.')),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Code: '), SelectableText(userCode)]),
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

  Future<String?> accessToken() async {
    final file = await NyaaShows.dataManager.dataFile('real-debrid');
    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      return json['access_token'];
    }

    return null;
  }

  void revolkToken() async {
    final file = await NyaaShows.dataManager.dataFile('real-debrid');
    file.deleteSync();
  }

  Future<List?> availableHosts() async {
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/availableHosts');
    var response = await http.get(url, headers: {'Authorization': 'Bearer W2IZWZOKMCTEKZO36JXALP2UXYNQ4QDFZR2YMALEIGYSV2IBD32A'});
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json;
    }
    return null;
  }

  Future<void> checkTorrents() async {
    accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents');
      var get = await http.get(url, headers: {'Authorization': 'Bearer $value'});
      print(get.statusCode);
      print(get.body);
    });
  }
}
