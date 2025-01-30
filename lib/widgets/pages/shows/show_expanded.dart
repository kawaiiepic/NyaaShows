import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../torrents/helper.dart';
import '../../../trakt/json/shows/extended_show.dart';
import '../../../trakt/json/shows/watched_progress.dart';
import '../../../trakt/trakt_json.dart';
import '../../../utils/common.dart';
import '../torrent/torrent_links.dart';
import 'episodes.dart';
import '../../../trakt/json/shows/episode.dart' as ShowsEpisode;

class ShowExpanded extends StatelessWidget {
  const ShowExpanded({super.key, this.watchedProgress, required this.show, this.episode});

  // final CombinedShow combinedShow;
  final WatchedProgress? watchedProgress;
  final ShowsEpisode.Episode? episode;
  final ExtendedShow show;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
          child: FutureBuilder(
        future: TraktJson.seasonsFromId(show.ids!.trakt),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final seasons = snapshot.data;
            FutureBuilder<ShowsEpisode.Episode>? futureBuilder;

            if (episode != null) {
              return Column(
                children: [
                  const Text('Next Up:'),
                  Text('S${episode!.season}:E${episode!.number} - ${episode!.title}'),
                  const Text('Seasons:'),
                  Expanded(child: listBuilder(seasons))
                ],
              );
            } else {
              if (watchedProgress != null) {
                outerLoop:
                for (var season in watchedProgress!.seasons) {
                  for (var episode in season.episodes) {
                    if (watchedProgress!.resetAt != null &&
                        episode.lastWatchedAt != null &&
                        DateTime.parse(episode.lastWatchedAt).compareTo(DateTime.parse(watchedProgress!.resetAt)) < 0) {
                      futureBuilder = FutureBuilder(
                        future: TraktJson.episode(show.ids!.trakt, season.number, episode.number),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var episode = snapshot.data!;
                            return Text('S${episode.season}:E${episode.number} - ${episode.title}');
                          } else if (snapshot.hasError) {
                            return Common.error();
                          } else {
                            return Common.loading();
                          }
                        },
                      );
                      break outerLoop;
                    } else {}
                  }
                }

                if (watchedProgress!.resetAt != null) {
                  return Column(
                    children: [const Text('Next Up:'), futureBuilder!, const Text('Seasons:'), Expanded(child: listBuilder(seasons))],
                  );
                } else if (watchedProgress!.lastWatchedAt != null) {
                  return Column(
                    children: [
                      const Text('Next Up:'),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                platformPageRoute(
                                  context: context,
                                  builder: (context) => TorrentLinks(
                                    torrentEpisode: TorrentEpisode(
                                        showName: show.title!,
                                        seasonId: watchedProgress!.nextEpisode!.season,
                                        episodeId: watchedProgress!.nextEpisode!.number,
                                        episodeName: '',
                                        seasonName: '',
                                        showYear: 0,
                                        episodeYear: 0,
                                        episodeIds: watchedProgress!.nextEpisode!.ids,
                                        showIds: show.ids!),
                                  ),
                                ));
                          },
                          child: Text(
                              'S${watchedProgress!.nextEpisode?.season}:E${watchedProgress!.nextEpisode?.number} - ${watchedProgress!.nextEpisode?.title}')),
                      const Text('Seasons:'),
                      Expanded(child: listBuilder(seasons))
                    ],
                  );
                } else {
                  return Column(
                    children: [const Text('Seasons:'), Expanded(child: listBuilder(seasons))],
                  );
                }
              } else {
                return Column(
                  children: [const Text('Seasons:'), Expanded(child: listBuilder(seasons))],
                );
              }
            }
          } else if (snapshot.hasError) {
            return Common.error();
          } else {
            return Common.loading();
          }
        },
      )),
    );
  }

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
                      show: show,
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
}
