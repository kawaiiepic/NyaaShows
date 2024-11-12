import 'package:nyaashows/torrents/helper.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

class TorrentGalaxy extends TorrentEngine {
  @override
  String name = "TorrentGalaxy";

  @override
  Future<List<TorrentFile>?> search(List<String> searchTerms) async {
    String url;
    List<TorrentFile> torrents = [];
    for (var term in searchTerms) {
      var url = 'https://torrentgalaxy.one/get-posts/keywords:$term:category:Anime:category:Movies:category:TV';
      print(url);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Document document = parse(response.body);
        List<Element> elements = document.querySelectorAll('a[title]');

        for (final element in elements) {
          var selec = element.querySelector('span');
          if (selec != null && selec.attributes["src"] == "torrent") {
            final href = element.attributes["href"];

            final postDetail = await http.get(Uri.parse('https://torrentgalaxy.one$href'));

            if (postDetail.statusCode == 200) {
              Document document = parse(postDetail.body);
              Document div = parse(document.querySelectorAll('div.torrentpagetable')[1].innerHtml);
              final magnet = document.querySelectorAll('a.lift')[1].attributes["href"]!;
              var elements = div.querySelectorAll('div.tprow');
              var title = elements[0].children[1].children[0].text;
              var uploadDate = elements[8].children[1].text;
              var seeders = int.tryParse(elements[10].children[1].children[0].text.replaceFirst('Seeds', '').trim());
              var leechers = int.tryParse(elements[10].children[1].children[1].text.replaceFirst('Leechers', '').trim());
              var uploader = elements[7].children[1].text;

              var sizeText = elements[5].children[1].text;
              var sized = 0;

              if (sizeText.contains("GB")) {
                var sizeTrimmed = sizeText.replaceAll('GB', '');
                sized = (double.parse(sizeTrimmed) * 1000.0 * 1000000).toInt();
              } else {
                sized = (double.parse(sizeText.replaceAll('MB', '')) * 1000000).toInt();
              }

              var size = sized;

              var torrentFile =
                  TorrentFile(title: title, uploadedDate: uploadDate, size: size, seeders: seeders, leechers: leechers, uploader: uploader, magnet: magnet);
              if (!torrents.contains(torrentFile)) {
                torrents.add(torrentFile);
              }
            }
          }
        }
      }
    }
    return torrents;
  }
}
