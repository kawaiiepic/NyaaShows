import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../tmdb/tmdb.dart';
import '../../../trakt/json/enum/media_type.dart';
import '../../../trakt/json/sync/watched.dart';
import '../../../trakt/trakt_json.dart';
import '../../../utils/common.dart';
import 'show_expanded.dart';

class ExpandedNextUp extends StatelessWidget {
  const ExpandedNextUp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
        child: FutureBuilder(
          future: TraktJson.nextUp(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Watched> watchedShows = snapshot.data!;
              return GridView.count(
                mainAxisSpacing: 20,
                padding: EdgeInsets.all(16),
                crossAxisCount: 5,
                children: List.generate(watchedShows.length, (index) {
                  var watched = watchedShows[index];
                  return FutureBuilder(
                    future: TMDB.poster(MediaType.show, watched.show.ids!.tmdb!).onError((error, stackTrace) {
                      return Uint8List(0);
                    },),
                    builder: (context, posterData) {
                      if (posterData.hasData) {
                        var poster = posterData.data!;

                        return FutureBuilder(
                          future: TraktJson.watchedProgress(watched.show.ids!.trakt!).catchError((_) => print('Logging message failed')),
                          builder: (context, progressData) {
                            if (progressData.hasData) {
                              var progress = progressData.data!;

                              return Column(children: [Container(
                                alignment: Alignment.center,
                                constraints: BoxConstraints(minWidth: 120, minHeight: 150, maxWidth: 120, maxHeight: 150),
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
                                                        )),
                                              ),
                                          child: Ink(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(image: MemoryImage(poster), fit: BoxFit.cover),
                                                  borderRadius: BorderRadius.circular(18)),
                                              child: Tooltip(
                                                message: watched.show.title,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                    Tooltip(
                                                      message:
                                                          '${((progress.completed / progress.aired) * 100).round()}% watched\n${progress.completed}/${progress.aired} episodes\n${(progress.aired - progress.completed)} remaining',
                                                      child: LinearProgressIndicator(
                                                        minHeight: 8,
                                                        value: progress.completed / progress.aired,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              )))),
                                ),
                              ),

                              ]);
                            } else if (progressData.hasError) {
                              return Common.error();
                            } else {
                              return Common.loading();
                            }
                          },
                        );
                      } else if (posterData.hasError) {
                        return Common.error();
                      } else {
                        return Common.loading();
                      }
                    },
                  );
                }),
              );
            } else {
              return Common.loading();
            }
          },
        ),
      ),
    );
  }
}
