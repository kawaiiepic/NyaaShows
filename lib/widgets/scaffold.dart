import 'package:flutter/material.dart';
import 'package:nyaashows/main.dart';

class MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      // TODO: Handle this case.
                      case Menu.trakt:
                        NyaaShows.traktModel.auth(context);
                      // TODO: Handle this case.
                      case Menu.about:
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
                Container(
                    height: 200,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.center,
                    color: Colors.red.shade200,
                    child: const Text("Item 1")),
                const Text("Continue Watching"),
                SizedBox(
                    height: 200,
                    child: Row(children: [
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
                      Expanded(
                          child: ListenableBuilder(
                              listenable: NyaaShows.traktModel,
                              builder: (context, widget) {
                                return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    controller: scrollController,
                                    itemCount:
                                        NyaaShows.traktModel.histories.length,
                                    itemBuilder: (context, index) {
                                      var history = NyaaShows
                                          .traktModel.histories
                                          .elementAt(index);
                                      var title = history.show.entries
                                          .elementAt(0)
                                          .value;

                                      return Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(8),
                                        color: Colors.pink.shade50,
                                        width: 400,
                                        child: Text(title),
                                      );
                                    });
                              })),
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
                    ])),
                const Text("Up Next"),
                SizedBox(
                    height: 300,
                    child: Row(children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_left_rounded),
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            scrollController1.animateTo(
                                scrollController1.offset - 800,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeIn);
                          }),
                      Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: scrollController1,
                              itemCount: 50,
                              itemBuilder: (context, index) {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(8),
                                  color: Colors.pink.shade50,
                                  width: 200,
                                  child: Text('${index + 1}'),
                                );
                              })),
                      IconButton(
                          icon: const Icon(Icons.arrow_right_rounded),
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            scrollController1.animateTo(
                                scrollController1.offset + 800,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeIn);
                          })
                    ])),
                Container(
                    height: 200,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.center,
                    color: Colors.red.shade200,
                    child: const Text("Item 2")),
                Container(
                    height: 200,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.center,
                    color: Colors.red.shade200,
                    child: const Text("Item 3"))
              ]))
            ]),

            // Container(child: ,)
            const Center(child: Text("Discover")),
            const Center(child: Text("Calendar")),
          ]),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _incrementCounter,
          //   tooltip: 'Increment',
          //   child: const Icon(Icons.add),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
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
