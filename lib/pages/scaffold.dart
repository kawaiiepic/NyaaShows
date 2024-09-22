import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/secondRoute.dart';
import 'package:nyaashows/trakt/trakt.dart';

class MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  @override
  void initState() {
    super.initState();
    DataManager.traktData.setShows();
  }

  AppBar appBar() {
    return AppBar(
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
    );
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
          appBar: appBar(),
          body: TabBarView(children: [
            Column(children: [
              Text('Test'),
              FutureBuilder(
                  future: NyaaShows.trakt.nextUp(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      final List<CombinedShow> combinedShows = snap.data!;
                      return Expanded(
                          child: Row(children: [
                        Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                controller: scrollController,
                                itemCount: combinedShows.length,
                                itemBuilder: (_, index) {
                                  final CombinedShow combinedShow = combinedShows[index];
                                  if (combinedShow.show.ids.tvdb != null) {
                                    return FutureBuilder(
                                      future: NyaaShows.tvdb.artwork(combinedShow.show.ids.tvdb!),
                                      builder: (_, snapshot) {
                                        return Text(snapshot.data!.toString());
                                      },
                                    );
                                    // return FutureBuilder(
                                    //     future: NyaaShows.tvdb.artwork(combinedShow.show.ids.tvdb!),
                                    //     builder: (_, snapshot) {
                                    //       print(snapshot.data!);
                                    //       if (snapshot.hasData) {
                                    //         Uint8List artwork = snapshot.data!;

                                    //         return Column(children: [
                                    //           Container(
                                    //               height: 220,
                                    //               width: 150,
                                    //               decoration: BoxDecoration(
                                    //                 image: DecorationImage(
                                    //                   image: MemoryImage(artwork),
                                    //                   fit: BoxFit.fill,
                                    //                 ),
                                    //                 borderRadius: BorderRadius.circular(18),
                                    //               ),
                                    //               alignment: Alignment.center,
                                    //               margin: const EdgeInsets.all(8),
                                    //               child: InkWell(
                                    //                   onTap: () {
                                    //                     Navigator.push(
                                    //                       context,
                                    //                       MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: combinedShow)),
                                    //                     );
                                    //                   },
                                    //                   child: Tooltip(
                                    //                       message: combinedShow.show.title,
                                    //                       child: ClipRRect(
                                    //                         borderRadius: BorderRadius.circular(18),
                                    //                         child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    //                           Tooltip(
                                    //                             message:
                                    //                                 '${((combinedShow.watchedProgress.completed / combinedShow.watchedProgress.aired) * 100).round()}% watched\n${combinedShow.watchedProgress.completed}/${combinedShow.watchedProgress.aired} episodes\n${(combinedShow.watchedProgress.aired - combinedShow.watchedProgress.completed)} remaining',
                                    //                             child: LinearProgressIndicator(
                                    //                               minHeight: 8,
                                    //                               value: (combinedShow.watchedProgress.nextEpisode!.season *
                                    //                                       combinedShow.watchedProgress.nextEpisode!.number) /
                                    //                                   combinedShow.watchedProgress.aired,
                                    //                             ),
                                    //                           )
                                    //                         ]),
                                    //                       )))),
                                    //           Text(
                                    //             'S${combinedShow.watchedProgress.nextEpisode!.season}:E${combinedShow.watchedProgress.nextEpisode!.number}',
                                    //             textAlign: TextAlign.center,
                                    //             overflow: TextOverflow.ellipsis,
                                    //             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    //           ),
                                    //           Text(
                                    //             combinedShow.watchedProgress.nextEpisode!.title,
                                    //             textAlign: TextAlign.center,
                                    //             overflow: TextOverflow.ellipsis,
                                    //             style: const TextStyle(fontSize: 10),
                                    //           ),
                                    //         ]);
                                    //       } else {
                                    //         return Text('error');
                                    //         return const Icon(
                                    //           Icons.error_outline,
                                    //           color: Colors.red,
                                    //           size: 60,
                                    //         );
                                    //       }
                                    //     });
                                  } else {
                                    return const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 60,
                                    );
                                  }
                                })),
                      ]));
                    } else if (snap.hasError) {
                      return const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      );
                    } else {
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ]),
            Column(),
            Column()
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Search',
            child: const Icon(Icons.search),
          ),
        ));
  }
}
