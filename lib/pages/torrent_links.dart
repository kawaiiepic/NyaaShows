import 'package:flutter/material.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/tpb.dart';

class TorrentLinks extends StatelessWidget {
  const TorrentLinks({super.key, required this.show, required this.progress});

  final Show show;
  final TraktProgress progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Torrents")),
        body: FutureBuilder<List<TPB>>(
            future: ThePirateBay.torrent(show: show, progress: progress),
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                var validList = [];
                for (TPB e in snapshot.data!) {
                  print(e.title);
                  if (progress.nextEpisode != null) {
                    var nextEpisode = progress.nextEpisode!;
                    var result = [nextEpisode.season.toString()].every(e.title.contains);
                    if (result) {
                      print(nextEpisode.number.toString());
                      validList.add(e);
                    }

                    // if (validList.isEmpty) {
                    //   validList = snapshot.data!;
                    // }
                  }
                }
                child = ListView.builder(
                    itemCount: validList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: TextButton(
                            onPressed: () async {
                              await NyaaShows.realDebrid.addMagnet(magnet: validList[index].magnet, context: context, progress: progress);
                              // NyaaShows.realDebrid.checkTorrents();
                            },
                            child: Text(
                              validList[index].title,
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
