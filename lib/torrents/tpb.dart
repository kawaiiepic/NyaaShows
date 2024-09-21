import 'package:html_parser_plus/html_parser_plus.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/pages/episodes_page.dart';

class ThePirateBay {
  static Future<List<TPB>> torrent({tvshows = true, required TorrentEpisode torrentEpisode}) async {
    final response = await http.get(Uri.parse('https://1.piratebays.to/s/?q=${torrentEpisode.showName.replaceAll(' ', '+')}'));

    if (response.statusCode == 200) {
      var htmlString = response.body;
      final parser = HtmlParser();
      var node = parser.parse(htmlString);

      var parse = parser.queryNodes(node, '//tr');
      print(torrentEpisode.showName.replaceAll(' ', '+'));

      List<TPB> torrents = [];
      for (var p in parse) {
        var type = parser.query(p, '//td[1]/@align/@text|dart.replace(\n ,)');
        var title = parser.query(p, '//td[2]/@align/@text|dart.replace(\n ,)');
        var uploadedDate = parser.query(p, '//td[3]/@align/@text|dart.replace(\n ,)');
        var size = parser.query(p, '//td[5]/@align/@text|dart.replace(\n ,)');
        var seeders = parser.query(p, '//td[6]/@align/@text|dart.replace(\n ,)');
        var leechers = parser.query(p, '//td[7]/@align/@text|dart.replace(\n ,)');
        var uploader = parser.query(p, '//td[8]/@align/@text|dart.replace(\n ,)');
        var magnet = parser.query(p, '//td/nobr/a/@href');
        var tpb = TPB(title: title, uploadedDate: uploadedDate, size: size, seeders: seeders, leechers: leechers, uploader: uploader, magnet: magnet);
        // print('Title: $title | Type: $type');
        if (tvshows) {
          torrents.add(tpb);
        } else if (!tvshows && type.contains('Movies')) {
          torrents.add(tpb);
        }
        // return tpb;
      }
      return torrents;
    } else {
      throw Exception();
    }
  }
}

class TPB {
  String title;
  String uploadedDate;
  String size;
  String seeders;
  String leechers;
  String uploader;
  String magnet;

  TPB(
      {required this.title,
      required this.uploadedDate,
      required this.size,
      required this.seeders,
      required this.leechers,
      required this.uploader,
      required this.magnet});
}
