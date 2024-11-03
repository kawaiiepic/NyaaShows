import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nyaashows/data/trakt/profile.dart';
import 'package:nyaashows/data/trakt/search/show.dart' as Search;
import 'package:nyaashows/data/trakt/watched.dart';
import 'package:nyaashows/data/trakt/watched_progress.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/secondRoute.dart';
import 'package:nyaashows/trakt/trakt.dart';
import 'package:nyaashows/utils/utils.dart';

import '../data/trakt/show.dart';

class MyHomePageState extends State<MyHomePage> {
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

          final List<Search.SearchShow> options = (await NyaaShows.trakt.search(SearchType.show, _searchingWithQuery!)).toList();

          if (_searchingWithQuery != controller.text) {
            return _lastOptions;
          }

          List<Widget> options0 = [];
          for (var entry in options) {
            var artwork = (await NyaaShows.tmdb.poster(entry.show!.ids!.tmdb != null ? entry.show!.ids!.tmdb! : 0).onError(
              (error, stackTrace) {
                return "https://i.ebayimg.com/images/g/ypkAAOSwnYphk0fJ/s-l400.jpg";
              },
            ));

            Show? show = (await NyaaShows.trakt.show(entry.show!.ids!.trakt));
            WatchedProgress? progress = (await NyaaShows.trakt.watchedProgress(entry.show!.ids!.trakt));

            Widget container;

            if (show != null) {
              container = Container(
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          controller.closeView(entry.show!.title!);
                          var combinedShow = CombinedShow(show: show, watchedProgress: progress);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: combinedShow)));
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
                                Text(show.genres!.join(', '), maxLines: 3, overflow: TextOverflow.ellipsis,),
                              ],
                            )
                          ]))));

              options0.add(container);
            }
          }

          _lastOptions = options0;

          return _lastOptions;
        });
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
    NyaaShows.trakt.userData().then((data) {
      iconUrl = data?.images.avatar;
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
                      future: NyaaShows.trakt.accessToken(),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          return FutureBuilder(
                              future: NyaaShows.trakt.nextUp(),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  final List<CombinedShow> combinedShows = snap.data!;
                                  double titleFontSize = ((MediaQuery.of(context).size.height * 0.1) * 0.11);
                                  double episodeTitleFontSize = ((MediaQuery.of(context).size.height * 0.1) * 0.1);
                                  List<Widget> containers = [];
                                  var index = 0;
                                  combinedShows.forEach(
                                    (element) async {
                                      final CombinedShow combinedShow = combinedShows[index];
                                      index++;

                                      var widget = FutureBuilder(
                                        future: NyaaShows.tvdb.artwork(combinedShow.show.ids!.tvdb!),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var artwork = snapshot.data!;

                                            return Column(children: [
                                              Container(
                                                constraints: BoxConstraints(minWidth: 80, minHeight: 130),
                                                height: MediaQuery.of(context).size.height * 0.2,
                                                width: MediaQuery.of(context).size.width * 0.075,
                                                // alignment: Alignment.center,
                                                // margin: const EdgeInsets.all(8),
                                                child: Material(
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => SecondRoute(combinedShow: combinedShow)),
                                                          );
                                                        },
                                                        child: Ink(
                                                          decoration: BoxDecoration(
                                                              image: DecorationImage(image: MemoryImage(artwork), fit: BoxFit.fill),
                                                              borderRadius: BorderRadius.circular(18)),
                                                          child: Tooltip(
                                                            message: combinedShow.show.title,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                Tooltip(
                                                                  message:
                                                                      '${((combinedShow.watchedProgress.completed / combinedShow.watchedProgress.aired) * 100).round()}% watched\n${combinedShow.watchedProgress.completed}/${combinedShow.watchedProgress.aired} episodes\n${(combinedShow.watchedProgress.aired - combinedShow.watchedProgress.completed)} remaining',
                                                                  child: LinearProgressIndicator(
                                                                    minHeight: 8,
                                                                    value: combinedShow.watchedProgress.completed / combinedShow.watchedProgress.aired,
                                                                  ),
                                                                ),
                                                              ]),
                                                            ),
                                                          ),
                                                        ))),
                                              ),
                                              Text(
                                                'S${combinedShow.watchedProgress.nextEpisode!.season}:E${combinedShow.watchedProgress.nextEpisode!.number}',
                                                textAlign: TextAlign.center,
                                                textHeightBehavior: TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                                              ),
                                              Tooltip(
                                                  message: combinedShow.watchedProgress.nextEpisode!.title,
                                                  child: Container(
                                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.075),
                                                    child: Text(
                                                      combinedShow.watchedProgress.nextEpisode!.title,
                                                      textAlign: TextAlign.center,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: episodeTitleFontSize),
                                                    ),
                                                  ))
                                            ]);
                                          } else if (snapshot.hasError) {
                                            return Utils.error();
                                          } else {
                                            return Utils.loading();
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
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [

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
                                      ), Icon(Icons.book, size: 50),
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
                                  return Utils.error();
                                } else {
                                  return Utils.loading();
                                }
                              });
                        } else if (snap.hasError) {
                          NyaaShows.trakt.auth(context).then((value) {
                            if (value) {
                              setState(() {});
                            }
                          });
                          return const Text("Trakt-connection is required to use this app.");
                        } else {
                          return Utils.loading();
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
