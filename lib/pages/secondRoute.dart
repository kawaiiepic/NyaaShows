
import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/pages/torrent_links.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(show.show.title),
        ),
        body: FutureBuilder<TraktProgress?>(
            future: DataManager.traktData.showProgress(show.show.ids.trakt),
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                child = Center(
                    child: Column(
                  children: [
                    Text(show.lastWatchedAt.toString()),
                    Text(show.plays.toString()),
                    Text(show.seasons.length.toString()),
                    Text(show.show.title),
                    Text(show.show.year.toString()),
                    Text(show.show.ids.toString()),
                    Text(snapshot.data!.toString()),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TorrentLinks(show: show, progress: snapshot.data!)));
                      },
                      child: const Text('Play'),
                    )
                  ],
                ));
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
