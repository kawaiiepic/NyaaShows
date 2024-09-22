import 'package:flutter/material.dart';
import 'package:nyaashows/data/trakt/all_seasons.dart';
import 'package:nyaashows/data/trakt/episodes_from_season.dart';
import 'package:nyaashows/data/trakt/watched.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/torrent_links.dart';
import 'package:nyaashows/torrents/helper.dart';

class EpisodesPage extends StatelessWidget {
  const EpisodesPage({super.key, required this.show, required this.season});

  final Show show;
  final Season season;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<EpisodesFromSeason>?>(
        future: NyaaShows.trakt.episodesFromSeason(id: show.ids.trakt, season: season.number),
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasData) {
            child = ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                      height: 50,
                      child: Center(
                        child: TextButton(
                            onPressed: () {
                              NyaaShows.trakt.episodeFromNumber(show: show.ids.trakt, season: snapshot.data![index].season, episode: snapshot.data![index].number).then((episode) {
                                 Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TorrentLinks(
                                              torrentEpisode: TorrentEpisode(
                                                  showName: show.title,
                                                  seasonId: snapshot.data![index].season,
                                                  episodeId: snapshot.data![index].number,
                                                  episodeName: snapshot.data![index].title,
                                                  seasonName: season.title,
                                                  showYear: show.year,
                                                  episodeYear: episode.firstAired.year,
                                                  tvdb: snapshot.data![index].ids.tvdb!),
                                            )));
                              });
                            },
                            child: Text('S${snapshot.data![index].season}:E${snapshot.data![index].number} - ${snapshot.data![index].title}')),
                      ));
                });
          } else if (snapshot.hasError) {
            child = const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            );
          } else {
            child = const Center(
                child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ));
          }

          return child;
        },
      ),
    );
  }
}
