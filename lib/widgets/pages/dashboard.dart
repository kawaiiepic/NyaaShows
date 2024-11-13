import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nyaashows/tvdb/tvdb.dart';

import '../../tmdb/tmdb.dart';
import '../../torrents/helper.dart';
import '../../trakt/json/combined_show.dart';
import '../../trakt/json/enum/media_type.dart';
import '../../trakt/json/sync/playback_progress.dart';
import '../../trakt/trakt_json.dart';
import '../../utils/common.dart';
import '../search/search.dart';
import 'shows/show_expanded.dart';
import 'torrent/torrent_links.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> showsWidget = [];

  @override
  void initState() {
    super.initState();
    // _playbackProgressFuture = TraktJson.playbackProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Stack(children: [
              SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.fromLTRB(8, 80, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      playbackProgress(),
                      // Padding(
                      //     padding: EdgeInsets.all(8),
                      //     child: Text(
                      //       'Next Up',
                      //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      //     )),
                      nextUp()
                    ],
                  )),
              Search(),
            ])));
  }

  Widget nextUp() {
    return FutureBuilder(
        future: TraktJson.nextUp(),
        builder: (_, snap) {
          if (snap.hasData) {
            final List<CombinedShow> combinedShows = snap.data!;
            double titleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 12);
            double episodeTitleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 15);
            List<Widget> containers = [];

            for (final element in combinedShows) {
              final CombinedShow combinedShow = element;
              var widget = FutureBuilder(
                future: TMDB.poster(MediaType.show, combinedShow.show.ids!.tmdb!).onError(
                      (error, stackTrace) => TVDB.artwork(combinedShow.show.ids!.tvdb!),
                    ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var artwork = snapshot.data!;

                    return Column(children: [
                      Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minWidth: 120, minHeight: 150, maxWidth: 150, maxHeight: 200),
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: AspectRatio(
                          aspectRatio: 0.75,
                          child: Material(
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowExpanded(
                                                  show: combinedShow.show,
                                                  watchedProgress: combinedShow.watchedProgress,
                                                )),
                                      ),
                                  child: Ink(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.fill), borderRadius: BorderRadius.circular(18)),
                                      child: Tooltip(
                                        message: combinedShow.show.title,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                            Tooltip(
                                              message:
                                                  '${((combinedShow.watchedProgress.completed / combinedShow.watchedProgress.aired) * 100).round()}% watched\n${combinedShow.watchedProgress.completed}/${combinedShow.watchedProgress.aired} episodes\n${(combinedShow.watchedProgress.aired - combinedShow.watchedProgress.completed)} remaining',
                                              child: LinearProgressIndicator(
                                                minHeight: 8,
                                                value: combinedShow.watchedProgress.completed / combinedShow.watchedProgress.aired,
                                              ),
                                            ),
                                          ]),
                                        ),
                                      )))),
                        ),
                      ),
                      Text(
                        'S${combinedShow.watchedProgress.nextEpisode!.season}:E${combinedShow.watchedProgress.nextEpisode!.number}',
                        textAlign: TextAlign.center,
                        textHeightBehavior: TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                      ),
                      Container(
                          constraints: BoxConstraints(maxWidth: 120),
                          child: Tooltip(
                              message: combinedShow.watchedProgress.nextEpisode!.title,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 10),
                                child: Text(
                                  combinedShow.watchedProgress.nextEpisode!.title!,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: episodeTitleFontSize),
                                ),
                              )))
                    ]);
                  } else if (snapshot.hasError) {
                    return Common.error();
                  } else {
                    return Common.loading();
                  }
                },
              );

              containers.add(widget);
              containers.add(
                SizedBox(width: 10),
              );
            }

            containers.add(
              Column(children: [
                Stack(alignment: Alignment.center, children: [
                  Container(
                    constraints: BoxConstraints(minWidth: 120, minHeight: 150, maxWidth: 150, maxHeight: 200),
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Material(
                        child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: combinedShow)),
                              // );
                            },
                            child: Ink(
                              decoration: BoxDecoration(color: Colors.pink.shade400, borderRadius: BorderRadius.circular(18)),
                              child: Tooltip(
                                message: 'View More',
                              ),
                            ))),
                  ),
                  Icon(Icons.book, color: Colors.pink[50], size: 50),
                ]),
                Text('View all')
              ]),
            );

            showsWidget = containers;

            Widget title = Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Next Up',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ));

            return Column(
              children: [
                title,
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: containers,
                    ))
              ],
            );
          } else if (snap.hasError) {
            return Common.error();
          } else {
            return Common.loading();
          }
        });
  }

  Widget playbackProgress() {
    return FutureBuilder(
        future: TraktJson.playbackProgress(),
        builder: (_, snap) {
          if (snap.hasData) {
            final List<PlaybackProgress> progressList = snap.data!;
            // final List<PlaybackProgress> progressList = [];

            var title = Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Continue Watching',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ));

            if (progressList.isEmpty) {
              return Container();
            } else {
              double titleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 12);
              double episodeTitleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 15);
              List<Widget> containers = [];
              for (final element in progressList) {
                Widget? widget;

                if (element.show != null) {
                  widget = FutureBuilder(
                    future: TMDB.poster(MediaType.show, element.show!.ids!.tmdb!),
                    builder: (context, artwork) {
                      if (artwork.hasData) {
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            // alignment: Alignment.center,
                            constraints: BoxConstraints(minWidth: 120, minHeight: 150, maxWidth: 150, maxHeight: 200),
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: AspectRatio(
                              aspectRatio: 0.75,
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
                                            onTap: () async {
                                             await TraktJson.removePlaybackItem(element);
                                              setState(() {

                                              });
                                            },
                                            child: Text('Remove'),
                                          )
                                        ]);
                                  },
                                  child: Material(
                                      child: InkWell(
                                          onTap: () => {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => TorrentLinks(
                                                            torrentEpisode: TorrentEpisode(
                                                                showName: element.show!.title!,
                                                                seasonId: element.episode!.season,
                                                                episodeId: element.episode!.number,
                                                                episodeName: element.episode!.title,
                                                                seasonName: "",
                                                                showYear: element.show!.year!,
                                                                episodeYear: element.show!.year!,
                                                                showIds: element.show!.ids!,
                                                                episodeIds: element.episode!.ids))))
                                              },
                                          child: Ink(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(image: MemoryImage(artwork.data!), fit: BoxFit.fill),
                                                borderRadius: BorderRadius.circular(18)),
                                          )))),
                            ),
                          ),
                          Text(
                            'S${element.episode!.season}:E${element.episode!.number}',
                            textAlign: TextAlign.center,
                            textHeightBehavior: TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                          ),
                          Container(
                              constraints: BoxConstraints(maxWidth: 120),
                              child: Tooltip(
                                  message: element.episode!.title,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 10),
                                    child: Text(
                                      element.episode!.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: episodeTitleFontSize),
                                    ),
                                  )))
                        ]);
                      } else {
                        return Common.error();
                      }
                    },
                  );
                } else if (element.movie != null) {
                  widget = FutureBuilder(
                    future: TMDB.poster(MediaType.movie, element.movie!.ids.tmdb!),
                    builder: (context, artwork) {
                      if (artwork.hasData) {
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            // alignment: Alignment.center,
                            constraints: BoxConstraints(minWidth: 120, minHeight: 150, maxWidth: 150, maxHeight: 200),
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: AspectRatio(
                              aspectRatio: 0.75,
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
                                              setState(() {
                                                TraktJson.removePlaybackItem(element);
                                              });
                                            },
                                            child: Text('Remove'),
                                          )
                                        ]);
                                  },
                                  child: Material(
                                      child: InkWell(
                                          // onTap: () => Navigator.push(
                                          //       context,
                                          //       // MaterialPageRoute(builder: (context) => ShowExpanded(show: element.movie!)),
                                          //     ),
                                          child: Ink(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(image: MemoryImage(artwork.data!), fit: BoxFit.fill), borderRadius: BorderRadius.circular(18)),
                                  )))),
                            ),
                          ),
                        ]);
                      } else if (artwork.hasError) {
                        return Common.error();
                      } else {
                        return Common.loading();
                      }
                    },
                  );
                }

                widget ??= Container();
                containers.add(widget);
                containers.add(
                  SizedBox(width: 10),
                );
              }

              return Column(
                children: [
                  title,
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: containers,
                      ))
                ],
              );
            }
          } else if (snap.hasError) {
            return Common.error();
          } else {
            return Common.loading();
          }
        });
  }
}
