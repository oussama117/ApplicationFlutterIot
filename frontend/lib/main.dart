import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des Utilisateurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Changer la route initiale pour le SplashScreen
      routes: {
        '/splash': (context) =>const SplashScreen(), // Ajoutez la route pour SplashScreen
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(role: 'user'),
        '/admin_home': (context) => const HomeScreen(role: 'admin'),
        '/Profile': (context) => const ProfileScreen(),
        // Ajoutez d'autres routes nécessaires ici
      },
      // home: AddUserScreen(),
      // home: SheepProfileScreen(),
    );
  }
}
