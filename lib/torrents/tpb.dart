import 'package:html_parser_plus/html_parser_plus.dart';
import 'package:http/http.dart' as http;
import 'package:nyaashows/torrents/helper.dart';

class ThePirateBay extends TorrentEngine {
  @override
  Future<List<TorrentFile>?> search(List<String> searchTerms) async {
    String url;
    List<TorrentFile> torrents = [];
    for (var term in searchTerms) {
      var url = 'https://1.piratebays.to/s/?q=$term';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var htmlString = response.body;
        final parser = HtmlParser();
        var node = parser.parse(htmlString);
        var parse = parser.queryNodes(node, '//tr');

        for (var p in parse) {
          var title = parser.query(p, '//td[2]/@align/@text|dart.replace(\n ,)').trim();
          var uploadedDate = parser.query(p, '//td[3]/@align/@text|dart.replace(\n ,)');
          int? size = int.tryParse(parser.query(p, '//td[5]/@align/@text|dart.replace(\n ,)').replaceAll(RegExp(r"\D"), ""));
          int? seeders = int.tryParse(parser.query(p, '//td[6]/@align/@text|dart.replace(\n ,)'));
          int? leechers = int.tryParse(parser.query(p, '//td[7]/@align/@text|dart.replace(\n ,)'));
          var uploader = parser.query(p, '//td[8]/@align/@text|dart.replace(\n ,)');
          var magnet = parser.query(p, '//td/nobr/a/@href');
          var torrentFile =
              TorrentFile(title: title, uploadedDate: uploadedDate, size: size, seeders: seeders, leechers: leechers, uploader: uploader, magnet: magnet);

          if (!torrents.contains(torrentFile)) {
            torrents.add(torrentFile);
          }
        }
      }
    }
    return torrents;
  }

  @override
  String name = "TPB";
}
