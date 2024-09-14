// Import the test package and Counter class
import 'package:html_parser_plus/html_parser_plus.dart';
import 'package:nyaashows/torrent/tpb.dart';
import 'package:test/test.dart';

void main() {
  test('The Pirate Bay Search', () async {
    var tpb = ThePirateBay();
    await tpb.torrent().then((value) {
      var htmlString = value.body;
      final parser = HtmlParser();
      var node = parser.parse(htmlString);
      // var magnets = parser.query(node,
      // '//nobr/a/@href|dart.replace(magnet, \nmagnet)'); // Magnet Links
      var parse = parser.queryNodes(node, '//tr');
      var int = 0;
      for (var p in parse) {
        var title = parser.query(p, '//td[2]/@align/@text|dart.replace(\n ,)');
        var uploadedDate =
            parser.query(p, '//td[3]/@align/@text|dart.replace(\n ,)');
        var size = parser.query(p, '//td[5]/@align/@text|dart.replace(\n ,)');
        var seeders =
            parser.query(p, '//td[6]/@align/@text|dart.replace(\n ,)');
        var leechers =
            parser.query(p, '//td[7]/@align/@text|dart.replace(\n ,)');
        var uploader =
            parser.query(p, '//td[8]/@align/@text|dart.replace(\n ,)');
        var magnet = parser.query(p, '//td/nobr/a/@href');
        print(int.toString() + magnet);
        int++;
      }

      // print(parse);
    });
    // expect(counter.value, 2);
  });

  test('Real-Debrid testing', () async {
    print("Test");
  });
}
