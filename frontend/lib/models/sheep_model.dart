class Sheep {
  final String id;
  final String necklaceID;
  final String age;
  final String race;
  final String healthStatus;
  final String weight;
  final bool vaccinated;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sheep({
    required this.id,
    required this.necklaceID,
    required this.age,
    required this.race,
    required this.healthStatus,
    required this.weight,
    required this.vaccinated,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a Sheep object from JSON
  factory Sheep.fromJson(Map<String, dynamic> json) {
    return Sheep(
      id: json['_id'] ?? '',
      necklaceID: json['necklaceID'] ?? '',
      age: json['age']?.toString() ?? "0",
      race: json['race'] ?? '',
      healthStatus: json['healthStatus'] ?? '',
      weight: json['weight']?.toString() ?? '0',
      vaccinated: json['vaccinated'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

// Method to convert Sheep object to JSON for POST requests
  Map<String, dynamic> toJson() {
    return {
      'necklaceID': necklaceID,
      'age': age,
      'race': race,
      'healthStatus': healthStatus,
      'weight': weight,
      'vaccinated': vaccinated,
    };
  }
}
