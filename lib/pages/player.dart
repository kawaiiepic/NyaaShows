import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key}) : super(key: key);
  @override
  State<VideoPlayer> createState() => PlayerState();
}

class PlayerState extends State<VideoPlayer> {
  // Create a [Player] to control playback.
  final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller =
      VideoController.create(player.handle, enableHardwareAcceleration: false);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].

    player.open(
        Media(
            'https://chi7-4.download.real-debrid.com/d/NR5LMICJI7KUS76/Criminal.Minds.S01E01.1080p.WEBRip.x265-KONTRAST.mp4'),
        play: false);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoController>(
        future: controller,
        builder: (context, snapshot) {
          Widget child;

          if (snapshot.hasData) {
            child = Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text('Title'),
                ),
                body: Center(
                  child: Video(controller: snapshot.data),
                ));
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
        });
  }
}
