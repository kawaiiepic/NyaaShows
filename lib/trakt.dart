import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/main.dart';
import 'package:url_launcher/url_launcher.dart';

class TraktModel with ChangeNotifier {
  List<History> histories = [];

  void auth(
    BuildContext context,
  ) async {
    var dataManager = NyaaShows.dataManager;
    if (dataManager.traktToken != null) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Trakt Auth'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('@${dataManager.traktUsername}'),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: const Text('Disconnect Trakt')),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                      },
                      child: const Text("Cancel"))
                ],
              ));
    } else {
      final url = Uri.https('api.trakt.tv', '/oauth/device/code');
      var response = await http.post(url, body: {
        'client_id': await rootBundle.loadString('keys/trakt_client_id.key')
      });

      print(response.body);
      if (response.statusCode == 200 && context.mounted) {
        Map json = jsonDecode(response.body);

        String deviceCode = "";
        String userCode = "";
        String verificationUrl = "";
        int expiresIn = -1;
        int interval = 0;
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
          }
        });

        var timer = Timer.periodic(Duration(seconds: 10), (timer) async {
          var hasAccessToken = false;

          final url = Uri.https('api.trakt.tv', '/oauth/device/token');
          var response = await http.post(url, body: {
            'code': deviceCode,
            'client_id':
                await rootBundle.loadString('keys/trakt_client_id.key'),
            'client_secret': await rootBundle.loadString('keys/traktSecret')
          });

          if (response.statusCode == 200) {
            hasAccessToken = true;
            print("Acess Token!");
            print(response.body);
            timer.cancel();
          } else {
            print('Access Token failed, ${response.statusCode}');
          }
        });

        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Trakt Auth'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () async {
                            if (!await launchUrl(
                              Uri.parse(verificationUrl),
                              mode: LaunchMode.inAppBrowserView,
                              browserConfiguration:
                                  const BrowserConfiguration(showTitle: true),
                            )) {
                              throw Exception('Could not launch website');
                            }
                          },
                          child: const Text('Trakt Activate Page.')),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Code: '),
                            SelectableText(userCode)
                          ]),
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
  }
}

class History {
  final int id;
  final String watchedat;
  final String action;
  final String type;
  final Map<String, dynamic> episode;
  final Map<String, dynamic> show;

  const History(
      {required this.id,
      required this.watchedat,
      required this.action,
      required this.type,
      required this.episode,
      required this.show});

  factory History.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'watched_at': String watchedat,
        'action': String action,
        'type': String type,
        'episode': Map<String, dynamic> episode,
        'show': Map<String, dynamic> show,
      } =>
        History(
          id: id,
          action: action,
          watchedat: watchedat,
          type: type,
          episode: episode,
          show: show,
        ),
      _ => throw const FormatException('Failed to load History.'),
    };
  }
}
