import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  final Media media;

  const VideoPlayer({super.key, required this.media});

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

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        // Modify theme options:
        seekBarThumbColor: Colors.pink.shade200,
        seekBarPositionColor: Colors.pink.shade200,
        toggleFullscreenOnDoublePress: false,
        // Modify top button bar:
        topButtonBar: [
          const Spacer(),
          MaterialDesktopCustomButton(
            onPressed: () {
              debugPrint('Custom "Settings" button pressed.');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        // Modify bottom button bar:
        bottomButtonBar: [
          const MaterialDesktopSkipPreviousButton(),
          const MaterialDesktopPlayOrPauseButton(),
          const MaterialDesktopSkipNextButton(),
          MaterialDesktopCustomButton(
              onPressed: () {
                player.stop();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.stop)),
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
