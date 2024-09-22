import 'package:nyaashows/main.dart';
import 'package:nyaashows/torrents/tpb.dart';

class TorrentHelper {
  static final List<TorrentEngine> _torrentEngines = [ThePirateBay()];

  static Future<List<TorrentFile>> search({required TorrentEpisode torrentEpisode}) async {
    List<TorrentFile> list = [];
    for (var torrentEngine in _torrentEngines) {
      await torrentEngine.search(torrentEpisode).then((torrentFiles) {
        if (torrentFiles != null) {
          for (var torrentFile in torrentFiles) {
            if (checkTorrent(torrentFile, torrentEpisode)) {
              // NyaaShows.log('Torrent Added: ${torrentFile.title}');
              list.add(torrentFile);
            }
          }
        }
      });
    }
    return list;
  }

  static String websiteSafeSearchTerm(String searchTerm) {
    var search = searchTerm.replaceAll(' ', '+');
    NyaaShows.log('Search: $search');
    return search;
  }

  static bool checkFile(String filePath, TorrentEpisode torrentEpisode) {
    bool fileExtension = _checkFileExtension(filePath);
    bool season = _checkSeason(filePath, torrentEpisode.seasonId);
    bool episode = _checkEpisode(filePath, torrentEpisode.episodeId);
    bool title = _checkTitle(filePath, torrentEpisode.showName);

    // NyaaShows.log('Path: ${filePath}, FileExtension: $fileExtension, Season: $season, Episode: $episode, title: $title');

    if (fileExtension && title && season && episode) {
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

    NyaaShows.log('Title: ${torrentFile.title}, Title: $title, Season: $season, Episode: $episode, Size: $size, Seeders: $seeders, Leechers: $leechers');

    // NyaaShows.log(
    //     'Torrent | Title: ${torrentFile.title}, Size: ${torrentFile.size}, Seeders: ${torrentFile.seeders}, Leeechers: ${torrentFile.leechers}, Upload Date: ${torrentFile.uploadedDate}');
    if (size && title && season && episode && seeders && leechers) {
      return true;
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
    return title.contains(RegExp('s([0]${seasonId}|${seasonId})', caseSensitive: false));
  }

  static bool _checkEpisode(String title, int episodeId) {
    return title.contains(RegExp('e([0]${episodeId}|${episodeId})', caseSensitive: false));
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

  TorrentFile(
      {required this.title,
      required this.uploadedDate,
      required this.size,
      required this.seeders,
      required this.leechers,
      required this.uploader,
      required this.magnet});
}

class TorrentEpisode {
  int seasonId;
  int episodeId;
  int showYear;
  int episodeYear;

  int tvdb;

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
      required this.tvdb});
}

abstract class TorrentEngine {
  Future<List<TorrentFile>?> search(TorrentEpisode torrentEpisode);
}
