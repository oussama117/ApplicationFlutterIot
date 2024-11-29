import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_list_screen.dart';
import 'ProfileScreen.dart';
import 'list_of_sheep_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données sauvegardées
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implémentez la recherche si nécessaire
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              } else if (value == 'users' && role == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserListScreen()),
                );
              } else if (value == 'sheep' && role == 'user') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListOfSheepScreen()),
                );
              } else if (value == 'logout') {
                logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('Profil'),
                ),
                if (role == 'admin')
                  const PopupMenuItem(
                    value: 'users',
                    child: Text('List of user'),
                  ),
                if (role == 'user')
                  const PopupMenuItem(
                    value: 'sheep',
                    child: Text('List of sheep'),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Drawer Header
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            // Drawer Menu Items
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            if (role == 'admin')
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text('Liste of user'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserListScreen()),
                  );
                },
              ),
            if (role == 'user')
              ListTile(
                leading: const Icon(Icons.list, color: Colors.blue),
                title: const Text('List of sheep'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListOfSheepScreen()),
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Rester sur Home
          } else if (index == 1) {
            if (role == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            } else if (role == 'user') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListOfSheepScreen()),
              );
            }
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }
}
