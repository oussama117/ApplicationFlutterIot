import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fonction pour récupérer les informations utilisateur
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('userName') ?? 'Inconnu',
      'email': prefs.getString('userEmail') ?? 'Non renseigné',
      'role': prefs.getString('userRole') ?? 'Utilisateur',
    };
  }

  // Fonction de déconnexion
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprimer toutes les données
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
                child: Text('Erreur lors du chargement des données.'));
          }

          final userInfo = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Nom : ${userInfo['name']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Email : ${userInfo['email']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Role : ${userInfo['role']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => logout(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Logout'),
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
