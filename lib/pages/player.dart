import 'dart:async';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
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
  late DateTime discordEndPoc;

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].

    super.widget.media;
    player.open(super.widget.media);

    discordStartPoc = DateTime.now();

    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      NyaaShows.tvdb.showIcon(super.widget.torrentEpisode.tvdb).then((var artwork) {
        NyaaShows.discord.updatePresence(switch (player.state.playing) {
          true => RPCActivity(
              activityType: ActivityType.watching,
              assets: RPCAssets(
                largeImage: artwork,
                largeText: super.widget.torrentEpisode.showName,
              ),
              buttons: [
                const RPCButton(label: "trakt", url: "https://trakt.tv"),
              ],
              details: '${super.widget.torrentEpisode.showName} (${super.widget.torrentEpisode.episodeYear})',
              state: '${super.widget.torrentEpisode.seasonId}x${super.widget.torrentEpisode.episodeId} ${super.widget.torrentEpisode.episodeName}',
              timestamps: RPCTimestamps(
                start: DateTime.now().subtract(player.state.position).millisecondsSinceEpoch,
                end: DateTime.now().add(player.state.duration).subtract(player.state.position).millisecondsSinceEpoch,
              ),
            ),
          false => RPCActivity(
              activityType: ActivityType.watching,
              assets: RPCAssets(
                largeImage: artwork,
                largeText: super.widget.torrentEpisode.showName,
              ),
              buttons: [
                const RPCButton(label: "trakt", url: "https://trakt.tv"),
              ],
              details: '⏸️ ${super.widget.torrentEpisode.showName} (${super.widget.torrentEpisode.showYear})',
              state: '${super.widget.torrentEpisode.seasonId}x${super.widget.torrentEpisode.episodeId} ${super.widget.torrentEpisode.episodeName}',
              timestamps: RPCTimestamps(
                start: DateTime.now().subtract(player.state.position).millisecondsSinceEpoch,
                end: DateTime.now().add(player.state.duration).subtract(player.state.position).millisecondsSinceEpoch,
              ),
            ),
        });
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

  Widget audioTrack() {
    return PopupMenuButton(
        icon: const Icon(Icons.audiotrack_rounded),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry> st = [];
          for (var subtitle in player.state.tracks.audio) {
            if (subtitle.language != null) {
              st.add(PopupMenuItem(
                  child: Text(subtitle.language!),
                  onTap: () {
                    player.setAudioTrack(subtitle);
                  }));
            }
          }

          return st;
        });
  }

  Widget subtitles() {
    return PopupMenuButton(
        icon: const Icon(Icons.closed_caption_rounded),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry> st = [];
          for (var subtitle in player.state.tracks.subtitle) {
            if (subtitle.title != null) {
              st.add(PopupMenuItem(child: Text(subtitle.title!), onTap: () {
                    player.setSubtitleTrack(subtitle);
                  }));
            }
          }

          return st;
        });
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
        audioTrack(),
        subtitles(),
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
