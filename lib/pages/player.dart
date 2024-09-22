import 'dart:async';

import 'package:discord_rpc/discord_rpc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/helper.dart';

class VideoPlayer extends StatefulWidget {
  final Media media;
  final TorrentEpisode torrentEpisode;

  const VideoPlayer({super.key, required this.media, required this.torrentEpisode});

  @override
  State<VideoPlayer> createState() => MyScreenState();
}

class MyScreenState extends State<VideoPlayer> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  Timer? timer;
  late DateTime discordStartPoc;
  late int discordEndPoc;

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    print(player.state.position);
    super.widget.media;
    player.open(super.widget.media);

    discordStartPoc = DateTime.now();

    NyaaShows.tvdb.showIcon(super.widget.torrentEpisode.tvdb).then((iconUrl) {

    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (player.state.playing) {
        discordEndPoc = discordStartPoc.add(player.state.duration).millisecondsSinceEpoch;
      }

      NyaaShows.discord.updatePresence(switch (player.state.playing) {
        false => DiscordPresence(
            state:
                'Watching 📺 ${super.widget.torrentEpisode.showName} (${super.widget.torrentEpisode.showYear}) ${super.widget.torrentEpisode.seasonId}x${super.widget.torrentEpisode.episodeId} ${super.widget.torrentEpisode.episodeName}',
            details: 'Paused',
            startTimeStamp: discordStartPoc.millisecondsSinceEpoch,
            endTimeStamp: discordEndPoc,
            largeImageKey: 'https://i.pinimg.com/736x/7d/49/4e/7d494e29437e63f67c910253ab002436.jpg',
            smallImageKey: 'play',
            smallImageText: 'Paused'
            // largeImageText: 'This text describes the large image.',
            // smallImageKey: 'browsing',
            // smallImageText: 'This text describes the small image.',
            ),
        true => DiscordPresence(
            state:
                'Watching 📺 ${super.widget.torrentEpisode.showName} (${super.widget.torrentEpisode.showYear}) ${super.widget.torrentEpisode.seasonId}x${super.widget.torrentEpisode.episodeId} ${super.widget.torrentEpisode.episodeName}',
            details:
                '[${player.state.position.inMinutes}:${player.state.position.inSeconds - (player.state.position.inMinutes * 60)}] - [${player.state.duration.inMinutes}:${player.state.duration.inSeconds - (player.state.duration.inMinutes * 60)}]',
            startTimeStamp: discordStartPoc.millisecondsSinceEpoch,
            endTimeStamp: discordEndPoc,
            largeImageKey: 'https://i.pinimg.com/736x/7d/49/4e/7d494e29437e63f67c910253ab002436.jpg',
            smallImageKey: 'pause',
            smallImageText: 'Playing'
            // largeImageText: 'This text describes the large image.',
            // smallImageKey: 'browsing',
            // smallImageText: 'This text describes the small image.',
            ),
      });
    });

    // player.stream.position.listen(
    //   (Duration position) {
    //     print('Position updated! ${position.inMinutes}');
    //     // setState(() {
    //     //   // Update UI.
    //     // });
    //   },
    // );
  }

  void setVideo(String url) {
    player.open(Media(url));
  }

  void getPosition() {
    print(player.state.position);
  }

  @override
  void dispose() {
    player.dispose();
    timer?.cancel();
    NyaaShows.discord.resetPresence();
    super.dispose();
  }

  MaterialDesktopCustomButton rewind() {
    return MaterialDesktopCustomButton(
        onPressed: () {
          player.seek(player.state.position - const Duration(seconds: 30));
        },
        icon: const Icon(Icons.fast_rewind_rounded));
  }

  MaterialDesktopCustomButton forward() {
    return MaterialDesktopCustomButton(
        onPressed: () {
          player.seek(player.state.position + const Duration(seconds: 30));
        },
        icon: const Icon(Icons.fast_forward_rounded));
  }

  MaterialDesktopVideoControlsThemeData controls() {
    return MaterialDesktopVideoControlsThemeData(
      // Modify theme options:
      seekBarThumbColor: Colors.pink.shade200,
      seekBarPositionColor: Colors.pink.shade200,
      controlsHoverDuration: const Duration(seconds: 5),
      // Modify top button bar:
      topButtonBar: [
        MaterialDesktopCustomButton(
          onPressed: () {
            player.stop();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${super.widget.torrentEpisode.showName} - S${super.widget.torrentEpisode.seasonId}:E${super.widget.torrentEpisode.episodeId}'),
                Text(
                  '${super.widget.torrentEpisode.episodeName} (${super.widget.torrentEpisode.episodeYear})', // (${super.widget.torrentEpisode.show.year})
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                )
              ],
            ))
        // MaterialDesktopCustomButton(
        //   onPressed: () {
        //     debugPrint('Custom "Settings" button pressed.');
        //   },
        //   icon: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //     Text(super.widget.torrentEpisode.showName),
        //     Text(super.widget.torrentEpisode.episodeName)
        //   ],),
        // ),
      ],
      // Modify bottom button bar:
      bottomButtonBar: [
        const MaterialDesktopSkipPreviousButton(),
        rewind(),
        const MaterialDesktopPlayOrPauseButton(),
        forward(),
        const MaterialDesktopSkipNextButton(),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        MaterialDesktopCustomButton(
            onPressed: () {
              getPosition();
            },
            icon: const Icon(Icons.closed_caption_sharp)),
        MaterialDesktopCustomButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        const MaterialDesktopFullscreenButton()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: controls(),
      fullscreen: controls(),
      child: Scaffold(
        body: Video(
          controller: controller,
        ),
      ),
    );
  }
}
