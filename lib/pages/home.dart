import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nyaashows/tmdb/tmdb.dart';
import 'package:nyaashows/trakt/json/enum/search_type.dart';
import 'package:nyaashows/trakt/json/shows/extended_show.dart';
import 'package:nyaashows/trakt/trakt.dart';
import 'package:nyaashows/utils/common.dart';
import 'package:nyaashows/widgets/main/main.dart';
import 'package:nyaashows/widgets/pages/shows/show_expanded.dart';

import '../real-debrid/real_debrid.dart';
import '../trakt/json/enum/media_type.dart';
import '../trakt/json/shows/watched_progress.dart';
import '../trakt/json/sync/watched.dart';
import '../trakt/json/users/extended_profile.dart';
import '../tvdb/tvdb.dart';
import 'menu.dart';

class MyHomePageState extends State<Home> {
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];

  @override
  void initState() {
    super.initState();
  }

  Widget search() {
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

          final options = (await Trakt.search([SearchType.show], _searchingWithQuery!)).toList();

          if (_searchingWithQuery != controller.text) {
            return _lastOptions;
          }

          List<Widget> options0 = [];
          for (var entry in options) {
            var artwork = (await TMDB.poster(MediaType.show, entry.show!.ids.tmdb != null ? entry.show!.ids.tmdb! : ""));

            ExtendedShow? show = (await Trakt.extendedShowFromId(entry.show!.ids.trakt!));
            WatchedProgress? progress = (await Trakt.watchedProgress(entry.show!.ids.trakt!));

            Widget container;

            container = Container(
                padding: EdgeInsets.all(8),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        controller.closeView(entry.show!.title);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowExpanded(show: show)));
                      });
                    },
                    child: Tooltip(
                        message: entry.show!.title,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Ink(
                              height: 100,
                              width: 60,
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.cover), borderRadius: BorderRadius.circular(10))),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.show!.title} (${entry.show!.year?.toString()})'),
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

  AppBar appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text("Home"),
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
          child: Row(
            children: [
              search(),
              SizedBox(width: 20),
              PopupMenuButton(
                  padding: const EdgeInsets.all(0),
                  onSelected: (Menu menu) {
                    switch (menu) {
                      case Menu.settings:
                        break;
                      case Menu.trakt:
                        Trakt.auth(context);
                        break;
                      case Menu.about:
                        break;
                      case Menu.realdebrid:
                        RealDebrid.login(context);
                        break;
                    }
                  },
                  icon: FutureBuilder(
                      future: Trakt.userProfile(),
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
                          child = const Icon(Icons.person_remove);
                        } else {
                          child = const Icon(Icons.person);
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
                      ])
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Avatar? iconUrl;
    Trakt.userProfile().then((data) {
      iconUrl = data.images.avatar;
    });

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: appBar(),
          body: TabBarView(children: [
            Padding(
                padding: EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Next Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                      future: Trakt.accessToken(),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          return FutureBuilder(
                              future: Trakt.nextUp(),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  final List<Watched> watchedList = snap.data!;
                                  double titleFontSize = ((MediaQuery.of(context).size.height * 0.1) * 0.11);
                                  double episodeTitleFontSize = ((MediaQuery.of(context).size.height * 0.1) * 0.1);
                                  List<Widget> containers = [];
                                  var index = 0;
                                  watchedList.forEach(
                                    (element) async {
                                      final Watched watched = watchedList[index];
                                      index++;

                                      var widget = FutureBuilder(
                                        future: TVDB.artwork(MediaType.show, watched.show.ids!.tvdb!),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var artwork = snapshot.data!;

                                            return FutureBuilder(
                                              future: Trakt.watchedProgress(watched.show.ids!.trakt!),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  var watchedProgress = snapshot.data!;

                                                  return Column(children: [
                                                    Container(
                                                      constraints: BoxConstraints(minWidth: 80, minHeight: 130),
                                                      height: MediaQuery.of(context).size.height * 0.2,
                                                      width: MediaQuery.of(context).size.width * 0.075,
                                                      child: Material(
                                                          child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => ShowExpanded(show: watched.show)),
                                                                );
                                                              },
                                                              child: Ink(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.fill),
                                                                    borderRadius: BorderRadius.circular(18)),
                                                                child: Tooltip(
                                                                  message: watched.show.title,
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(16),
                                                                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                      Text("Gay")
                                                                      // Tooltip(
                                                                      //   message:
                                                                      //       '${((watchedProgress.completed / watchedProgress.aired) * 100).round()}% watched\n${watchedProgress.completed}/${watchedProgress.aired} episodes\n${(watchedProgress.aired - watchedProgress.completed)} remaining',
                                                                      //   child: LinearProgressIndicator(
                                                                      //     minHeight: 8,
                                                                      //     value: watchedProgress.completed / watchedProgress.aired,
                                                                      //   ),
                                                                      // ),
                                                                    ]),
                                                                  ),
                                                                ),
                                                              ))),
                                                    ),
                                                    Text(
                                                      'S${watchedProgress.nextEpisode!.season}:E${watchedProgress.nextEpisode!.number}',
                                                      textAlign: TextAlign.center,
                                                      textHeightBehavior: TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even),
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                                                    ),
                                                    Tooltip(
                                                        message: watchedProgress.nextEpisode!.title,
                                                        child: Container(
                                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.075),
                                                          child: Text(
                                                            watchedProgress.nextEpisode!.title!,
                                                            textAlign: TextAlign.center,
                                                            maxLines: 3,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: episodeTitleFontSize),
                                                          ),
                                                        ))
                                                  ]);
                                                } else if (snapshot.hasError) {
                                                  return Common.error();
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
                                        SizedBox(width: 20),
                                      );
                                    },
                                  );

                                  containers.add(
                                    Column(children: [
                                      Stack(alignment: Alignment.center, children: [
                                        Container(
                                          constraints: BoxConstraints(minWidth: 80, minHeight: 130),
                                          height: MediaQuery.of(context).size.height * 0.2,
                                          width: MediaQuery.of(context).size.width * 0.075,
                                          // alignment: Alignment.center,
                                          // margin: const EdgeInsets.all(8),
                                          child: Material(
                                              child: InkWell(
                                                  onTap: () {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: combinedShow)),
                                                    // );
                                                  },
                                                  child: Ink(
                                                    decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(18)),
                                                    child: Tooltip(
                                                      message: 'View More',
                                                    ),
                                                  ))),
                                        ),
                                        Icon(Icons.book, size: 50),
                                      ]),
                                      Text('View all')
                                    ]),
                                  );

                                  return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: containers,
                                      ));
                                } else if (snap.hasError) {
                                  return Common.error();
                                } else {
                                  return Common.loading();
                                }
                              });
                        } else if (snap.hasError) {
                          Trakt.auth(context).then((value) {
                            setState(() {});
                          });
                          return const Text("Trakt-connection is required to use this app.");
                        } else {
                          return Common.loading();
                        }
                      }),
                  Text(
                    'Next Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ])),
            const Column(),
            const Column()
          ]),
        ));
  }
}
