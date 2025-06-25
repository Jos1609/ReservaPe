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
  final String? email;
  final String? phoneNumber;

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
      'companyId': id.isNotEmpty ? id : throw ArgumentError('ID cannot be empty'),
      'name': name.isNotEmpty ? name : throw ArgumentError('Name cannot be empty'),
      'description': description.isNotEmpty ? description : '',
      'logo': logo?.isNotEmpty == true ? logo : null,
      'openingTime': openingTime.isNotEmpty ? openingTime : throw ArgumentError('Opening time cannot be empty'),
      'closingTime': closingTime.isNotEmpty ? closingTime : throw ArgumentError('Closing time cannot be empty'),
      'services': services.isNotEmpty ? services : [],
      'address': address.isNotEmpty ? address : throw ArgumentError('Address cannot be empty'),
      'coordinates': coordinates.isNotEmpty
          ? {
              'latitude': coordinates['latitude'] ?? 0.0,
              'longitude': coordinates['longitude'] ?? 0.0,
            }
          : {'latitude': 0.0, 'longitude': 0.0},
      'status': status.isNotEmpty ? status : 'Cerrado',
      'email': email?.isNotEmpty == true ? email : null,
      'phoneNumber': phoneNumber?.isNotEmpty == true ? phoneNumber : null,
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
}