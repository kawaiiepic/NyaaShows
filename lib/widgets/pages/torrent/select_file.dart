import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/real-debrid/json/torrent_info.dart';
import 'package:nyaashows/utils/exceptions.dart';

import '../../../real-debrid/real_debrid.dart';
import '../../../torrents/helper.dart';
import '../player/show_player.dart';

class SelectFile extends StatefulWidget {
  const SelectFile({super.key, required this.id, required this.files, required this.torrentEpisode});

  final String id;
  final List<FileElement> files;
  final TorrentEpisode torrentEpisode;

  @override
  State<StatefulWidget> createState() => SelectFileState();
}

class SelectFileState extends State<SelectFile> {
  late Timer timer;
  double progress = 0.0;
  late var _alertSetState;
  int currentFileId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Select File")),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: super.widget.files.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.all(8),
                child: Center(
                    child: TextButton(
                        onPressed: () async {
                          await _selectFiles(super.widget.id, super.widget.torrentEpisode, overrideId: super.widget.files[index].id);
                          print(super.widget.files[index].id);
                          unrestrickLink(link: await _getLink(super.widget.id), torrentEpisode: super.widget.torrentEpisode);
                        },
                        child: Text(super.widget.files[index].path))),
              );
            }));
  }

  Future<String> _getLink(String id) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      switch (response.statusCode) {
        case 200:
          {
            final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);
            log(torrentInfo.status);
            log(torrentInfo.progress.toString());

            switch (torrentInfo.status) {
              case 'queued':
                {
                  print('Still downloading...');
                  var link = "";
                  await Future.doWhile(() async {
                    var newResponse = await http.get(url, headers: {'Authorization': 'Bearer $token'});
                    final TorrentInfo responseInfo = torrentInfoFromJson(newResponse.body);
                    switch (newResponse.statusCode) {
                      case 200:
                        {
                          switch (responseInfo.status) {
                            case 'downloading':
                              {
                                print(responseInfo.progress);
                              }
                            case 'downloaded':
                              {
                                link = responseInfo.links[0];
                              }
                            default:
                              {
                                print(responseInfo.status);
                              }
                          }
                        }
                    }

                    await Future.delayed(Duration(seconds: 5));
                    return true;
                  });

                  return link;
                }
              case 'downloaded':
                {
                  return torrentInfo.links[0];
                }
            }
          }
      }

      return "";
    } else {
      return Future.error(MissingTraktAccessToken());
    }
  }

  Future<void> _selectFiles(String id, TorrentEpisode torrentEpisode, {int overrideId = -1}) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      switch (response.statusCode) {
        case 200:
          {
            final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);

            var downloadsId = overrideId;
            if (overrideId == -1) {
              List<int> ids = [];

              for (var file in torrentInfo.files) {
                if (TorrentHelper.checkFile(file.path, torrentEpisode)) {
                  ids.add(file.id);
                }
              }

              if (ids.isNotEmpty) {
                downloadsId = ids[0];
              } else {
                if (context.mounted) {
                  showPlatformDialog(
                    context: context,
                    builder: (context) => PlatformAlertDialog(
                      title: Text('Torrent error'),
                      content: Text('Episode not found.'),
                    ),
                  );
                }
                return Future.error(Exception('No Files found that match the episode'));
              }
            }

            currentFileId = downloadsId;

            var downloadIds = await _instantAvailable(torrentInfo.hash, downloadsId).onError(
              (error, stackTrace) => currentFileId.toString(),
            );

            final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
            await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': downloadIds});
          }
        default:
          return Future.error(Exception('Unknown Status Code'));
      }
    } else {
      return Future.error(Exception('Missing Access Token'));
    }
  }

  Future<String> _instantAvailable(String hash, int id) async {
    var token = await RealDebrid.accessToken();
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/instantAvailability/$hash');
    var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    switch (response.statusCode) {
      case 200:
        {
          Map<String, dynamic> json = jsonDecode(response.body)[hash];

          var list = json['rd'] as List;
          for (Map<String, dynamic> files in list) {
            if (files.containsKey('$id')) {
              return files.keys.join(',');
            }
          }

          return Future.error(Exception('No instant downloads found!'));
        }
      default:
        {
          return Future.error(Exception('No instant downloads found!'));
        }
    }
  }

  Future<Map<String, dynamic>?> unrestrickLink({required String link, required TorrentEpisode torrentEpisode}) async {
    RealDebrid.accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'link': link});

      if (post.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(post.body);
        print(json);
        String video = json["download"];

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowPlayer(
                      media: Media(video),
                      torrentEpisode: torrentEpisode,
                    )));
        return json;
      }
    });

    return null;
  }
}
