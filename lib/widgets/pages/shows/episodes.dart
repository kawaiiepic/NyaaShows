import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nyaashows/torrents/helper.dart';
import 'package:nyaashows/widgets/pages/torrent/torrent_links.dart';

import '../../../trakt/json/enum/media_type.dart';
import '../../../trakt/json/shows/extended_seasons.dart';
import '../../../trakt/json/shows/extended_show.dart';
import '../../../trakt/json/shows/show.dart';
import '../../../trakt/trakt_json.dart';
import '../../../utils/common.dart';

class EpisodesPage extends StatelessWidget {
  const EpisodesPage({super.key, required this.show, required this.season});

  final Show show;
  final ExtendedSeason season;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: TraktJson.seasonEpisodes(show.ids!.trakt, season.number),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                      height: 50,
                      child: Center(
                        child: GestureDetector(
                            onSecondaryTapDown: (details) {
                              final offset = details.globalPosition;
                              showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    offset.dx,
                                    offset.dy,
                                    MediaQuery.of(context).size.width - offset.dx,
                                    MediaQuery.of(context).size.height - offset.dy,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      onTap: () {
                                        TraktJson.stopWatching(MediaType.episode, 100, snapshot.data![index].ids.trakt!);
                                      },
                                      child: Text('Mark as Watched'),
                                    )
                                  ]);
                            },
                            child: TextButton(
                                onPressed: () {
                                  // final episode = TraktJson.

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TorrentLinks(
                                              torrentEpisode: TorrentEpisode(
                                                  showName: show.title!,
                                                  seasonId: snapshot.data![index].season,
                                                  episodeId: snapshot.data![index].number,
                                                  episodeName: snapshot.data![index].title,
                                                  seasonName: season.title,
                                                  showYear: show.year!,
                                                  episodeYear: show.year!,
                                                  showIds: show.ids!,
                                                  episodeIds: snapshot.data![index].ids))));
                                  // NyaaShows.trakt
                                  //     .episodeFromNumber(show: show.ids!.trakt, season: snapshot.data![index].season, episode: snapshot.data![index].number)
                                  //     .then((episode) {
                                  //   Navigator.pushReplacement(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) => TorrentLinks(
                                  //                 torrentEpisode: TorrentEpisode(
                                  //                     showName: show.title!,
                                  //                     seasonId: snapshot.data![index].season,
                                  //                     episodeId: snapshot.data![index].number,
                                  //                     episodeName: snapshot.data![index].title,
                                  //                     seasonName: season.title,
                                  //                     showYear: show.year!,
                                  //                     episodeYear: episode.firstAired.year,
                                  //                     tvdb: snapshot.data![index].ids.tvdb!),
                                  //               )));
                                  // });
                                },
                                child: Text('S${snapshot.data![index].season}:E${snapshot.data![index].number} - ${snapshot.data![index].title}'))),
                      ));
                });
          } else if (snapshot.hasError) {
            return Common.error();
          } else {
            return Common.loading();
          }
        },
      ),
    );
  }
}
