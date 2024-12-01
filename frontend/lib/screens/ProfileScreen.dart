import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fetch user information from SharedPreferences
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    String name = prefs.getString('userName') ?? 'Inconnu';
    String email = prefs.getString('userEmail') ?? 'Non renseigné';
    String role = prefs.getString('userRole') ?? 'Utilisateur';

    // Debugging output to check the values being fetched
    print('Fetched user info - Name: $name, Email: $email, Role: $role');

    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Save user information to SharedPreferences
  Future<void> saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', 'John Doe');
    await prefs.setString('userEmail', 'john.doe@example.com');
    await prefs.setString('userRole', 'Admin');

    // Debugging output to ensure data is saved
    print('User Info Saved: John Doe, john.doe@example.com, Admin');
  }

  // Logout function
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur lors du chargement des données.'),
            );
          }

          final userInfo = snapshot.data!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage('assets/img/profile.png'),
                  onBackgroundImageError: (_, __) => const Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                // User Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'User Information',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Nom : ${userInfo['name']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Email : ${userInfo['email']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Role : ${userInfo['role']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Logout Button
                ElevatedButton(
                  onPressed: () => logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
