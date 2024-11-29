import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // L'URL de base de l'API
  static const String baseUrl = "http://localhost:5000/api/users";

  // Méthode pour la connexion
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Logs pour le débogage
      print("Request Body: ${jsonEncode({
            'email': email,
            'password': password
          })}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // Méthode pour ajouter un utilisateur
  static Future<Map<String, dynamic>> addUser(Map<String, String> user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      print("Request Body: ${jsonEncode(user)}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: ${response.body}');
      } else {
        throw Exception('Failed to add user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  // Méthode pour récupérer tous les utilisateurs
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Méthode pour récupérer un utilisateur par ID
  static Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Méthode pour mettre à jour un utilisateur
  static Future<Map<String, dynamic>> updateUser(
      String id, Map<String, String> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      print("Request Body: ${jsonEncode(updatedData)}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: ${response.body}');
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Méthode pour supprimer un utilisateur
  static Future<void> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Méthode pour vérifier le statut de connexion d'un utilisateur (par exemple via un token)
  static Future<bool> isAuthenticated(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error checking authentication: $e');
    }
  }
}
