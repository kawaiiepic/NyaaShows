import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../tmdb/tmdb.dart';
import '../../trakt/json/combined_show.dart';
import '../../trakt/json/enum/search_type.dart';
import '../../trakt/json/search/search.dart' as json_search;
import '../../trakt/json/shows/extended_show.dart';
import '../../trakt/json/shows/show.dart';
import '../../trakt/json/shows/watched_progress.dart';
import '../../trakt/trakt_json.dart';
import '../../tvdb/tvdb.dart';
import '../pages/shows/show_expanded.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State createState() => SearchState();
}

class SearchState extends State {
  String? _searchingWithQuery;
  Iterable<Widget> _lastOptions = <Widget>[];
  Map<String, Iterable<Widget>> _searchResults = {};
  String _lastSearchQuery = "";

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

            if (_searchingWithQuery != controller.text) {
              return _lastOptions;
            }

            if (_lastSearchQuery == _searchingWithQuery) {
              return _lastOptions;
            }

            if (_searchResults.containsKey(_searchingWithQuery)) {
              return _searchResults[_searchingWithQuery]!;
            }

            final List<json_search.Search> options = await TraktJson.search(SearchType.show, _searchingWithQuery!);

            List<Widget> options0 = [];
            var int = 0;
            for (var entry in options) {
              if (int == 5) {
                break;
              }

              var artwork = await TMDB.poster(entry.show!.ids!.tmdb!).onError(
                    (error, stackTrace) => TVDB.showIcon(entry.show!.ids!.tvdb!).onError(
                          (error, stackTrace) => "",
                        ),
                  );
              ExtendedShow show = await TraktJson.extendedShowFromId(entry.show!.ids!.trakt!);
              WatchedProgress progress = await TraktJson.watchedProgress(entry.show!.ids!.trakt!);

              Widget container = Container(
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          controller.closeView(entry.show!.title!);
                          CombinedShow combinedShow = CombinedShow(show: Show.fromJson(show.toJson()), watchedProgress: progress);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowExpanded(combinedShow: combinedShow),
                              ));
                        });
                      },
                      child: Tooltip(
                        message: entry.show!.title!,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Ink(
                              height: 100,
                              width: 60,
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: NetworkImage(artwork), fit: BoxFit.contain), borderRadius: BorderRadius.circular(10)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.show!.title!} (${entry.show!.year?.toString()})'),
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

              options0.add(container);
              _searchResults[_searchingWithQuery!] = options0;
              int++;
            }

            _lastOptions = options0;

            return _lastOptions;
          },
        ));
  }

  Widget searchWidget() {
    return SearchAnchor(
        viewLeading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              'assets/trakt-logo.svg',
              width: 20,
              height: 20,
            )),
        builder: (context, controller) {
          return IconButton(
              onPressed: () {
                controller.openView();
              },
              icon: Icon(Icons.search_rounded));
        },
        suggestionsBuilder: (context, controller) async {
          _searchingWithQuery = controller.text;

          final List<json_search.Search> options = (await TraktJson.search(SearchType.show, _searchingWithQuery!)).toList();

          if (_searchingWithQuery != controller.text) {
            return _lastOptions;
          }

          List<Widget> options0 = [];
          for (var entry in options) {
            var artwork = (await TMDB.poster(entry.show!.ids!.tmdb != null ? entry.show!.ids!.tmdb! : "0").onError(
              (error, stackTrace) {
                return "https://i.ebayimg.com/images/g/ypkAAOSwnYphk0fJ/s-l400.jpg";
              },
            ));

            ExtendedShow show = (await TraktJson.extendedShowFromId(entry.show!.ids!.trakt!));
            WatchedProgress progress = (await TraktJson.watchedProgress(entry.show!.ids!.trakt!));

            Widget container;

            container = Container(
                padding: EdgeInsets.all(8),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        controller.closeView(entry.show!.title!);
                        var combinedShow = CombinedShow(show: Show.fromJson(show.toJson()), watchedProgress: progress);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowExpanded(combinedShow: combinedShow)));
                      });
                    },
                    child: Tooltip(
                        message: entry.show!.title!,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Ink(
                              height: 100,
                              width: 60,
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: NetworkImage(artwork), fit: BoxFit.cover), borderRadius: BorderRadius.circular(10))),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.show!.title!} (${entry.show!.year?.toString()})'),
                              Text(
                                show.genres!.join(', '),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ]))));

            options0.add(container);
          }

          _lastOptions = options0;

          return _lastOptions;
        });
  }
}
