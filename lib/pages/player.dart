import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:nyaashows/pages/episodes_page.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    print(player.state.position);
    super.widget.media;
    player.open(super.widget.media);
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

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        // Modify theme options:
        seekBarThumbColor: Colors.pink.shade200,
        seekBarPositionColor: Colors.pink.shade200,
        toggleFullscreenOnDoublePress: false,
        playAndPauseOnTap: false,
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
                    '${super.widget.torrentEpisode.episodeName}', // (${super.widget.torrentEpisode.show.year})
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
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(),
      child: Scaffold(
        body: Video(
          controller: controller,
        ),
      ),
    );
  }
}
