import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyaashows/pages/player.dart';
import 'package:nyaashows/trakt.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Center(
          child: Column(
        children: [
          Text(show.lastWatchedAt.toString()),
          Text(show.plays.toString()),
          Text(show.seasons.length.toString()),
          Text(show.show.title),
          Text(show.show.year.toString()),
          Text(show.show.ids.toString()),
          ElevatedButton(
            onPressed: () {
              Process.run("mpv", ['https://chi1-4.download.real-debrid.com/d/OYSU4N3ENQCDE85/%5BAnime%20Time%5D%20Nanatsu%20no%20Taizai%20-%20Seisen%20no%20Shirushi%20-%2002.mkv']);
            },
            child: const Text('Play'),
          )
        ],
      )),
    );
  }
}
