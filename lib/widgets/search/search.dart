import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../main.dart';
import '../../tmdb/tmdb.dart';
import '../../trakt/json/enum/media_type.dart';
import '../../trakt/json/enum/search_type.dart';
import '../../trakt/json/movies/extended_movie.dart';
import '../../trakt/json/search/search.dart' as json_search;
import '../../trakt/json/shows/extended_show.dart';
import '../../trakt/json/shows/watched_progress.dart';
import '../../trakt/trakt.dart';
import '../../tvdb/tvdb.dart';
import '../pages/movies/movie_expanded.dart';
import '../pages/shows/show_expanded.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State createState() => SearchState();
}

class SearchState extends State {
  String? _searchingWithQuery;
  Iterable<Widget> _lastOptions = <Widget>[];
  final String _lastSearchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: SearchAnchor(
          isFullScreen: false,
          viewHintText: 'Search TV Shows, Movies & more...',
          builder: (context, controller) {
            return PlatformSearchBar(
              controller: controller,
              hintText: 'Search TV Shows, Movies & more...',
              onTap: () => controller.openView(),
              onChanged: (value) => controller.openView(),
            );
          },
          suggestionsBuilder: (context, controller) async {
            _searchingWithQuery = controller.text;

            await Future.delayed(Duration(seconds: 1));

            if (_searchingWithQuery != controller.text) {
              return _lastOptions;
            }

            if (_lastSearchQuery == _searchingWithQuery && _lastSearchQuery != "") {
              return _lastOptions;
            }

            final List<json_search.SearchResults> options = await Trakt.search([SearchType.show, SearchType.movie, SearchType.person], _searchingWithQuery!);

            List<Widget> options0 = [];

            List<Widget> persons = [];
            List<Widget> movies = [];
            List<Widget> shows = [];
            var int = 0;

            for (var entry in options) {
              if (entry.type == "person") {
                Widget container = Text(entry.person!.name);
                persons.add(container);
              }

              if (entry.type == "movie") {
                Uint8List? artwork = await TMDB
                    .poster(MediaType.movie, entry.movie!.ids.tmdb!)
                    .onError((error, stackTrace) => TVDB.artwork(MediaType.movie, entry.movie!.ids.tvdb!).onError(
                          (error, stackTrace) {
                            return Uint8List(0);
                          },
                        ));

                ExtendedMovie movie = await Trakt.extendedMovieFromId(entry.movie!.ids.trakt!);

                Widget container = Container(
                    padding: EdgeInsets.all(8),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          controller.closeView(movie.title);
                          NyaaShows.navigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (context) => MovieExpanded(movie: movie),
                          ));
                        },
                        child: Tooltip(
                          message: entry.movie!.title,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Ink(
                                height: 100,
                                width: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.cover), borderRadius: BorderRadius.circular(10)),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${entry.movie!.title} (${entry.movie!.year?.toString()})'),
                                  Text(
                                    movie.genres.join(', '),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              )
                            ],
                          ),
                        )));

                movies.add(container);
              }

              if (entry.type == "show") {
                Uint8List? artwork = await TMDB
                    .poster(MediaType.show, entry.show!.ids.tmdb!)
                    .onError((error, stackTrace) => TVDB.artwork(MediaType.show, entry.show!.ids.tvdb!).onError(
                          (error, stackTrace) {
                            return Uint8List(0);
                          },
                        ));
                ExtendedShow show = await Trakt.extendedShowFromId(entry.show!.ids.trakt!);
                // WatchedProgress progress = await TraktJson.watchedProgress(entry.show!.ids!.trakt!);

                Widget container = Container(
                    padding: EdgeInsets.all(8),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          controller.closeView(show.title);
                          WatchedProgress progress = await Trakt.watchedProgress(entry.show!.ids.trakt!);
                          NyaaShows.navigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (context) => ShowExpanded(
                              show: show,
                              watchedProgress: progress,
                            ),
                          ));
                        },
                        child: Tooltip(
                          message: entry.show!.title,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Ink(
                                height: 100,
                                width: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.cover), borderRadius: BorderRadius.circular(10)),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${entry.show!.title} (${entry.show!.year?.toString()})',
                                  ),
                                  Text(
                                    show.genres!.join(', '),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              )
                            ],
                          ),
                        )));

                shows.add(container);
              }
            }

            if (shows.isNotEmpty) {
              options0.add(Text('Shows'));
              options0.addAll(shows);
            }

            if (movies.isNotEmpty) {
              options0.add(Text('Movies'));
              options0.addAll(movies);
            }

            if (persons.isNotEmpty) {
              options0.add(Text('Persons'));
              options0.addAll(persons);
            }

            _lastOptions = options0;

            return _lastOptions;
          },
        ));
  }
}
