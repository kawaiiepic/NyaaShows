import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/all_seasons.dart' as all_seasons;
import 'package:nyaashows/data/trakt/watched.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/episodes_page.dart';
import 'package:nyaashows/pages/torrent_links.dart';
import 'package:nyaashows/trakt/trakt.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key, required this.combinedShow});

  final CombinedShow combinedShow;

  Widget listBuilder(seasons) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 50,
          child: Center(
              child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodesPage(
                      show: combinedShow.show,
                      season: seasons[index],
                    ),
                  ));
            },
            child: Text('$index: ${seasons[index].title}'),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(combinedShow.show.title),
        ),
        body: FutureBuilder<TraktProgress?>(
            future: DataManager.traktData.showProgress(combinedShow.show.ids.trakt),
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                final id = combinedShow.show.ids.trakt;
                Widget child2;
                child = FutureBuilder<List<all_seasons.Season>?>(
                  future: NyaaShows.trakt.seasonsFromId(id: id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final seasons = snapshot.data!;
                      child2 = Column(
                        children: [
                          const Text('Next Up:'),
                          TextButton(onPressed: () {
                            Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TorrentLinks(
                                              torrentEpisode: TorrentEpisode(showName: combinedShow.show.title, seasonId: combinedShow.watchedProgress.nextEpisode!.season, episodeId: combinedShow.watchedProgress.nextEpisode!.number, episodeName: combinedShow.watchedProgress.nextEpisode!.title, seasonName: ''),
                                            )));

                          }, child: Text('S${combinedShow.watchedProgress.nextEpisode?.season}:E${combinedShow.watchedProgress.nextEpisode?.number} - ${combinedShow.watchedProgress.nextEpisode?.title}')),
                          const Text('Seasons:'),
                          Expanded(child: listBuilder(seasons))
                        ],
                      );
                    } else if (snapshot.hasError) {
                      child2 = const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                      );
                    } else {
                      child2 = const Center(
                          child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ));
                    }

                    return child2;
                  },
                );
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
