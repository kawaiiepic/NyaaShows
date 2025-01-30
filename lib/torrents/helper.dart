<<<<<<< HEAD
import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/torrent_galaxy.dart';
=======
import '../main.dart';
import '../trakt/json/utils/ids.dart';
import 'torrent_galaxy.dart';
>>>>>>> bacc27a54346025c68eaffba2bb6d99a806c96ac

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
        torrentFiles = await torrentEngine.search([(websiteSafeSearchTerm(torrentEpisode.showName))]);
      } else {
        torrentFiles = await torrentEngine.search([
          "${websiteSafeSearchTerm(torrentEpisode.showName)} S${prettifyNumber(torrentEpisode.seasonId)}E${prettifyNumber(torrentEpisode.episodeId)}",
          "${websiteSafeSearchTerm(torrentEpisode.showName)} S${prettifyNumber(torrentEpisode.seasonId)}",
          '${websiteSafeSearchTerm(torrentEpisode.showName)} season ${prettifyNumber(torrentEpisode.seasonId)}',
          websiteSafeSearchTerm(torrentEpisode.showName)
        ]);
        torrentFiles = await torrentEngine.search([
          (websiteSafeSearchTerm(torrentEpisode.showName)),
        ]);
      }
      if (torrentFiles != null) {
        for (var torrentFile in torrentFiles) {
          torrentFile.provider = torrentEngine.name;
          NyaaShows.log('Torrent Added: ${torrentFile.title}');
          if (searchEverything) {
            list.add(torrentFile);
          } else {
            list.add(torrentFile);
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
      torrentFiles = await torrentEngine.search([(websiteSafeSearchTerm(torrentMovie.movieName))], movie: true);
      if (torrentFiles != null) {
        for (var torrentFile in torrentFiles) {
          torrentFile.provider = torrentEngine.name;
          NyaaShows.log('Torrent Added: ${torrentFile.title}');
          list.add(torrentFile);
        }
      }
    }

    list.sort((a, b) => b.seeders!.compareTo(a.seeders!));

    return list;
  }

  static String prettifyNumber(int number) {
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  static String websiteSafeSearchTerm(String searchTerm) {
    var search = searchTerm.replaceAll('-', ' ').replaceAll(':', ' ');
    NyaaShows.log('Search: $search');
    return search;
  }

  static bool checkFile(String filePath, TorrentEpisode torrentEpisode) {
    bool fileExtension = _checkFileExtension(filePath);
    bool season = _checkSeason(filePath, torrentEpisode.seasonId);
    bool episode = _checkEpisode(filePath, torrentEpisode.episodeId);
    bool title = _checkTitle(filePath, torrentEpisode.showName);

    // NyaaShows.log('Path: ${filePath}, FileExtension: $fileExtension, Season: $season, Episode: $episode, title: $title');

    print('Checking File: $filePath | $season $episode');
    if (fileExtension && title && season && episode) {
      print('checkFile: $filePath');
      return true;
    } else {
      return false;
    }
  }

  static bool checkMovie(String filePath, TorrentMovie torrentMovie) {
    bool fileExtension = _checkFileExtension(filePath);
    bool title = _checkTitle(filePath, torrentMovie.movieName);

    // NyaaShows.log('Path: ${filePath}, FileExtension: $fileExtension, Season: $season, Episode: $episode, title: $title');

    print('Checking File: $filePath | $title $fileExtension');
    if (fileExtension && title) {
      print('checkFile: $filePath');
      return true;
    } else {
      return false;
    }
  }

  static bool checkTorrent(TorrentFile torrentFile, TorrentEpisode torrentEpisode) {
    bool size = _checkSize(torrentFile.size);
    bool seeders = _checkSeeders(torrentFile.seeders);
    bool leechers = _checkLeechers(torrentFile.leechers);
    bool season = _checkSeason(torrentFile.title, torrentEpisode.seasonId);
    bool episode = _checkEpisode(torrentFile.title, torrentEpisode.episodeId);
    bool title = _checkTitle(torrentFile.title, torrentEpisode.showName);

    NyaaShows.log(
        'Title: ${torrentFile.title}, Title: $title, Season: $season, Episode: $episode, Size: $size + ${torrentFile.size}, Seeders: $seeders, Leechers: $leechers');

    // NyaaShows.log(
    //     'Torrent | Title: ${torrentFile.title}, Size: ${torrentFile.size}, Seeders: ${torrentFile.seeders}, Leeechers: ${torrentFile.leechers}, Upload Date: ${torrentFile.uploadedDate}');
    if (size && title && season) {
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
    return (size != null && size >= 200);
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

  static bool _checkEpisode(String title, int episodeId) {
    if (title.contains('E$episodeId') || title.contains('E00$episodeId') || title.contains('E0$episodeId')) {
      return true;
    } else {
      return false;
    }
  }

  static bool _checkFileExtension(String filePath) {
    return filePath.contains(RegExp(r'^.*\.(mp4|mkv|wmv|avi)$'));
  }
}

class TorrentFile {
  String title;
  String uploadedDate;
  int? size;
  int? seeders;
  int? leechers;
  String uploader;
  String magnet;
  String provider = "";

  TorrentFile(
      {required this.title,
      required this.uploadedDate,
      required this.size,
      required this.seeders,
      required this.leechers,
      required this.uploader,
      required this.magnet});
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
  Future<List<TorrentFile>?> search(List<String> searchTerms, {movie = false});
}
