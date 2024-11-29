// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des utilisateurs.';
        _isLoading = false;
      });
    }
  }

  void _refreshUsers() {
    _fetchUsers();
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await ApiService.deleteUser(userId);
      _refreshUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _editUser(String userId) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(userId: userId);
      },
    );
    if (result == true) {
      _refreshUsers();
    }
  }

  void _addUser() async {
    bool? result = await AddUserDialog.show(context);

    if (result == true) {
      _refreshUsers();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des utilisateurs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Prénom')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Rôle')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user['name'],
                              style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(user['lastName'],
                              style: TextStyle(fontStyle: FontStyle.italic))),
                          DataCell(Text(user['email'])),
                          DataCell(Text(user['role'],
                              style: TextStyle(color: Colors.blue))),
                          DataCell(Row(
                            children: [
                              // Bouton de suppression avec animation
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteUser(user['_id']),
                                color: Colors.red,
                                tooltip: 'Supprimer',
                              ),
                              // Bouton de modification avec animation
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editUser(user['_id']),
                                color: Colors.blue,
                                tooltip: 'Modifier',
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final String userId;
  const EditUserDialog({super.key, required this.userId});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = await ApiService.getUserById(widget.userId);
      setState(() {
        _nameController.text = user['name'];
        _lastNameController.text = user['lastName'];
        _emailController.text = user['email'];
        _roleController.text = user['role'];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement des données utilisateur.';
      });
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final updatedUser = await ApiService.updateUser(
        widget.userId,
        {
          'name': _nameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'role': _roleController.text,
        },
      );

      if (updatedUser != null) {
        Navigator.pop(context, true); // Modification réussie
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour de l\'utilisateur.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier l\'utilisateur'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage,
                        style: const TextStyle(color: Colors.red)),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUser,
                    child: const Text('Sauvegarder'),
                  ),
                ],
              ),
            ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddUserDialog();
          },
        ) ??
        false;
  }

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Ajout du contrôleur pour le mot de passe
  final TextEditingController _roleController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _addUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final newUser = await ApiService.addUser({
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _roleController.text,
      });

      if (newUser != null) {
        Navigator.pop(context, true); // Utilisateur ajouté avec succès
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'ajout de l\'utilisateur.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un utilisateur'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage,
                        style: const TextStyle(color: Colors.red)),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller:
                        _passwordController, // Champ pour le mot de passe
                    obscureText: true, // Masquer le mot de passe
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe'),
                  ),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
    );
  }
}
