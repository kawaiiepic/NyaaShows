import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../torrents/helper.dart';
import '../../../trakt/json/movies/extended_movie.dart';
import '../torrent/torrent_links.dart';

class MovieExpanded extends StatelessWidget {
  const MovieExpanded({super.key, required this.movie});

  final ExtendedMovie movie;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
          child: Column(children: [
            PlatformText('${movie.title} (${movie.year})'),
            PlatformText(movie.tagline ?? movie.tagline!),
            PlatformText(movie.overview),
            PlatformText(movie.country ?? movie.country!),
            PlatformText(movie.trailer),
            PlatformText(movie.rating.toString()),
            PlatformText(movie.certification != null? movie.certification! : ''),
            PlatformTextButton(child: PlatformText('Play'), onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TorrentLinks(
                                              torrentMovie:  TorrentMovie(movieName: movie.title, movieYear: movie.year!, ids: movie.ids)))),)
          ],)
    ));
  }
}
