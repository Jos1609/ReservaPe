import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import 'package:sintetico/models/cancha.dart';

class ReservationHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener reservas del usuario actual
  Stream<List<ReservationModel>> streamUserReservations({
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('reservas')
        .where('clientId', isEqualTo: user.uid);

    // Filtrar por estado si se especifica
    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    // Filtrar por rango de fechas
    if (startDate != null) {
      query = query.where('startTime', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('startTime', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    // Ordenar por fecha más reciente primero
    query = query.orderBy('startTime', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener información de una cancha específica
  Future<CourtModel?> getCourtInfo(String courtId) async {
    try {
      final doc = await _firestore.collection('canchas').doc(courtId).get();
      
      if (doc.exists && doc.data() != null) {
        return CourtModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener información de la cancha: $e');
      return null;
    }
  }

  // Obtener información de una empresa específica
  Future<CompanyModel?> getCompanyInfo(String companyId) async {
    try {
      final doc = await _firestore.collection('empresas').doc(companyId).get();
      
      if (doc.exists && doc.data() != null) {
        return CompanyModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener información de la empresa: $e');
      return null;
    }
  }

  // Cancelar una reserva
  Future<bool> cancelReservation(String reservationId, String reason) async {
    try {
      await _firestore.collection('reservas').doc(reservationId).update({
        'status': 'Cancelada',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error al cancelar reserva: $e');
      return false;
    }
  }

  // Obtener estadísticas del usuario
  Future<UserReservationStats> getUserStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return UserReservationStats.empty();
    }

    try {
      final snapshot = await _firestore
          .collection('reservas')
          .where('clientId', isEqualTo: user.uid)
          .get();

      int total = snapshot.docs.length;
      int pending = 0;
      int confirmed = 0;
      int cancelled = 0;
      int rejected = 0;
      int completed = 0;

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'Pendiente':
            pending++;
            break;
          case 'Confirmada':
            confirmed++;
            break;
          case 'Cancelada':
            cancelled++;
            break;
          case 'Rechazada':
            rejected++;
            break;
          case 'Completada':
            completed++;
            break;
        }
      }

      return UserReservationStats(
        totalReservations: total,
        pendingReservations: pending,
        confirmedReservations: confirmed,
        cancelledReservations: cancelled,
        rejectedReservations: rejected,
        completedReservations: completed,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener estadísticas: $e');
      return UserReservationStats.empty();
    }
  }
}

// Modelo para estadísticas de reservas
class UserReservationStats {
  final int totalReservations;
  final int pendingReservations;
  final int confirmedReservations;
  final int cancelledReservations;
  final int rejectedReservations;
  final int completedReservations;

  UserReservationStats({
    required this.totalReservations,
    required this.pendingReservations,
    required this.confirmedReservations,
    required this.cancelledReservations,
    required this.rejectedReservations,
    required this.completedReservations,
  });

  factory UserReservationStats.empty() {
    return UserReservationStats(
      totalReservations: 0,
      pendingReservations: 0,
      confirmedReservations: 0,
      cancelledReservations: 0,
      rejectedReservations: 0,
      completedReservations: 0,
    );
  }
}