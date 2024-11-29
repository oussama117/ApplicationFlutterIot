import 'dart:convert';
import 'package:http/http.dart' as http;

class NecklaceService {
  static Future<List<dynamic>> fetchNecklaceData(String idNecklace) async {
    final response = await http
        .get(Uri.parse('http://localhost:5000/api/necklace/$idNecklace'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data']; // Adjust based on the API's structure.
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
