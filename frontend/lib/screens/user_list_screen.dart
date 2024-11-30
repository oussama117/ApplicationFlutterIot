import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching users.';
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
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

  void _searchUsers(String query) {
    final filtered = _users.where((user) {
      final name = user['name'].toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      _searchUsers(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Last Name')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('delete')),
                              DataColumn(label: Text('Update')),
                            ],
                            rows: _filteredUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(
                                    user['lastName'],
                                  )),
                                  DataCell(Text(user['email'])),
                                  DataCell(Text(user['role'],
                                      style:
                                          const TextStyle(color: Colors.blue))),
                                  DataCell(
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteUser(user['_id']),
                                      color: Colors.red,
                                      tooltip: 'Delete',
                                    ),
                                  ),
                                  DataCell(
                                    // Edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editUser(user['_id']),
                                      color: Colors.blue,
                                      tooltip: 'Edit',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        onPressed: _addUser,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
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
        _errorMessage = 'Error loading user data.';
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
        Navigator.pop(context, true); // Update successful
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating user.';
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
      title: const Text('Edit User'),
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
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUser,
                    child: const Text('Save'),
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
  final TextEditingController _passwordController = TextEditingController();
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
        Navigator.pop(context, true); // User added successfully
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding user.';
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
      title: const Text('Add User'),
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
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Add User'),
                  ),
                ],
              ),
            ),
    );
  }
}
