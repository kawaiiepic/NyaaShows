import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../trakt/json/combined_show.dart';
import '../../../trakt/json/shows/show.dart';
import '../../../trakt/json/shows/watched_progress.dart';
import '../../../trakt/trakt_json.dart';
import '../../../utils/common.dart';
import 'episodes.dart';

class ShowExpanded extends StatelessWidget {
  const ShowExpanded({super.key, this.watchedProgress, required this.show});

  // final CombinedShow combinedShow;
  final WatchedProgress? watchedProgress;
  final Show show;

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
            if(watchedProgress != null){
              return Column(
                children: [
                  const Text('Next Up:'),
                  TextButton(
                      onPressed: () {
                        
                      },
                      child: Text(
                          'S${watchedProgress!.nextEpisode?.season}:E${watchedProgress!.nextEpisode?.number} - ${watchedProgress!.nextEpisode?.title}')),
                  const Text('Seasons:'),
                  Expanded(child: listBuilder(seasons))
                ],
              );
            } else {
              return Column(
                children: [
                  const Text('Seasons:'),
                  Expanded(child: listBuilder(seasons))
                ],
              );
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
