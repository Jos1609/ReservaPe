// Modelo para representar una cancha sintética
class FieldModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double pricePerHour;
  final List<String> availableTimes;

  FieldModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.pricePerHour,
    required this.availableTimes,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      availableTimes: List<String>.from(json['availableTimes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'pricePerHour': pricePerHour,
      'availableTimes': availableTimes,
    };
  }
}