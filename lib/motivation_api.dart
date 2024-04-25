import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationApi {
  final String quoteApiUrl;
  final String unsplashAccessKey;

  MotivationApi({required this.quoteApiUrl, required this.unsplashAccessKey});

  Future<Map<String, dynamic>> fetchMotivationalData() async {
    try {
      final response = await http.get(
        Uri.parse(quoteApiUrl),
        headers: {'X-Api-Key': 'U2pCa21J9HUjc8k4tngsVQ==qXtdvQJVBtwCzf6E'},
      );
      if (response.statusCode == 200) {
        return parseMotivationalData(response.body);
      } else {
        throw Exception('Failed to load motivational data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motivational data: $e');
      return {};
    }
  }

  Map<String, dynamic> parseMotivationalData(String motivationalData) {
    final data = json.decode(motivationalData);
    return {'quote': data[0]['quote'], 'author': data[0]['author']};
  }

  Future<String> fetchRandomImageUrl({String query = 'inspirational'}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/photos/random?query=$query&count=1'),
        headers: {
          'Authorization': 'Client-ID $unsplashAccessKey',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[0]['urls']['regular'] ?? '';
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random image: $e');
      return '';
    }
  }
}