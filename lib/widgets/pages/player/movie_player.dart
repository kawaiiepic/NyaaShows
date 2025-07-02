import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../torrents/helper.dart';
import '../../../trakt/json/enum/media_type.dart';
import '../../../trakt/trakt.dart';

class MoviePlayer extends StatefulWidget {
  final Media media;
  final TorrentMovie torrentMovie;
  final double progress = 0;

  const MoviePlayer({super.key, required this.media, required this.torrentMovie});

  @override
  State<MoviePlayer> createState() => MyScreenState();
}

class MyScreenState extends State<MoviePlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  Timer? timer;
  late DateTime discordStartPoc;
  late DateTime discordEndPoc;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].

    super.widget.media;
    player.open(super.widget.media);
    Trakt.startWatching(MediaType.movie, {
      "progress": super.widget.progress,
      "movie": {
        "ids": {"trakt": super.widget.torrentMovie.ids.trakt}
      }
    });

    discordStartPoc = DateTime.now();

    // TMDB.posterUrl(MediaType.movie, super.widget.torrentMovie.ids.tmdb!).then((var artwork) {
    //   timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
    //     Discord.updatePresence(switch (player.state.playing) {
    //       true => RPCActivity(
    //           activityType: ActivityType.watching,
    //           assets: RPCAssets(
    //             largeImage: artwork,
    //             largeText: super.widget.torrentMovie.movieName,
    //           ),
    //           buttons: [
    //             RPCButton(
    //                 label: "trakt",
    //                 url:
    //                     "https://trakt.tv/movies/${super.widget.torrentMovie.ids.trakt}"),
    //           ],
    //           details: '${super.widget.torrentMovie.movieName} (${super.widget.torrentMovie.movieYear})',
    //           // state: '',
    //           timestamps: RPCTimestamps(
    //             start: DateTime.now().subtract(player.state.position).millisecondsSinceEpoch,
    //             end: DateTime.now().add(player.state.duration).subtract(player.state.position).millisecondsSinceEpoch,
    //           ),
    //         ),
    //       false => RPCActivity(
    //           activityType: ActivityType.watching,
    //           assets: RPCAssets(
    //             largeImage: artwork,
    //             largeText: super.widget.torrentMovie.movieName,
    //           ),
    //           buttons: [
    //             RPCButton(
    //                 label: "trakt",
    //                 url:
    //                     "https://trakt.tv/movies/${super.widget.torrentMovie.ids.trakt}"),
    //           ],
    //           details: '⏸️ ${super.widget.torrentMovie.movieName} (${super.widget.torrentMovie.movieYear})',
    //           // state: '${super.widget.torrentEpisode!.seasonId}x${super.widget.torrentEpisode!.episodeId} ${super.widget.torrentEpisode!.episodeName}',
    //           timestamps: RPCTimestamps(
    //             start: DateTime.now().subtract(player.state.position).millisecondsSinceEpoch,
    //             end: DateTime.now().add(player.state.duration).subtract(player.state.position).millisecondsSinceEpoch,
    //           ),
    //         ),
    //     });
    //   });
    // });

    player.stream.playing.listen(
      (event) {
        if (event) {
          Trakt.startWatching(MediaType.movie, {
            "progress": progressPercentage(),
            "episode": {
              "ids": {"trakt": super.widget.torrentMovie.ids.trakt}
            }
          });
        } else {
          Trakt.pauseWatching(MediaType.movie, {
            "progress": progressPercentage(),
            "episode": {
              "ids": {"trakt": super.widget.torrentMovie.ids.trakt}
            }
          });
        }
      },
    );

    player.stream.position.listen(
      (Duration position) {
        if (player.state.position.inSeconds / player.state.duration.inSeconds >= 0.8 && !finished) {
          finished = !finished;

          Trakt.stopWatching(MediaType.movie, 100, super.widget.torrentMovie.ids.trakt!);
        }
      },
    );
  }

  int progressPercentage() {
    var progress = ((player.state.position.inSeconds / player.state.duration.inSeconds) * 100).toStringAsFixed(2);
    if (progress == "NaN" || progress == "Infinity") {
      return 0;
    } else {
      return double.parse(progress).round();
    }
  }

  void setVideo(String url) {
    player.open(Media(url));
  }

  @override
  void dispose() {
    if (!finished) {
      Trakt.stopWatching(MediaType.movie, 0.0, super.widget.torrentMovie.ids.trakt!);
    }
    player.dispose();
    timer?.cancel();
    super.dispose();
  }

  MaterialDesktopCustomButton rewind() {
    return MaterialDesktopCustomButton(
        onPressed: () {
          if ((player.state.position - const Duration(seconds: 30)).isNegative) {
            player.seek(Duration());
          } else {
            player.seek(player.state.position - const Duration(seconds: 30));
          }
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
              st.add(PopupMenuItem(
                  child: Text(subtitle.title!),
                  onTap: () {
                    player.setSubtitleTrack(subtitle);
                  }));
            }
          }

          return st;
        });
  }

  MaterialDesktopVideoControlsThemeData controls() {
    return MaterialDesktopVideoControlsThemeData(
      controlsTransitionDuration: Duration(seconds: 1),
      visibleOnMount: true,
      playAndPauseOnTap: false,
      // Modify theme options:
      seekBarThumbColor: Colors.pink.shade200,
      seekBarPositionColor: Colors.pink.shade200,
      controlsHoverDuration: const Duration(seconds: 5),
      primaryButtonBar: [MaterialPlayOrPauseButton(iconSize: 36.0)],
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
              children: [PlatformText('${super.widget.torrentMovie.movieName} (${super.widget.torrentMovie.movieYear})')],
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
          controls: Theme.of(context).platform == TargetPlatform.iOS ? CupertinoVideoControls : MaterialDesktopVideoControls,
        ),
      ),
    );
  }
}
