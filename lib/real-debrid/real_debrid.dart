import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/common.dart';

class RealDebrid {
  static late Timer timer;
  static String? userCode;
  static String? token;

  static Future<void> authentication(BuildContext context) async {
    final response = await get(Uri.https('api.real-debrid.com', '/oauth/v2/device/code', {'client_id': 'X245A4XAIBGVM', 'new_credentials': 'yes'}));
    if (response.statusCode == 200) {
      final Map json = jsonDecode(response.body);

      String deviceCode = json['device_code'];
      String userCode = json['user_code'];
      String verificationUrl = json['verification_url'];
      int expiresIn = json['expires_in'];
      int interval = json['interval'];

      RealDebrid.userCode = userCode;

      NyaaShows.log('Connect the app with real-debrid at: $verificationUrl with code: [$userCode]');

      timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final response = await get(Uri.https('api.real-debrid.com', '/oauth/v2/device/credentials', {'client_id': 'X245A4XAIBGVM', 'code': deviceCode}));

        if (response.statusCode == 200) {
          Map json = jsonDecode(response.body);

          String clientId = json['client_id'];
          String clientSecret = json['client_secret'];

          final token = await post(Uri.https('api.real-debrid.com', '/oauth/v2/token'),
              body: {'client_id': clientId, 'client_secret': clientSecret, 'code': deviceCode, 'grant_type': 'http://oauth.net/grant_type/device/1.0'});

          Map tokenJson = jsonDecode(token.body);
          if (token.statusCode == 200) {
            String accessToken = tokenJson['access_token'];
            int expiresIn = tokenJson['expires_in'];
            String tokenType = tokenJson['token_type'];
            String refreshToken = tokenJson['refresh_token'];

            final file = await Common.dirJson('rd-token');

            Map<String, dynamic> data = {
              'client_id': clientId,
              'client_secret': clientSecret,
              'access_token': accessToken,
              'expires_in': expiresIn.toString(),
              'token_type': tokenType,
              'refresh_token': refreshToken
            };

            file.writeAsString(jsonEncode(data));

            Navigator.pop(context);
            timer.cancel();
          }
        }
      });
    }
  }

  static Future<Future> login(BuildContext context) async {
    if (await RealDebrid.hasAccessToken()) {
      final token = await RealDebrid.accessToken();

      return showDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
          title: Text('Real-Debrid Auth'),
          content: Column(
            children: [
              const Text('@Username'),
              PlatformTextButton(
                child: const Text('Revolk Real-Debrid'),
              )
            ],
          ),
          actions: [
            PlatformTextButton(
              child: const Text('Cancel'),
            )
          ],
        ),
      );
    } else {
      await RealDebrid.authentication(context);
      return showDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
          title: const Text('Real-Debrid Authentication'),
          content: Column(
            children: [
              PlatformTextButton(
                onPressed: () {
                  launchUrl(Uri.parse('https://real-debrid.com/device'));
                },
                child: const Text('Activate Page'),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Code: '), SelectableText(RealDebrid.userCode!)]),
            ],
          ),
          actions: [
            PlatformTextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
                if (RealDebrid.timer.isActive) {
                  RealDebrid.timer.cancel();
                }
              },
              child: const Text('Cancel'),
            )
          ],
        ),
      );
    }
  }

  static Future<void> expiredPremium() async {
    return showDialog(
      context: NyaaShows.navigatorKey.currentContext!,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Real-Debrid Missing Premium'),
        content: Column(
          children: [
            Text('This account is missing Premium')
          ],
        ),
        actions: [
          PlatformTextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
              if (RealDebrid.timer.isActive) {
                RealDebrid.timer.cancel();
              }
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  static Future<void> refreshToken() async {
    if (await hasAccessToken()) {
      final file = await Common.dirJson('rd-token');
      Map<String, dynamic> json = jsonDecode(await file.readAsString());

      final token = await post(Uri.https('api.real-debrid.com', '/oauth/v2/token'), body: {
        'client_id': json['client_id'],
        'client_secret': json['client_secret'],
        'code': json['refresh_token'],
        'grant_type': 'http://oauth.net/grant_type/device/1.0'
      });

      Map tokenJson = jsonDecode(token.body);
      if (token.statusCode == 200) {
        String accessToken = tokenJson['access_token'];
        int expiresIn = tokenJson['expires_in'];
        String tokenType = tokenJson['token_type'];
        String refreshToken = tokenJson['refresh_token'];

        Map<String, dynamic> data = {
          'client_id': json['client_id'],
          'client_secret': json['client_secret'],
          'access_token': accessToken,
          'expires_in': expiresIn.toString(),
          'token_type': tokenType,
          'refresh_token': refreshToken
        };

        file.writeAsString(jsonEncode(data));

        RealDebrid.token = accessToken;
      }
    }
  }

  static Future<String> accessToken() async {
    if (token != null) {
      return Future.value(RealDebrid.token);
    } else {
      return _accessToken();
    }
  }

  static Future<String> _accessToken() async {
    final file = await Common.dirJson('rd-token');
    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());

      token = json['access_token'];
      return Future.value(token);
    }

    return Future.error(Exception('Missing rd-token file'));
  }

  static Future<bool> hasAccessToken() async {
    final file = await Common.dirJson('rd-token');
    if (await file.exists()) {
      return true;
    }
    return false;
  }

  void loginPopup(BuildContext context) async {
    await accessToken().then((value) async {
      if (context.mounted) {
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
      }
    }).onError((_, except) {});
  }
}
