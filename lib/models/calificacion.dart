class RatingModel {
  final String id;
  final String companyId;
  final String clientId;
  final String comment;
  final int rating;

  RatingModel({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.comment,
    required this.rating,
  });

  factory RatingModel.fromMap(String id, Map<String, dynamic> data) {
    return RatingModel(
      id: id,
      companyId: data['id_empresa'] ?? '',
      clientId: data['id_cliente'] ?? '',
      comment: data['comentario'] ?? '',
      rating: data['calificacion'] ?? 0,
    );
  }
}