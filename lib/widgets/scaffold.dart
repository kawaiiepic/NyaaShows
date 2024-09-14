import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/pages/secondRoute.dart';
import 'package:nyaashows/trakt.dart';

class MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  double containerHeight() {
    var height = MediaQuery.of(context).size.height;
    return 280;
  }

  double containerWidth() {
    var width = MediaQuery.of(context).size.width;
    return 180;
  }

  @override
  void initState() {
    super.initState();
    DataManager.traktData.setShows();
  }

  @override
  Widget build(BuildContext context) {
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
            actions: <Widget>[
              PopupMenuButton<Menu>(
                  onSelected: (Menu menu) {
                    switch (menu) {
                      case Menu.settings:
                        break;
                      // TODO: Handle this case.
                      case Menu.trakt:
                        NyaaShows.traktModel.auth(context);
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
                  icon: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.0),
                    child: CircleAvatar(child: Icon(Icons.account_circle)),
                  ),
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
                        const PopupMenuItem<Menu>(
                          value: Menu.about,
                          child: ListTile(
                            leading: Icon(Icons.info_rounded),
                            title: Text('About'),
                          ),
                        ),
                      ]),
            ],
          ),
          body: TabBarView(children: [
            Column(children: [
              Expanded(
                  child: ListView(children: [
                const Text("Continue Watching"),
                SizedBox(
                    height: containerHeight(),
                    child: FutureBuilder<List<Show>>(
                      future: DataManager.traktData.showData,
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
                                var container;

                                return FutureBuilder<Uint8List>(
                                  future: DataManager.tvdbData
                                      .retrieveArtwork(tvdb!),
                                  builder: (context, snapshot) {
                                    Widget tab = Container();
                                    if (snapshot.hasData) {
                                      // Image? image = snapshot.data![tvdb];
                                      var data = snapshot.data;
                                      // print('Data: $data');
                                      if (data != null) {
                                        // NetworkI
                                        tab = Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: MemoryImage(data),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.all(8),
                                          width: containerWidth(),
                                          child: InkWell(
                                              onTap: () {
                                                print("Clicked!");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SecondRoute(
                                                              show: show!)),
                                                );
                                              },
                                              child: Tooltip(
                                                  message:
                                                      '${show?.show.title}',
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        218,
                                                                        252,
                                                                        228,
                                                                        236),
                                                                    child: Text(
                                                                      '${show?.show.title}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ))
                                                              ]),
                                                          LinearProgressIndicator(
                                                            minHeight: 8,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            value: 0.5,
                                                            semanticsLabel:
                                                                'Linear progress indicator',
                                                          )
                                                        ],
                                                      )))),
                                          // child: Image(
                                          //   fit: BoxFit.contain,
                                          //   image: NetworkImage(url),
                                          // ), // Text(title)
                                        );
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
                                scrollController.animateTo(
                                    scrollController.offset - 800,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeIn);
                              }),
                          Expanded(child: child),
                          IconButton(
                              icon: const Icon(Icons.arrow_right_rounded),
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                scrollController.animateTo(
                                    scrollController.offset + 800,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeIn);
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
