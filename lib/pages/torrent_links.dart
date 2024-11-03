import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/overridden_torrents.dart';
import 'package:nyaashows/pages/player.dart';
import 'package:nyaashows/torrents/helper.dart';
import 'package:nyaashows/utils/utils.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class TorrentLinks extends StatefulWidget {
  const TorrentLinks({super.key, required this.torrentEpisode});

  final TorrentEpisode torrentEpisode;

  @override
  State createState() => TorrentLinksState();
}

class TorrentLinksState extends State<TorrentLinks> {
  Timer? timer;
  late Future<List<TorrentFile>> _searchResults;
  double progress = 0.0;
  late var _alertSetState;

  @override
  void initState() {
    super.initState();
    _searchResults = TorrentHelper.search(torrentEpisode: super.widget.torrentEpisode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('${super.widget.torrentEpisode.showName} S${super.widget.torrentEpisode.seasonId}:E${super.widget.torrentEpisode.episodeId}')),
        body: FutureBuilder<List<TorrentFile>>(
            future: _searchResults,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Column(children: [Text("No torrents found."), TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OverriddenTorrents(torrentEpisode: super.widget.torrentEpisode)));
                      },
                      child: Text("Override Search"),
                    )],);
                } else {
                  return Column(children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                height: 50,
                                child: TextButton(
                                    onPressed: () async {
                                      progress = 0;
                                      addMagnet(magnet: snapshot.data![index].magnet, context: context, torrentEpisode: super.widget.torrentEpisode);

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Downloading torrent'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  if (timer != null) {
                                                    timer!.cancel();
                                                  }
                                                },
                                                child: Text('Cancel Download'),
                                              )
                                            ],
                                            content: StatefulBuilder(
                                              builder: (context, setState) {
                                                _alertSetState = setState;
                                                return Column(
                                                  children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            "${snapshot.data![index].title} - ${snapshot.data![index].provider} | S: ${snapshot.data![index].seeders} L: ${snapshot.data![index].leechers}")),
                                                    Utils.loading(),
                                                    Text('$progress%'),
                                                    LinearProgressIndicator(
                                                      value: progress / 100,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "${snapshot.data![index].title} - ${snapshot.data![index].provider} | S: ${snapshot.data![index].seeders} L: ${snapshot.data![index].leechers}",
                                      textAlign: TextAlign.center,
                                    )),
                              );
                            })),
                    Center(
                        child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OverriddenTorrents(torrentEpisode: super.widget.torrentEpisode)));
                      },
                      child: Text("Override Search"),
                    ))
                  ]);
                }
              } else if (snapshot.hasError) {
                return const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                return Utils.loading();
              }
            }));
  }

  Future<void> addMagnet({required String magnet, required BuildContext context, required TorrentEpisode torrentEpisode}) async {
    await NyaaShows.realDebrid.accessToken().then(
      (value) async {
        if (value != null) {
          final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/addMagnet');
          var response = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'magnet': magnet});

          if (response.statusCode == 201) {
            developer.log('addMagnet');
            Map<String, dynamic> json = jsonDecode(response.body);
            var id = json["id"];
            checkMagnet(id, context, torrentEpisode: torrentEpisode);
          } else if (response.statusCode == 401) {
            developer.log('Access Token expired!');
            NyaaShows.realDebrid.revolkToken();

            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Real-Debrid: Access-Token expired'),
                content: const Text('Your real-debrid access token has expired, what should we do?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Nothing'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.pop(context, 'Renew Token');
                      // loginPopup(context);
                    },
                    child: const Text('Renew Token'),
                  ),
                ],
              ),
            );
          }
        } else {
          // loginPopup(context);
        }
      },
    );
  }

  Future<void> instantAvailable(String hash) async {
    var token = await NyaaShows.realDebrid.accessToken();
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/instantAvailability/$hash');
    var get = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    Map<String, dynamic> decode = jsonDecode(get.body);

    print(decode);
  }

  Future<void> checkMagnet(String id, BuildContext context, {required TorrentEpisode torrentEpisode}) async {
    if (context.mounted) {
      await NyaaShows.realDebrid.accessToken().then((value) async {
        timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
          print("Timer!");
          final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
          var get = await http.get(url, headers: {'Authorization': 'Bearer $value'});
          Map<String, dynamic> decode = jsonDecode(get.body);

          // NyaaShows.log(decode.toString());
          switch (decode['status']) {
            case 'waiting_files_selection':
              selectFiles(id, decode, context, torrentEpisode: torrentEpisode);
              print('awaiting selection');
              break;
            case 'downloading':
              _alertSetState(
                () {
                  progress = double.parse(decode['progress'].toString());
                },
              );
              break;
            case 'downloaded':
              timer.cancel();
              var link = (decode['links'] as List<dynamic>).first;
              unrestrickLink(link: link, context: context, torrentEpisode: torrentEpisode);
              print('Downloaded!!!');
              _alertSetState(() {
                progress = 100;
              });
              Navigator.of(context).pop();

              break;
            case 'queued':
              print('Still waiitng');
          }
        });

        // print(decode);
      });
    }
  }

  Future<void> selectFiles(String id, Map<String, dynamic> json, BuildContext context, {required TorrentEpisode torrentEpisode}) async {
    await NyaaShows.realDebrid.accessToken().then((value) async {
      List<dynamic> files = json["files"];
      List<int> ids = [];

      // String season = progress.nextEpisode!.season.toString();
      // String episode = progress.nextEpisode!.number.toString();
      // String episodeName = progress.nextEpisode!.title;

      for (var file in files) {
        var id0 = file["id"];
        String path = file["path"];
        var bytes = file["bytes"];
        var selected = file["selected"];
        if (TorrentHelper.checkFile(path, torrentEpisode)) {
          ids.add(id0);
        }
      }

      if (ids.isEmpty) {
        print("No episodes found!");
      }

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'files': ids.join(',')});
      print(ids.join(','));
      print(post.body);
      if (post.statusCode == 204) {
        // checkTorrents();
        // checkMagnet(id, context, torrentEpisode: torrentEpisode);
      }
    });
  }

  Future<Map<String, dynamic>?> unrestrickLink({required String link, required BuildContext context, required TorrentEpisode torrentEpisode}) async {
    NyaaShows.realDebrid.accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'link': link});

      if (post.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(post.body);
        print(json);
        String video = json["download"];

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPlayer(
                      media: Media(video),
                      torrentEpisode: torrentEpisode,
                    )));
        return json;
      }
    });

    return null;
  }
}
