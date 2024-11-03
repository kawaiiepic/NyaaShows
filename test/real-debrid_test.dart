// Import the test package and Counter class

import 'package:test/test.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Real-Debrid testing', () async {
    final response = await http.get(Uri.parse('https://nyaa.si/?f=0&c=1_2&q=rent+a+girlfriend+season+2'));
    if (response.statusCode == 200) {
      Document document = parse(response.body);
      List<Element> elements = document.querySelectorAll('tr[class="default"]');
      for (var element in elements) {
        var td = element.querySelectorAll('td[class=text-center]');
        var title = element.querySelectorAll('a:not(.comments)')[1].text;
        var magnet = td[0].querySelectorAll('a[href]')[1].attributes["href"];
        var uploadedDate = td[2].text;
        var size = td[1].text;
        var seeders = td[3].text;
        var leechers = td[4].text;
      }
      // print(elements);
    }
  });
}


// <td class="text-center">
// 					<a href="/download/1784260.torrent"><i class="fa fa-fw fa-download"></i></a>
// 					<a href="magnet:?xt=urn:btih:2c651761c77a85349f8971873816209cf05e8c85&amp;dn=%5BneoDESU%5D%20Rent%20a%20Girlfriend%20%5BSeason%203%5D%20%5BBD%201080p%20x265%20HEVC%20OPUS%20AAC%5D%20%5BDual%20Audio%5D%20Kanojo%2C%20Okarishimasu&amp;tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&amp;tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&amp;tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce"><i class="fa fa-fw fa-magnet"></i></a>
// 				</td>


			// 	<tr class="default">
			// 	<td>
			// 		<a href="/?c=1_2" title="Anime - English-translated">
			// 			<img src="/static/img/icons/nyaa/1_2.png" alt="Anime - English-translated" class="category-icon">
			// 		</a>
			// 	</td>
			// 	<td colspan="2">
			// 		<a href="/view/1784260#comments" class="comments" title="10 comments">
			// 			<i class="fa fa-comments-o"></i>10</a>
			// 		<a href="/view/1784260" title="[neoDESU] Rent a Girlfriend [Season 3] [BD 1080p x265 HEVC OPUS AAC] [Dual Audio] Kanojo, Okarishimasu">[neoDESU] Rent a Girlfriend [Season 3] [BD 1080p x265 HEVC OPUS AAC] [Dual Audio] Kanojo, Okarishimasu</a>
			// 	</td>
			// 	<td class="text-center">
			// 		<a href="/download/1784260.torrent"><i class="fa fa-fw fa-download"></i></a>
			// 		<a href="magnet:?xt=urn:btih:2c651761c77a85349f8971873816209cf05e8c85&amp;dn=%5BneoDESU%5D%20Rent%20a%20Girlfriend%20%5BSeason%203%5D%20%5BBD%201080p%20x265%20HEVC%20OPUS%20AAC%5D%20%5BDual%20Audio%5D%20Kanojo%2C%20Okarishimasu&amp;tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&amp;tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&amp;tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce"><i class="fa fa-fw fa-magnet"></i></a>
			// 	</td>
			// 	<td class="text-center">2.9 GiB</td>
			// 	<td class="text-center" data-timestamp="1709317966">2024-03-01 18:32</td>

			// 	<td class="text-center">32</td>
			// 	<td class="text-center">5</td>
			// 	<td class="text-center">2269</td>
			// </tr>


				// <td>
				// 	<a href="/?c=1_2" title="Anime - English-translated">
				// 		<img src="/static/img/icons/nyaa/1_2.png" alt="Anime - English-translated" class="category-icon">
				// 	</a>
				// </td>
				// <td colspan="2">
				// 	<a href="/view/1784260#comments" class="comments" title="10 comments">
				// 		<i class="fa fa-comments-o"></i>10</a>
				// 	<a href="/view/1784260" title="[neoDESU] Rent a Girlfriend [Season 3] [BD 1080p x265 HEVC OPUS AAC] [Dual Audio] Kanojo, Okarishimasu">[neoDESU] Rent a Girlfriend [Season 3] [BD 1080p x265 HEVC OPUS AAC] [Dual Audio] Kanojo, Okarishimasu</a>
				// </td>
				// <td class="text-center">
				// 	<a href="/download/1784260.torrent"><i class="fa fa-fw fa-download"></i></a>
				// 	<a href="magnet:?xt=urn:btih:2c651761c77a85349f8971873816209cf05e8c85&amp;dn=%5BneoDESU%5D%20Rent%20a%20Girlfriend%20%5BSeason%203%5D%20%5BBD%201080p%20x265%20HEVC%20OPUS%20AAC%5D%20%5BDual%20Audio%5D%20Kanojo%2C%20Okarishimasu&amp;tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&amp;tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&amp;tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&amp;tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce"><i class="fa fa-fw fa-magnet"></i></a>
				// </td>
				// <td class="text-center">2.9 GiB</td>
				// <td class="text-center" data-timestamp="1709317966">2024-03-01 18:32</td>

				// <td class="text-center">32</td>
				// <td class="text-center">5</td>
				// <td class="text-center">2269</td>
