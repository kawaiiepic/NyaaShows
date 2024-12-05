import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nyaashows/trakt/json/shows/episode.dart';
import 'package:nyaashows/tvdb/tvdb.dart';

import '../../main.dart';
import '../../tmdb/tmdb.dart';
import '../../torrents/helper.dart';
import '../../trakt/json/combined_show.dart';
import '../../trakt/json/enum/media_type.dart';
import '../../trakt/json/shows/watched_progress.dart';
import '../../trakt/json/sync/playback_progress.dart';
import '../../trakt/json/sync/watched.dart';
import '../../trakt/trakt_json.dart';
import '../../utils/common.dart';
import '../search/search.dart';
import 'shows/expanded_next_up.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
      Search()
    ]);
  }

  Widget nextUp() {
    return FutureBuilder(
        future: TraktJson.nextUp(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.done) {
            if (snap.hasData) {
              // final List<CombinedShow> combinedShows = snap.data!;
              final List<Watched> watchedShows = snap.data!;
              double titleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 12);
              double episodeTitleFontSize = clampDouble(((MediaQuery.of(context).size.height * 0.12) * 0.15), 0.0, 15);
              List<Widget> containers = [];

              int count = 0;

              for (final watched in watchedShows) {
                count++;

                if (count == 20) {
                  break;
                }

                var widget = FutureBuilder(
                  future: TMDB.poster(MediaType.show, watched.show.ids!.tmdb!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var artwork = snapshot.data!;
                      FutureBuilder<Episode> futureBuilder;

                      return FutureBuilder(
                        future: TraktJson.watchedProgress(watched.show.ids!.trakt!),
                        builder: (context, progressData) {
                          if (progressData.hasData) {
                            var progress = progressData.data!;
                            if (progress.resetAt != null) {
                              outerLoop:
                              for (var season in progress.seasons) {
                                for (var episode in season.episodes) {
                                  if (episode.lastWatchedAt != null && DateTime.parse(episode.lastWatchedAt).compareTo(DateTime.parse(progress.resetAt)) < 0) {
                                    futureBuilder = FutureBuilder(
                                      future: TraktJson.episode(watched.show.ids!.trakt, season.number, episode.number),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var episode = snapshot.data!;
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
                                                              show: watched.show,
                                                              watchedProgress: progress,
                                                              episode: episode,
                                                            )),
                                                  ),
                                                  child: Stack(alignment: Alignment.topRight.add(FractionalOffset(0.4, 0.6)), children: [
                                                    Ink(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.cover),
                                                          borderRadius: BorderRadius.circular(18)),
                                                    ),
                                                    Ink(
                                                      height: MediaQuery.of(context).size.height * 0.02,
                                                      width: MediaQuery.of(context).size.height * 0.02,
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.circular(40)),
                                                      child: Tooltip(
                                                          message:
                                                              '${((episode.season * episode.number / progress.aired) * 100).round()}% watched\n${(episode.season * episode.number)}/${progress.aired} episodes\n${(progress.aired - ((episode.season * episode.number)))} remaining',
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 5,
                                                            value: (episode.season * episode.number) / progress.aired,
                                                          )),
                                                    ),
                                                  ]),
                                                )),
                                              ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(top: 10),
                                                constraints: BoxConstraints(maxWidth: 120),
                                                child: Tooltip(
                                                    message: episode.title,
                                                    child: Container(
                                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 10),
                                                      child: Text(
                                                        'S${episode.season}:E${episode.number} - ${episode.title}',
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
                                    break outerLoop;
                                  }
                                }
                              }
                              if (futureBuilder != null) {
                                return futureBuilder;
                              } else {
                                return Common.loading();
                              }
                            } else {
                              if (progress.nextEpisode != null) {
                                return Column(children: [
                                  Container(
                                    alignment: Alignment.center,
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
                                                    await TraktJson.addHistory(MediaType.episode, progress.nextEpisode!.ids.trakt!);
                                                    await TraktJson.watchedProgress(watched.show.ids!.trakt!, refresh: true);
                                                    setState(() {
                                                      TraktJson.nextUpFuture = Future.value([]);
                                                    });
                                                  },
                                                  child: Text('Mark as Watched'),
                                                )
                                              ]);
                                        },
                                        child: Material(
                                            child: InkWell(
                                                borderRadius: BorderRadius.circular(16),
                                                onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => ShowExpanded(
                                                                show: watched.show,
                                                                watchedProgress: progress,
                                                              )),
                                                    ),
                                                child: Stack(alignment: Alignment.topRight.add(FractionalOffset(0.4, 0.6)), children: [
                                                  Ink(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.cover),
                                                        borderRadius: BorderRadius.circular(18)),
                                                  ),
                                                  Ink(
                                                    height: MediaQuery.of(context).size.height * 0.02,
                                                    width: MediaQuery.of(context).size.height * 0.02,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.circular(40)),
                                                    child: Tooltip(
                                                        message:
                                                            '${((progress.completed / progress.aired) * 100).round()}% watched\n${progress.completed}/${progress.aired} episodes\n${(progress.aired - progress.completed)} remaining',
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          value: progress.completed / progress.aired,
                                                        )),
                                                  ),
                                                ]))),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      constraints: BoxConstraints(maxWidth: 120),
                                      child: Tooltip(
                                          message: progress.nextEpisode?.title,
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10),
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 10),
                                            child: Text(
                                              'S${progress.nextEpisode?.season}:E${progress.nextEpisode?.number} - ${progress.nextEpisode!.title!}',
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: episodeTitleFontSize),
                                            ),
                                          )))
                                ]);
                              } else {
                                return Container();
                              }
                            }
                          } else {
                            return Common.loading();
                          }
                        },
                      );
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
                                NyaaShows.navigatorKey.currentState!.push(platformPageRoute(
                                  context: NyaaShows.navigatorKey.currentContext!,
                                  builder: (context) => ExpandedNextUp(),
                                ));
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
            } else {
              return Common.loading();
            }
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

                print(element.progress);

                if (element.show != null) {
                  widget = FutureBuilder(
                    future: TMDB.poster(MediaType.show, element.show!.ids!.tmdb!),
                    builder: (context, artwork) {
                      if (artwork.hasData) {
                        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                                              await TraktJson.removePlaybackItem(element.id);
                                              setState(() {});
                                            },
                                            child: Text('Remove'),
                                          )
                                        ]);
                                  },
                                  child: Material(
                                      child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
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
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Ink(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(image: MemoryImage(artwork.data!), fit: BoxFit.cover),
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.2,
                                                child: Padding(
                                                    padding: EdgeInsets.only(bottom: 5.0),
                                                    child: LinearProgressIndicator(
                                                      borderRadius: BorderRadius.circular(12),
                                                      value: element.progress,
                                                      minHeight: 6,
                                                    )),
                                              )
                                            ],
                                          )))),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              constraints: BoxConstraints(maxWidth: 120),
                              child: Tooltip(
                                  message: element.episode!.title,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 10),
                                    child: Text(
                                      'S${element.episode!.season}:E${element.episode!.number} - ${element.episode!.title}',
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: episodeTitleFontSize),
                                    ),
                                  )))
                        ]);
                      } else {
                        return Container();
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
                                                TraktJson.removePlaybackItem(element.id);
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
                                        image: DecorationImage(image: MemoryImage(artwork.data!), fit: BoxFit.fill), borderRadius: BorderRadius.circular(12)),
                                  )))),
                            ),
                          ),
                        ]);
                      } else if (artwork.hasError) {
                        return Common.error();
                      } else {
                        return Container();
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
