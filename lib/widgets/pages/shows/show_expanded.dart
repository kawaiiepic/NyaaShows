import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../trakt/json/combined_show.dart';
import '../../../trakt/trakt_json.dart';
import '../../../utils/common.dart';
import 'episodes.dart';

class ShowExpanded extends StatelessWidget {
  const ShowExpanded({super.key, required this.combinedShow});

  final CombinedShow combinedShow;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
          child: FutureBuilder(
        future: TraktJson.seasonsFromId(combinedShow.show.ids!.trakt),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final seasons = snapshot.data;
            return Column(
              children: [
                const Text('Next Up:'),
                TextButton(
                    onPressed: () {},
                    child: Text(
                        'S${combinedShow.watchedProgress.nextEpisode?.season}:E${combinedShow.watchedProgress.nextEpisode?.number} - ${combinedShow.watchedProgress.nextEpisode?.title}')),
                const Text('Seasons:'),
                Expanded(child: listBuilder(seasons))
              ],
            );
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
}
