import 'package:flutter/material.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/helper.dart';
import 'package:nyaashows/torrents/tpb.dart';

class TorrentLinks extends StatelessWidget {
  const TorrentLinks({super.key, required this.torrentEpisode});

  final TorrentEpisode torrentEpisode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Torrents")),
        body: FutureBuilder<List<TorrentFile>>(
            future: TorrentHelper.search(torrentEpisode: torrentEpisode),
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                child = ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: TextButton(
                            onPressed: () async {
                              NyaaShows.realDebrid.addMagnet(magnet: snapshot.data![index].magnet, context: context, torrentEpisode: torrentEpisode);
                            },
                            child: Text(
                              snapshot.data![index].title,
                              textAlign: TextAlign.center,
                            )),
                      );
                    });
              } else if (snapshot.hasError) {
                child = const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                child = const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }

              return child;
            }));
  }
}
