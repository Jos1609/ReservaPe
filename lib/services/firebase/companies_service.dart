import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/calificacion.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';
class CompaniesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CompanyModel>> getCompanies() async {
    try {
      final querySnapshot = await _firestore.collection('empresas').get();
      return querySnapshot.docs
          .map((doc) => CompanyModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error cargando empresas: $e');
    }
  }

  Future<List<RatingModel>> getRatingsForCompany(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('calificaciones')
          .where('id_empresa', isEqualTo: companyId)
          .get();
      return querySnapshot.docs
          .map((doc) => RatingModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error cargando calificaciones: $e');
    }
  }

  Future<List<CourtModel>> getCourtsForCompany(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('canchas')
          .where('id_empresa', isEqualTo: companyId)
          .get();
      return querySnapshot.docs
          .map((doc) => CourtModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error cargando canchas: $e');
    }
  }
}