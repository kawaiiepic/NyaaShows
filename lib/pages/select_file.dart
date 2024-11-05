import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/pages/player.dart';
import 'package:nyaashows/utils/utils.dart';

import '../main.dart';
import '../torrents/helper.dart';

class SelectFile extends StatefulWidget {
  const SelectFile({super.key, required this.files, required this.torrentEpisode});

  final Map<dynamic, dynamic> files;
  final TorrentEpisode torrentEpisode;

  @override
  State<StatefulWidget> createState() => SelectFileState();
}

class SelectFileState extends State<SelectFile> {
  late Timer timer;
  double progress = 0.0;
  late var _alertSetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Select File")),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: super.widget.files.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.purple,
                child: Center(
                    child: TextButton(
                        onPressed: () async {
                          progress = 0;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Downloading torrent'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      timer.cancel();
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
                                                "${((super.widget.files[index + 1]) as Set).elementAt(2)}")),
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


                          var id = ((super.widget.files[index + 1]) as Set).elementAt(0);
                          var fileId = ((super.widget.files[index + 1]) as Set).elementAt(1);
                          var token = await NyaaShows.realDebrid.accessToken();

                          final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
                          var post = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': fileId.toString()});

                          if (post.statusCode == 204) {
                            timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
                              final url2 = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
                              var get2 = await http.get(url2, headers: {'Authorization': 'Bearer $token'});
                              Map<String, dynamic> decode2 = jsonDecode(get2.body);

                              print(decode2['status']);
                              _alertSetState(
                                () {
                                  progress = double.parse(decode2['progress'].toString());
                                },
                              );

                              if (decode2['status'] == 'downloaded') {
                                timer.cancel();
                                var post2 = await http.post(Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link'),
                                    headers: {'Authorization': 'Bearer $token'}, body: {'link': (decode2['links'] as List<dynamic>).first});

                                if (post2.statusCode == 200) {
                                  Map<String, dynamic> json = jsonDecode(post2.body);
                                  String video = json["download"];

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => VideoPlayer(
                                                media: Media(video),
                                                torrentEpisode: super.widget.torrentEpisode,
                                              )));
                                }
                              }
                            });
                          }
                        },
                        child: Text('${((super.widget.files[index + 1]) as Set).elementAt(2)}'))),
              );
            }));
  }
}
