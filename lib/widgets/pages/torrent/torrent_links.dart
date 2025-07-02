import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;

import '../../../real-debrid/json/torrent_info.dart';
import '../../../real-debrid/real_debrid.dart';
import '../../../torrents/helper.dart';
import '../../../utils/common.dart';
import 'select_file.dart';

class TorrentLinks extends StatefulWidget {
  const TorrentLinks({super.key, this.torrentEpisode, this.torrentMovie});

  final TorrentEpisode? torrentEpisode;
  final TorrentMovie? torrentMovie;

  @override
  State createState() => TorrentLinksState();
}

class TorrentLinksState extends State<TorrentLinks> {
  Timer? timer;
  late Future<List<TorrentFile>> _searchResults;
  final Map<String, String> _magnetIds = {};
  double progress = 0.0;
  bool _seachOverridden = false;
  int currentFileId = 0;
  late var _alertSetState;

  @override
  void initState() {
    super.initState();
    if (super.widget.torrentEpisode != null) {
      _searchResults = TorrentHelper.searchShow(torrentEpisode: super.widget.torrentEpisode!);
    } else {
      _searchResults = TorrentHelper.searchMovie(torrentMovie: super.widget.torrentMovie!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: super.widget.torrentEpisode != null
                ? Text('${super.widget.torrentEpisode!.showName} S${super.widget.torrentEpisode!.seasonId}:E${super.widget.torrentEpisode!.episodeId}')
                : Text('')),
        body: FutureBuilder<List<TorrentFile>>(
            future: _searchResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  var children = [
                    snapshot.data!.isEmpty
                        ? Text("No torrents found.")
                        : Expanded(
                            child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final torrentFile = snapshot.data![index];
                                  var color = torrentFile.seeders! >= 10 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary;

                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    child: TextButton(
                                        onPressed: () async {
                                          if (await RealDebrid.hasAccessToken()) {
                                            var id = await TorrentHelper.addMagnet(await torrentFile.obtainMagnet());
                                            if (_seachOverridden) {
                                              var files = await _getFiles(id);
                                              // if (files != null) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SelectFile(id: id, files: files, torrentEpisode: super.widget.torrentEpisode!),
                                                  ));
                                              // }
                                            } else {
                                              progress = 0;
                                              if (super.widget.torrentEpisode != null) {
                                                TorrentHelper.playTorrent(id, super.widget.torrentEpisode!);
                                              } else {
                                                playMovie(id, super.widget.torrentMovie!);
                                              }
                                            }
                                          } else {
                                            RealDebrid.login(context);
                                          }
                                        },
                                        onLongPress: () {
                                          showMenu(context: context, position: RelativeRect.fill, items: [
                                            PopupMenuItem(
                                              child: Text('Boop'),
                                            )
                                          ]);
                                        },
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(text: torrentFile.title, style: Theme.of(context).primaryTextTheme.labelMedium?.copyWith(color: color)),
                                            TextSpan(text: '\n'),
                                            WidgetSpan(child: Icon(Icons.people_alt, size: 12, color: color), style: TextStyle(color: color)),
                                            TextSpan(
                                                text: ' ${torrentFile.seeders}', style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color: color)),
                                            TextSpan(text: '  '),
                                            WidgetSpan(child: Icon(Icons.sd_storage, size: 12, color: color), style: TextStyle(color: color)),
                                            TextSpan(
                                                text: ' ${Common.getFileSizeString(bytes: torrentFile.size!)}',
                                                style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color: color)),
                                            TextSpan(text: '  '),
                                            WidgetSpan(child: Icon(Icons.settings, size: 12, color: color), style: TextStyle(color: color)),
                                            TextSpan(
                                                text: ' ${torrentFile.provider.name}',
                                                style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color: color))
                                          ]),
                                        )),
                                  );
                                })),
                    Center(
                        child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (!_seachOverridden) {
                            _searchResults = super.widget.torrentEpisode != null
                                ? TorrentHelper.searchShow(torrentEpisode: super.widget.torrentEpisode!, searchEverything: true)
                                : TorrentHelper.searchMovie(torrentMovie: super.widget.torrentMovie!);
                          } else {
                            _searchResults = super.widget.torrentEpisode != null
                                ? TorrentHelper.searchShow(torrentEpisode: super.widget.torrentEpisode!, searchEverything: false)
                                : TorrentHelper.searchMovie(torrentMovie: super.widget.torrentMovie!);
                          }
                          _seachOverridden = !_seachOverridden;
                        });
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => OverriddenTorrents(torrentEpisode: super.widget.torrentEpisode)));
                      },
                      child: Text(_seachOverridden ? 'Normal Search' : 'Override Search'),
                    ))
                  ];
                  return Column(children: children);
                } else {
                  return Common.error();
                }
              } else {
                return Common.loading();
              }
            }));
  }

  Future<void> playMovie(String id, TorrentMovie torrentMovie) async {
    await _magnetDownloadMovie(id, torrentMovie);
  }



  Future<void> _magnetDownloadMovie(String id, TorrentMovie torrentMovie) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      switch (response.statusCode) {
        case 200:
          {
            final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);
            log(torrentInfo.status);
            log(torrentInfo.progress.toString());

            switch (torrentInfo.status) {
              case 'waiting_files_selection':
                {
                  _selectFilesMovie(id, torrentMovie).then(
                    (_) {
                      _magnetDownloadMovie(id, torrentMovie);
                    },
                  );
                }
              case 'downloaded':
                {
                  TorrentHelper.unrestrickLink(link: torrentInfo.links[currentFileId], context: context, torrentMovie: torrentMovie);
                }
            }
          }
      }
    }
  }

  Future<void> _selectFilesMovie(String id, TorrentMovie torrentMovie, {int overrideId = -1}) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      switch (response.statusCode) {
        case 200:
          {
            final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);

            var downloadsId = overrideId;
            if (overrideId == -1) {
              List<int> ids = [];

              for (var file in torrentInfo.files) {
                if (TorrentHelper.checkMovie(file.path, torrentMovie)) {
                  ids.add(file.id);
                }
              }

              if (ids.isNotEmpty) {
                downloadsId = ids[0];
              } else {
                if (context.mounted) {
                  showPlatformDialog(
                    context: context,
                    builder: (context) => PlatformAlertDialog(
                      title: Text('Torrent error'),
                      content: Text('Episode not found.'),
                    ),
                  );
                }
                return Future.error(Exception('No Files found that match the episode'));
              }
            }

            var downloadIds = await TorrentHelper.instantAvailable(torrentInfo.hash, downloadsId).onError(
              (error, stackTrace) => downloadsId.toString(),
            );

            currentFileId = downloadIds.split(',').indexOf(downloadsId.toString());

            final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
            var post = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': downloadIds});
          }
        default:
          return Future.error(Exception('Unknown Status Code'));
      }
    } else {
      return Future.error(Exception('Missing Access Token'));
    }
  }

  Future<List<FileElement>> _getFiles(String id) async {
    var token = await RealDebrid.accessToken();
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
    var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    switch (response.statusCode) {
      case 200:
        {
          final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);
          return torrentInfo.files;
        }
      default:
        return Future.error(Exception('Unknown Status Code'));
    }
  }




}
