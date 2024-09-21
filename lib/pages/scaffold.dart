import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/data/trakt/show.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/secondRoute.dart';

class MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  double containerHeight() {
    var height = MediaQuery.of(context).size.height;
    return 220;
  }

  double containerWidth() {
    var width = MediaQuery.of(context).size.width;
    return 150;
  }

  @override
  void initState() {
    super.initState();
    DataManager.traktData.setShows();
  }

  @override
  Widget build(BuildContext context) {
    var iconUrl;
    NyaaShows.trakt.userData().then((data) {
      iconUrl = data?.images.avatar;
    });

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                ),
                Tab(
                  icon: Icon(Icons.compass_calibration),
                ),
                Tab(
                  icon: Icon(Icons.calendar_month),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                ),
                child: PopupMenuButton(
                    padding: const EdgeInsets.all(0),
                    onSelected: (Menu menu) {
                      switch (menu) {
                        case Menu.settings:
                          break;
                        // TODO: Handle this case.
                        case Menu.trakt:
                          NyaaShows.trakt.auth(context);
                          break;
                        // TODO: Handle this case.
                        case Menu.about:
                          break;
                        // TODO: Handle this case.
                        case Menu.realdebrid:
                          NyaaShows.realDebrid.loginPopup(context);
                          break;
                        // TODO: Handle this case.
                      }
                    },
                    icon: FutureBuilder(
                        future: NyaaShows.trakt.userData(),
                        builder: (context, snapshot) {
                          Widget child;
                          if (snapshot.hasData) {
                            child = CircleAvatar(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(snapshot.data!.images.avatar.full),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            child = Icon(Icons.error);
                          } else {
                            child = Icon(Icons.person);
                          }
                          return child;
                        }),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                          const PopupMenuItem<Menu>(
                            value: Menu.settings,
                            child: ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Settings'),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<Menu>(
                            value: Menu.trakt,
                            child: ListTile(
                              leading: Icon(Icons.browser_updated_rounded),
                              title: Text('Connect Trakt'),
                            ),
                          ),
                          const PopupMenuItem<Menu>(
                            value: Menu.realdebrid,
                            child: ListTile(
                              leading: Icon(Icons.download),
                              title: Text('Connect Real-Debrid'),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<Menu>(
                            value: Menu.realdebrid,
                            child: ListTile(
                              leading: Icon(Icons.home_filled),
                              title: Text('Reload Home'),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<Menu>(
                            value: Menu.about,
                            child: ListTile(
                              leading: Icon(Icons.info_rounded),
                              title: Text('About'),
                            ),
                          ),
                        ]),
              )
            ],
          ),
          body: TabBarView(children: [
            Column(children: [
              Expanded(
                  child: ListView(children: [
                const Text("Next Up"),
                SizedBox(
                    height: 280,
                    child: FutureBuilder(
                      future: NyaaShows.trakt.nextUp(),
                      builder: (context, snapshot) {
                        Widget child;
                        if (snapshot.hasData) {
                          print(snapshot.data?.length);
                          child = ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: scrollController,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                var show = snapshot.data?[index];
                                int? tvdb = show?.show.ids.tvdb;

                                return FutureBuilder<Uint8List>(
                                  future: DataManager.tvdbData.retrieveArtwork(tvdb!),
                                  builder: (context, snapshot) {
                                    Widget tab = Container();
                                    if (snapshot.hasData) {
                                      var data = snapshot.data;
                                      if (data != null) {
                                        tab = Column(children: [
                                          Container(
                                            height: containerHeight(),
                                            width: containerWidth(),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: MemoryImage(data),
                                                fit: BoxFit.fill,
                                              ),
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.all(8),
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: show)),
                                                  );
                                                },
                                                child: Tooltip(
                                                    waitDuration: const Duration(seconds: 1),
                                                    message: show!.show.title,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(18),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Tooltip(
                                                              richMessage: TextSpan(text: '${((show.watchedProgress.completed / show.watchedProgress.aired) * 100).round()}% watched\n${show.watchedProgress.completed}/${show.watchedProgress.aired} episodes\n${(show.watchedProgress.aired - show.watchedProgress.completed)} remaining',  ),
                                                                child: LinearProgressIndicator(
                                                                minHeight: 8,
                                                                value: (show.watchedProgress.nextEpisode!.season * show.watchedProgress.nextEpisode!.number) /
                                                                    show.watchedProgress.aired,
                                                              ),

                                                        )],
                                                        )))),
                                          ),
                                          Text(
                                            'S${show.watchedProgress.nextEpisode!.season}:E${show.watchedProgress.nextEpisode!.number}',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            show.watchedProgress.nextEpisode!.title,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ]);
                                      }
                                    }

                                    return tab;
                                  },
                                );
                              });
                        } else if (snapshot.hasError) {
                          // TODO: Show error message.
                          child = const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          );
                        } else {
                          // TODO: Show loading icon.
                          child = const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Row(children: [
                          IconButton(
                              icon: const Icon(Icons.arrow_left_rounded),
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                scrollController.animateTo(scrollController.offset - 300, duration: const Duration(milliseconds: 800), curve: Curves.bounceIn);
                              }),
                          Expanded(child: child),
                          IconButton(
                              icon: const Icon(Icons.arrow_right_rounded),
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                scrollController.animateTo(scrollController.offset + 300, duration: const Duration(milliseconds: 800), curve: Curves.bounceOut);
                              })
                        ]);
                      },
                    )),
              ]))
            ]),

            // Container(child: ,)
            const Center(child: Text("Discover")),
            const Center(child: Text("Calendar")),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Search',
            child: const Icon(Icons.search),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}

class CardExample extends StatelessWidget {
  const CardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      // clipBehavior is necessary because, without it, the InkWell's animation
      // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
      // This comes with a small performance cost, and you should not set [clipBehavior]
      // unless you need it.
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          debugPrint('Card tapped.');
        },
        child: const SizedBox(
          width: 150,
          height: 200,
          child: Text(
            'A card that can be tapped',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}
