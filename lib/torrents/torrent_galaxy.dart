import 'package:nyaashows/torrents/helper.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

class TorrentGalaxy extends TorrentEngine {
  @override
  String name = "TorrentGalaxy";

  @override
  Future<List<TorrentFile>?> search(String searchTerm, {movie = false}) async {
    String url;
    List<TorrentFile> torrents = [];
    if (movie) {
      url = 'https://torrentgalaxy.one/get-posts/keywords:$searchTerm:category:Anime:category:Movies';
    } else {
      url = 'https://torrentgalaxy.one/get-posts/keywords:$searchTerm:category:Anime:category:TV';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Document document = parse(response.body);

      List<Element> elements = document.querySelectorAll('.tgxtablerow');

      for (final element in elements) {
        var selec = element.querySelector('span');

        var title = element.querySelector('a[title]')!.text; // Title
        var uploader = element.querySelector('.username')!.text; // Uploader

        var size = TorrentHelper.convertSizeToMB(element.querySelectorAll('.badge')[0].text); // Size

        var seedersLeechers = RegExp('[0-9]{1,2}/[0-9]{1,2}')
            .firstMatch(element.querySelector('span[title="Seeders/Leechers"]')!.text.replaceAll(' ', '').replaceFirst('\n', ''))![0]!
            .split('/');

        var seeders = int.parse(seedersLeechers[0]); // Seeders
        var leechers = int.parse(seedersLeechers[1]); // Leechers

        var href = 'https://torrentgalaxy.one${element.querySelector('[role=button]')!.attributes["href"]!}';

        var torrentFile = TorrentFile(provider: TorrentProviders.TorrentGalaxy, title: title, uploader: uploader, seeders: seeders, leechers: leechers, size: size, href: href);
        torrents.add(torrentFile);
      }
    }
    return torrents;
  }
}
