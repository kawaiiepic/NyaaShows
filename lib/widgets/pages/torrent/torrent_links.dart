import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:nyaashows/utils/exceptions.dart';

import '../../../real-debrid/json/torrent_info.dart';
import '../../../real-debrid/real_debrid.dart';
import '../../../torrents/helper.dart';
import '../../../utils/common.dart';
import '../player/movie_player.dart';
import '../player/show_player.dart';
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
                                            var id = await _addMagnet(torrentFile.magnet);
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
                                                playTorrent(id, super.widget.torrentEpisode!);
                                              } else {
                                                playMovie(id, super.widget.torrentMovie!);
                                              }
                                            }
                                          } else {
                                            RealDebrid.login(context);
                                          }
                                        },
                                        onLongPress: () {
                                          print('Long Press');
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
                                                text: ' ${torrentFile.provider}', style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color: color))
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

  Future<String> _addMagnet(String magnet) async {
    print('Adding magnet!!');
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final Uri url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/addMagnet');
      Response response = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'magnet': magnet});

      switch (response.statusCode) {
        case 201:
          {
            // Success.
            final Map<String, dynamic> json = jsonDecode(response.body);
            final String id = json['id'];
            return id;
          }
        case 401:
          {
            RealDebrid.refreshToken();
            return _addMagnet(magnet);
          }
        default:
          {
            print(response.body);
            return Future.error(UnknownStatusCode());
          }
      }
    } else {
      return Future.error(MissingRealDebridAccessToken());
    }
  }

  Future<void> _removeTorrents() async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();
      for (var id in _magnetIds.values) {
        final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/delete/$id');
        var response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

        print(response.statusCode);
      }
    }
  }

  Future<void> _selectFiles(String id, TorrentEpisode torrentEpisode, {int overrideId = -1}) async {
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
                if (TorrentHelper.checkFile(file.path, torrentEpisode)) {
                  ids.add(file.id);
                  print(file.id);
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

            var downloadIds = await _instantAvailable(torrentInfo.hash, downloadsId).onError(
              (error, stackTrace) => downloadsId.toString(),
            );

            currentFileId = downloadIds.split(',').indexOf(downloadsId.toString());

            final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
            var post = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': downloadIds});

            print(downloadIds);
          }
        default:
          return Future.error(Exception('Unknown Status Code'));
      }
    } else {
      return Future.error(Exception('Missing Access Token'));
    }
  }

  Future<void> playTorrent(String id, TorrentEpisode torrentEpisode) async {
    await _magnetDownload(id, torrentEpisode);
  }

  Future<void> playMovie(String id, TorrentMovie torrentMovie) async {
    await _magnetDownloadMovie(id, torrentMovie);
  }

  Future<void> _magnetDownload(String id, TorrentEpisode torrentEpisode) async {
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
              case 'queued':
                {
                  print('Still downloading...');
                  await Future.doWhile(() async {
                    var newResponse = await http.get(url, headers: {'Authorization': 'Bearer $token'});
                    final TorrentInfo responseInfo = torrentInfoFromJson(newResponse.body);
                    switch (newResponse.statusCode) {
                      case 200:
                        {
                          switch (responseInfo.status) {
                            case 'downloading':
                              {
                                print(responseInfo.progress);
                              }
                            case 'downloaded':
                              {
                                unrestrickLink(link: responseInfo.links[currentFileId], context: context, torrentEpisode: torrentEpisode);
                                return false;
                              }
                            case 'uploading':
                              {}
                            default:
                              {
                                print(responseInfo.status);
                              }
                          }
                        }
                    }

                    await Future.delayed(Duration(seconds: 5));
                    return true;
                  });
                }
              case 'waiting_files_selection':
                {
                  _selectFiles(id, torrentEpisode).then(
                    (_) {
                      _magnetDownload(id, torrentEpisode);
                    },
                  ).onError(
                    (error, stackTrace) {
                      print(error);
                    },
                  );
                }
              case 'downloaded':
                {
                  print(torrentInfo.links);
                  try {
                    unrestrickLink(link: torrentInfo.links[currentFileId], context: context, torrentEpisode: torrentEpisode);
                  } catch (e) {
                    showPlatformDialog(
                      context: context,
                      builder: (context) => PlatformAlertDialog(
                        title: Text('Torrent error'),
                        content: Text('Link missing.'),
                      ),
                    );
                  }
                }
            }
          }
      }
    }
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
                  ).onError(
                    (error, stackTrace) {
                      print(error);
                    },
                  );
                }
              case 'downloaded':
                {
                  print(torrentInfo.links);
                  unrestrickLink(link: torrentInfo.links[currentFileId], context: context, torrentMovie: torrentMovie);
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
                  print(file.id);
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

            var downloadIds = await _instantAvailable(torrentInfo.hash, downloadsId).onError(
              (error, stackTrace) => downloadsId.toString(),
            );

            currentFileId = downloadIds.split(',').indexOf(downloadsId.toString());

            final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
            var post = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': downloadIds});

            print(downloadIds);
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

  Future<String> _instantAvailable(String hash, int id) async {
    var token = await RealDebrid.accessToken();
    final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/instantAvailability/$hash');
    var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    Map<String, dynamic> json = jsonDecode(response.body)[hash];

    var list = json['rd'] as List;
    for (Map<String, dynamic> files in list) {
      if (files.containsKey('$id')) {
        return files.keys.join(',');
      }
    }

    return Future.error(Exception('No instant downloads found!'));
  }

  Future<Map<String, dynamic>?> unrestrickLink(
      {required String link, required BuildContext context, TorrentEpisode? torrentEpisode, TorrentMovie? torrentMovie}) async {
    RealDebrid.accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'link': link});

      if (post.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(post.body);
        print(json);
        String video = json["download"];

        if (torrentEpisode != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShowPlayer(
                        media: Media(video),
                        torrentEpisode: torrentEpisode,
                      )));
        } else if (torrentMovie != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MoviePlayer(
                        media: Media(video),
                        torrentMovie: torrentMovie,
                      )));
        }
        return json;
      }
    });

    return null;
  }
}
