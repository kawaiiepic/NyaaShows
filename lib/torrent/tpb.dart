import 'package:http/http.dart' as http;

class ThePirateBay {
  Future<http.Response> torrent() async {
    final response = await http
        .get(Uri.parse('https://1.piratebays.to/s/?q=jimmy+neutron'));

    if (response.statusCode == 200) {
      
      return response;
    } else {
      throw Exception();
    }
  }
}
