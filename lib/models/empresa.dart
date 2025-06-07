// lib/features/authentication/models/company_model.dart
class CompanyModel {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String openingTime;
  final String closingTime;
  final List<String> services;
  final String address;
  final Map<String, double> coordinates;
  final String status;
  final String? email; // Campo opcional para correo
  final String? phoneNumber; // Campo opcional para número de celular

  CompanyModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    required this.openingTime,
    required this.closingTime,
    required this.services,
    required this.address,
    required this.coordinates,
    required this.status,
    this.email,
    this.phoneNumber,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'companyId': id,
      'name': name,
      'description': description,
      'logo': logo,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'services': services,
      'address': address,
      'coordinates': coordinates,
      'status': status,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // Crear instancia desde un Map (Firestore)
  static CompanyModel fromMap(String id, Map<String, dynamic> data) {
    return CompanyModel(
      id: id,
      name: data['name']?.toString() ?? data['nombre']?.toString() ?? '',
      description: data['description']?.toString() ?? data['descripcion']?.toString() ?? '',
      logo: data['logo']?.toString(),
      openingTime: data['openingTime']?.toString() ?? data['horario_apertura']?.toString() ?? '',
      closingTime: data['closingTime']?.toString() ?? data['horario_cierre']?.toString() ?? '',
      services: _extractServices(data),
      address: data['address']?.toString() ?? data['direccion']?.toString() ?? '',
      coordinates: _extractCoordinates(data),
      status: data['status']?.toString() ?? data['estado']?.toString() ?? 'Cerrado',
      email: data['email']?.toString(),
      phoneNumber: data['phoneNumber']?.toString(),
    );
  }

  // Método helper para extraer servicios de forma segura
  static List<String> _extractServices(Map<String, dynamic> data) {
    try {
      var serviciosData = data['services'] ?? data['servicios'];
      if (serviciosData == null) return [];
      if (serviciosData is List) {
        return serviciosData.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Método helper para extraer coordenadas de forma segura
  static Map<String, double> _extractCoordinates(Map<String, dynamic> data) {
    try {
      var coordsData = data['coordinates'] ?? data['coordenadas'];
      if (coordsData == null) {
        return {'latitude': 0.0, 'longitude': 0.0};
      }
      if (coordsData is Map) {
        return {
          'latitude': (coordsData['latitude'] ?? coordsData['lat'] ?? 0.0).toDouble(),
          'longitude': (coordsData['longitude'] ?? coordsData['lng'] ?? coordsData['lon'] ?? 0.0).toDouble(),
        };
      }
      return {'latitude': 0.0, 'longitude': 0.0};
    } catch (e) {
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  // Crear instancia desde JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'],
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      address: json['address'] ?? '',
      coordinates: Map<String, double>.from(json['coordinates'] ?? {'latitude': 0.0, 'longitude': 0.0}),
      status: json['status'] ?? 'Cerrado',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}