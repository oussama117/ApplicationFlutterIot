class User {
  final String? id; // Identifiant unique de l'utilisateur
  final String name; // Nom
  final String lastName; // Prénom
  final String email; // Email
  final String password; // Mot de passe
  final String role; // Rôle (ex. 'admin', 'user')

  User({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });

  // Convertit un objet JSON en instance de User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
    );
  }

  // Convertit une instance de User en un objet JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
