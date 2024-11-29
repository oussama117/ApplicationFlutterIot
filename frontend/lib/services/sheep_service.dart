import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/sheep_model.dart';

class SheepService {
  final String BaseUrl = 'http://localhost:5000/api/sheep';

  ///AddSheep
  Future<bool> addSheep(Sheep sheep) async {
    final url = Uri.parse(BaseUrl);

    try {
      final response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: jsonEncode(sheep.toJson()));
      if (response.statusCode == 201) {
        print('Sheep added successfully');
        return true;
      } else {
        print('Failed to add sheep: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding sheep: $e');
      return false;
    }
  }

//Fetch all sheep
  Future<List<Sheep>> fetchSheep() async {
    final url = Uri.parse(BaseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> sheepData = jsonDecode(response.body);
        return sheepData.map((json) => Sheep.fromJson(json)).toList();
      } else {
        print('Failed to fetch sheep: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching sheep: $e');
      return [];
    }
  }

  //update a Sheep

  Future<bool> updateSheep(String id, Sheep Sheep) async {
    final url = Uri.parse('$BaseUrl/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-type': 'application/json'},
        body: jsonEncode(Sheep.toJson()),
      );

      if (response.statusCode == 200) {
        print('Sheep updated successfully');
        return true;
      } else {
        print('Failed to update sheep :${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating sheep: $e');
      return false;
    }
  }

//Delete a Sheep

  Future<bool> deleteSheep(String id) async {
    final url = Uri.parse('$BaseUrl/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print('Sheep deleted successfully');
        return true;
      } else {
        print('Failed to delete sheep :${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting sheep: $e');
      return false;
    }
  }
}
