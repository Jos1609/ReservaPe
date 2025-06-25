// lib/features/courts/services/court_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/cancha.dart';
class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'canchas';

  // Obtener canchas por ID de empresa
  Future<List<CourtModel>> getCourtsByCompanyId(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('empresaId', isEqualTo: companyId)
          .get();

      return querySnapshot.docs
          .map((doc) => CourtModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar las canchas');
    }
  }

  // Obtener una cancha específica
  Future<CourtModel?> getCourtById(String courtId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(courtId).get();
      
      if (doc.exists && doc.data() != null) {
        return CourtModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener canchas por tipo de deporte
  Future<List<CourtModel>> getCourtsBySportType(String sportType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('tipodeporte', isEqualTo: sportType)
          .get();

      return querySnapshot.docs
          .map((doc) => CourtModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar las canchas');
    }
  }

  // Obtener canchas con filtros
  Future<List<CourtModel>> getCourtsWithFilters({
    String? companyId,
    String? sportType,
    double? maxDayPrice,
    double? maxNightPrice,
    bool? hasRoof,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (companyId != null) {
        query = query.where('empresaId', isEqualTo: companyId);
      }
      if (sportType != null) {
        query = query.where('tipodeporte', isEqualTo: sportType);
      }
      if (maxDayPrice != null) {
        query = query.where('preciodia', isLessThanOrEqualTo: maxDayPrice);
      }
      if (maxNightPrice != null) {
        query = query.where('precionoche', isLessThanOrEqualTo: maxNightPrice);
      }
      if (hasRoof != null) {
        query = query.where('techo', isEqualTo: hasRoof);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => CourtModel.fromMap(
                doc.id, 
                doc.data() as Map<String, dynamic>
              ))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar las canchas');
    }
  }
}