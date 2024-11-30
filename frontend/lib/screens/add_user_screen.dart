import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddUserDialog {
  static Future<bool?> show(BuildContext context, {Map<String, dynamic>? user}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController(text: user?['name'] ?? '');
    final TextEditingController _lastNameController = TextEditingController(text: user?['lastName'] ?? '');
    final TextEditingController _emailController = TextEditingController(text: user?['email'] ?? '');
    final TextEditingController _passwordController = TextEditingController();
    String _role = user?['role'] ?? 'user';
    bool _isLoading = false;

    Future<void> _addUser() async {
      // Vérifier si le formulaire est valide avant de procéder
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Affiche un indicateur de chargement
      _isLoading = true;


      final userData = {
        'name': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': _role,
      };

      try {
        if (user == null) {
          // Ajout d'un nouvel utilisateur
          await ApiService.addUser(userData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur ajouté avec succès')),
          );
        } else {
          // Mise à jour d'un utilisateur existant
          await ApiService.updateUser(user['_id'], userData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur mis à jour avec succès')),
          );
        }
        Navigator.of(context).pop(true); // Retourne un succès
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'utilisateur : $error')),
        );
      } finally {

        _isLoading = false;
        
      }
    }

    return showDialog<bool>( 
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un utilisateur'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un prénom';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Mot de passe'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _role,
                        onChanged: (value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Rôle'),
                        items: ['user', 'admin']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Ferme sans succès
                  },
                  child: const Text('Annuler'),
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _addUser();
                          });
                        },
                        child: const Text('Ajouter'),
                      ),
              ],
            );
          },
        );
      },
    );
  }
}
