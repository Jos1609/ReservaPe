class CourtModel {
  final String id;
  final String empresaId;
  final String name;
  final String sportType;
  final List<String> photos;
  final double dayPrice;
  final double nightPrice;
  final bool hasRoof;
  final int teamCapacity;
  final String material;

  CourtModel({
    required this.id,
    required this.empresaId,
    required this.name,
    required this.sportType,
    required this.photos,
    required this.dayPrice,
    required this.nightPrice,
    required this.hasRoof,
    required this.teamCapacity,
    required this.material,
  });

  factory CourtModel.fromMap(String id, Map<String, dynamic> data) {
    return CourtModel(
      id: id,
      empresaId: data['empresaId'] ?? '',
      name: data['nombre'] ?? '',
      sportType: data['tipodeporte'] ?? '',
      photos: List<String>.from(data['fotos'] ?? []),
      dayPrice: (data['preciodia'] ?? 0.0).toDouble(),
      nightPrice: (data['precionoche'] ?? 0.0).toDouble(),
      hasRoof: data['techo'] ?? false,
      teamCapacity: data['capacidad_por_equipo'] ?? 0,
      material: data['material'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'nombre': name,
      'tipodeporte': sportType,
      'fotos': photos,
      'preciodia': dayPrice,
      'precionoche': nightPrice,
      'techo': hasRoof,
      'capacidad_por_equipo': teamCapacity,
      'material': material,
    };
  }
  CourtModel copyWith({
    String? id,
    String? empresaId,
    String? name,
    String? sportType,
    List<String>? photos,
    double? dayPrice,
    double? nightPrice,
    bool? hasRoof,
    int? teamCapacity,
    String? material,
  }) {
    return CourtModel(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      photos: photos ?? this.photos,
      dayPrice: dayPrice ?? this.dayPrice,
      nightPrice: nightPrice ?? this.nightPrice,
      hasRoof: hasRoof ?? this.hasRoof,
      teamCapacity: teamCapacity ?? this.teamCapacity,
      material: material ?? this.material,
    );
  }
}