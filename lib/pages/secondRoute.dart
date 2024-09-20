import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/data/trakt/progress.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/data/trakt/all_seasons.dart' as all_seasons;
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/episodes_page.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(show.show.title),
        ),
        body: FutureBuilder<TraktProgress?>(
            future: DataManager.traktData.showProgress(show.show.ids.trakt),
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                final id = show.show.ids.trakt;
                Widget child2;
                child = FutureBuilder<List<all_seasons.Season>?>(
                  future: NyaaShows.trakt.seasonsFromId(id: id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final seasons = snapshot.data!;
                      child2 = ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: seasons.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 50,
                            child: Center(
                                child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EpisodesPage(show: show.show.ids.trakt!, season: seasons[index],),));
                              },
                              child: Text(seasons[index].title),
                            )),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      child2 = const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                      );
                    } else {
                      child2 = const Center(
                          child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ));
                    }

                    return child2;
                  },
                );
              } else if (snapshot.hasError) {
                child = const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                child = const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }

              return child;
            }));
  }
}
