import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/torrent_galaxy.dart';
import '../real-debrid/json/torrent_info.dart';
import '../real-debrid/real_debrid.dart';
import '../trakt/json/utils/ids.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document;
import 'package:http/http.dart' as http;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/exceptions.dart';
import '../widgets/pages/player/movie_player.dart';
import '../widgets/pages/player/show_player.dart';

enum TorrentProviders {
  TorrentGalaxy('TorrentGalaxy');

  const TorrentProviders(this.name);

  final String name;
}

class TorrentHelper {
  static final List<TorrentEngine> _torrentEngines = [
    // ThePirateBay(),
    TorrentGalaxy()
  ];

  static Future<List<TorrentFile>> searchShow({required TorrentEpisode torrentEpisode, searchEverything = false}) async {
    List<TorrentFile> list = [];
    for (var torrentEngine in _torrentEngines) {
      List<TorrentFile>? torrentFiles;
      if (searchEverything) {
        torrentFiles = await torrentEngine.search((websiteSafeSearchTerm(torrentEpisode.showName)));
      } else {
        torrentFiles = await torrentEngine.search(websiteSafeSearchTerm(torrentEpisode.showName));
      }
      if (torrentFiles != null) {
        for (var torrentFile in torrentFiles) {
          if (searchEverything) {
            list.add(torrentFile);
          } else {
            if (checkTorrent(torrentFile, torrentEpisode)) {
              NyaaShows.log('Torrent Added: ${torrentFile.title}');
              list.add(torrentFile);
            }
          }
        }
      }
    }

    list.sort((a, b) => b.seeders!.compareTo(a.seeders!));

    return list;
  }

  static Future<List<TorrentFile>> searchMovie({required TorrentMovie torrentMovie}) async {
    List<TorrentFile> list = [];
    for (var torrentEngine in _torrentEngines) {
      List<TorrentFile>? torrentFiles;
      torrentFiles = await torrentEngine.search((websiteSafeSearchTerm(torrentMovie.movieName)), movie: true);
      if (torrentFiles != null) {
        for (var torrentFile in torrentFiles) {
          NyaaShows.log('Torrent Added: ${torrentFile.title}');
          list.add(torrentFile);
        }
      }
    }

    list.sort((a, b) => b.seeders!.compareTo(a.seeders!));

    return list;
  }

  static Future<void> quickPlay(TorrentEpisode episode) async {
    var statusMessage = "Searching for Episode...";
    StateSetter? _setState;

    showPlatformDialog(
      context: NyaaShows.navigatorKey.currentContext!,
      builder: (context) => PlatformAlertDialog(
        title: Text('Playing ${episode.episodeName}'),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return Text(statusMessage);
        }),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );

    var torrentSearch = await TorrentHelper.searchShow(torrentEpisode: episode);
    var searchIndex = 0;
    if (torrentSearch.isEmpty) {
      _setState!(() {
        statusMessage = "No Torrents Found.";
      });
      return;
    }
    _setState!(() {
      statusMessage = "Obtaining Magnet Link... \n${torrentSearch[searchIndex].title}";
    });
    var magnet = await torrentSearch[searchIndex].obtainMagnet();
    _setState!(() {
      statusMessage = "Adding Magnet to Debrid... \n${torrentSearch[searchIndex].title}";
    });
    var id = await TorrentHelper.addMagnet(magnet);

    _setState!(() {
      statusMessage = "Selecting Files...";
    });
    TorrentHelper._magnetDownload(id, episode);

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var download = false;

    await Future.doWhile(() async {
      try {
        var torrentInfo = await TorrentHelper._torrentInfo(id);
        switch (torrentInfo.status) {
          case 'downloading':
            {
              if (((DateTime.now().millisecondsSinceEpoch - startTime) ~/ Duration.millisecondsPerSecond) > (download ? 120 : 5)) {
                TorrentHelper._removeTorrent(id);
                if (torrentSearch.length <= ++searchIndex) {
                  searchIndex = 0;
                  print("None of the torrents are cached. Trying to download torrents instead.");
                  download = true;
                  return true;
                }

                if (download) {
                  print("Downloading for more than 2 minutes...");
                } else {
                  print("Downloading for more than 5 seconds...");
                  print('Seeders:${torrentInfo.seeders}');
                }
                _setState!(() {
                  statusMessage = "Failed to Download Torrent...\nTrying Another...";
                });
                startTime = DateTime.now().millisecondsSinceEpoch;

                _setState!(() {
                  statusMessage = "Obtaining Magnet Link... \n${torrentSearch[searchIndex].title}";
                });
                var magnet = await torrentSearch[searchIndex].obtainMagnet();
                if (magnet == null) {
                  return true;
                }
                _setState!(() {
                  statusMessage = "Adding Magnet to Debrid... \n${torrentSearch[searchIndex].title}";
                });
                id = await TorrentHelper.addMagnet(magnet);
                _setState!(() {
                  statusMessage = "Selecting Files...";
                });
                TorrentHelper._magnetDownload(id, episode);
              }

              if(download){
              var progress = torrentInfo.progress;
              _setState!(() {
                statusMessage = "Downloading... $progress%";
              });
            } else {
               _setState!(() {
                  statusMessage = "Checking if cached...";
                });
            }
              await Future.delayed(Duration(seconds: 2));
              return true;
            }
          case 'downloaded':
            {
              _setState!(() {
                statusMessage = "Downloaded...";
              });
              unrestrickLink(link: torrentInfo.links[0], context: NyaaShows.navigatorKey.currentContext!, torrentEpisode: episode);
              return false;
            }
        }
      } catch (e) {
        return true;
      }
      return true;
    });
  }

  static Future<String> addMagnet(String magnet) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final Uri url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/addMagnet');
      Response response = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'magnet': magnet});

      switch (response.statusCode) {
        case 201:
          {
            final Map<String, dynamic> json = jsonDecode(response.body);
            final String id = json['id'];
            return id;
          }
        case 401:
          {
            RealDebrid.refreshToken();
            return addMagnet(magnet);
          }
        case 403:
          {
            RealDebrid.expiredPremium();
            return Future.error(Exception('Expired Premium'));
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

  static Future<void> playTorrent(String id, TorrentEpisode torrentEpisode) async {
    await _magnetDownload(id, torrentEpisode);
  }

  static Future<TorrentInfo> _torrentInfo(String id) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final TorrentInfo responseInfo = torrentInfoFromJson(response.body);
        return responseInfo;
      } else {
        throw ('Bad Status Code');
      }
    } else {
      throw (MissingRealDebridAccessToken());
    }
  }

  static Future<void> _magnetDownload(String id, TorrentEpisode torrentEpisode, {int fileId = 0}) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();

      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/info/$id');
      var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      switch (response.statusCode) {
        case 200:
          {
            final TorrentInfo torrentInfo = torrentInfoFromJson(response.body);
            NyaaShows.log(torrentInfo.status);
            NyaaShows.log(torrentInfo.progress.toString());

            switch (torrentInfo.status) {
              case 'waiting_files_selection':
                {
                  await _selectFiles(id, torrentEpisode);
                }
              case 'downloaded':
                {
                  try {
                    unrestrickLink(link: torrentInfo.links[fileId], context: NyaaShows.navigatorKey.currentContext!, torrentEpisode: torrentEpisode);
                  } catch (e) {
                    showPlatformDialog(
                      context: NyaaShows.navigatorKey.currentContext!,
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

  static Future<int> _selectFiles(String id, TorrentEpisode torrentEpisode, {int overrideId = -1}) async {
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
                }
              }

              if (ids.isNotEmpty) {
                downloadsId = ids[0];
              } else {
                showPlatformDialog(
                  context: NyaaShows.navigatorKey.currentContext!,
                  builder: (context) => PlatformAlertDialog(
                    title: Text('Torrent error'),
                    content: Text('Episode not found.'),
                  ),
                );

                return Future.error(Exception('No Files found that match the episode'));
              }
            }

            var downloadIds = await instantAvailable(torrentInfo.hash, downloadsId).onError(
              (error, stackTrace) => downloadsId.toString(),
            );

            final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/selectFiles/$id');
            var post = await http.post(url, headers: {'Authorization': 'Bearer $token'}, body: {'files': downloadIds});

            return downloadIds.split(',').indexOf(downloadsId.toString());
          }
        default:
          return Future.error(Exception('Unknown Status Code'));
      }
    } else {
      return Future.error(Exception('Missing Access Token'));
    }
  }

  static Future<String> instantAvailable(String hash, int id) async {
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

  static Future<void> _removeTorrent(String id) async {
    if (await RealDebrid.hasAccessToken()) {
      final String token = await RealDebrid.accessToken();
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/torrents/delete/$id');
      var response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

      print(response.statusCode);
    }
  }

  static Future<Map<String, dynamic>?> unrestrickLink(
      {required String link, required BuildContext context, TorrentEpisode? torrentEpisode, TorrentMovie? torrentMovie}) async {
    RealDebrid.accessToken().then((value) async {
      final url = Uri.https('api.real-debrid.com', '/rest/1.0/unrestrict/link');
      var post = await http.post(url, headers: {'Authorization': 'Bearer $value'}, body: {'link': link});

      if (post.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(post.body);
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

  static String prettifyNumber(int number) {
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  static int convertSizeToMB(String sizeText) {
    var sized = 0;
    if (sizeText.contains("GB")) {
      var sizeTrimmed = sizeText.replaceAll('GB', '');
      sized = (double.parse(sizeTrimmed) * 1000.0).toInt();
    } else {
      sized = (double.parse(sizeText.replaceAll('MB', ''))).toInt();
    }
    return sized;
  }

  static String websiteSafeSearchTerm(String searchTerm) {
    var search = searchTerm.replaceAll('-', ' ').replaceAll(':', ' ');
    NyaaShows.log('Search: $search');
    return search;
  }

  static bool checkFile(String filePath, TorrentEpisode torrentEpisode) {
    bool fileExtension = _checkFileExtension(filePath);
    // bool season = _checkSeason(filePath, torrentEpisode.seasonId);
    bool episode = _checkEpisode(filePath, torrentEpisode.seasonId, torrentEpisode.episodeId);
    bool title = _checkTitle(filePath, torrentEpisode.showName);

    // NyaaShows.log('Path: ${filePath}, FileExtension: $fileExtension, Season: $season, Episode: $episode, title: $title');

    if (fileExtension && title && episode) {
      return true;
    } else {
      return false;
    }
  }

  static bool checkMovie(String filePath, TorrentMovie torrentMovie) {
    bool fileExtension = _checkFileExtension(filePath);
    bool title = _checkTitle(filePath, torrentMovie.movieName);

    if (fileExtension && title) {
      return true;
    } else {
      return false;
    }
  }

  static bool checkTorrent(TorrentFile torrentFile, TorrentEpisode torrentEpisode) {
    bool size = _checkSize(torrentFile.size);
    bool seeders = _checkSeeders(torrentFile.seeders);
    bool leechers = _checkLeechers(torrentFile.leechers);
    bool episode = _checkEpisode(torrentFile.title, torrentEpisode.seasonId, torrentEpisode.episodeId);
    bool title = _checkTitle(torrentFile.title, torrentEpisode.showName);

    NyaaShows.log('Title: ${torrentFile.title}, Title: $title, Episode: $episode, Size: $size + ${torrentFile.size}, Seeders: $seeders, Leechers: $leechers');

    // NyaaShows.log(
    //     'Torrent | Title: ${torrentFile.title}, Size: ${torrentFile.size}, Seeders: ${torrentFile.seeders}, Leeechers: ${torrentFile.leechers}, Upload Date: ${torrentFile.uploadedDate}');
    if (size && title && episode) {
      // seeders && leechers
      if (torrentFile.size! >= 1200) {
        return true;
      } else if (episode) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static bool _checkSize(int? size) {
    return (size != null && size >= 100);
  }

  static bool _checkSeeders(int? seeders) {
    return (seeders != null && seeders >= 3);
  }

  static bool _checkLeechers(int? leechers) {
    return (leechers != null && leechers >= 1);
  }

  static bool _checkTitle(String title, String showName) {
    var s = title.split(' ');
    bool contains = true;
    for (var name in s) {
      if (!title.contains(name)) contains = false;
    }
    return contains;
  }

  static bool _checkSeason(String title, int seasonId) {
    if (seasonId < 10) {
      return title.contains('0$seasonId');
    } else {
      return title.contains('$seasonId');
    }
  }

  static bool _checkEpisode(String title, int seasonId, int episodeId) {
    return RegExp(r'S([0]?' + seasonId.toString() + r')(E([0]?' + episodeId.toString() + r')|.COMPLETE)\b', caseSensitive: false).hasMatch(title);
  }

  static bool _checkFileExtension(String filePath) {
    return (RegExp(r'.(mp4|mkv|wmv|avi)').hasMatch(filePath));
  }
}

class TorrentFile {
  TorrentProviders provider;
  String title;
  int? size;
  int? seeders;
  int? leechers;
  String uploader;
  String href;

  obtainMagnet() async {
    switch (provider) {
      case TorrentProviders.TorrentGalaxy:
        {
          final response = await http.get(Uri.parse(href));

          if (response.statusCode == 200) {
            Document document = parse(response.body);

            return document.querySelectorAll('[role=button]')[1].attributes["href"];
          }
        }
    }
  }

  TorrentFile(
      {required this.provider,
      required this.title,
      required this.uploader,
      required this.seeders,
      required this.leechers,
      required this.size,
      required this.href});
}

class TorrentMovie {
  int movieYear;
  String movieName;
  Ids ids;

  TorrentMovie({required this.movieName, required this.movieYear, required this.ids});
}

class TorrentEpisode {
  int seasonId;
  int episodeId;
  int showYear;
  int episodeYear;

  Ids episodeIds;
  Ids showIds;

  String showName;
  String episodeName;
  String seasonName;

  TorrentEpisode(
      {required this.showName,
      required this.seasonId,
      required this.episodeId,
      required this.episodeName,
      required this.seasonName,
      required this.showYear,
      required this.episodeYear,
      required this.episodeIds,
      required this.showIds});
}

abstract class TorrentEngine {
  abstract String name;
  Future<List<TorrentFile>?> search(String searchTerm, {movie = false});
}
