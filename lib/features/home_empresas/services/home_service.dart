import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';

class HomeEmpresaService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await _auth.authStateChanges().first; // Asegura que el estado de autenticación esté listo
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<List<CourtModel>> getUserCourts() {
    final userId = currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('canchas')
        .where('empresaId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourtModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Future<void> addCourt(CourtModel court) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    await _firestore.collection('canchas').add(court.toMap());
  }

  static Future<void> updateCourt(CourtModel court) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    if (court.id.isEmpty) {
      throw Exception('El ID de la cancha no puede estar vacío');
    }
    final docSnapshot = await _firestore.collection('canchas').doc(court.id).get();
    if (!docSnapshot.exists || docSnapshot.data()?['empresaId'] != userId) {
      throw Exception('No tienes permiso para actualizar esta cancha');
    }
    await _firestore.collection('canchas').doc(court.id).update(court.toMap());
  }

  static Future<void> addReservation({
    required ReservationModel reservation,
    required CourtModel court,
  }) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final docSnapshot = await _firestore.collection('canchas').doc(court.id).get();
    if (!docSnapshot.exists || docSnapshot.data()?['empresaId'] != userId) {
      throw Exception('No tienes permiso para agregar reservas a esta cancha');
    }
    final calculatedPrice = ReservationModel.calculateTotalPrice(
      startTime: reservation.startTime,
      endTime: reservation.endTime,
      court: court,
    );
    final updatedReservation = ReservationModel(
      id: reservation.id,
      courtId: reservation.courtId,
      clientName: reservation.clientName,
      clientPhone: reservation.clientPhone,
      clientAvatarUrl: reservation.clientAvatarUrl,
      startTime: reservation.startTime,
      endTime: reservation.endTime,
      totalPrice: calculatedPrice,
      status: reservation.status,
      cancellationReason: reservation.cancellationReason,
      comprobantePago: reservation.comprobantePago,
      metodosPago: reservation.metodosPago,
    );
    await _firestore
        .collection('canchas')
        .doc(court.id)
        .collection('reservas')
        .add(updatedReservation.toMap());
  }

  // Obtiene las reservas de una cancha para un mes específico, agrupadas por día
  static Stream<Map<DateTime, List<ReservationModel>>> getCourtReservationsForMonth({
    required String courtId,
    required DateTime month,
  }) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59);
    return _firestore
        .collection('canchas')
        .doc(courtId)
        .collection('reservas')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .snapshots()
        .map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.id, doc.data()))
          .toList();
      final Map<DateTime, List<ReservationModel>> groupedReservations = {};
      for (var reservation in reservations) {
        final dateKey = DateTime(
          reservation.startTime.year,
          reservation.startTime.month,
          reservation.startTime.day,
        );
        groupedReservations[dateKey] ??= [];
        groupedReservations[dateKey]!.add(reservation);
      }
      return groupedReservations;
    });
  }

  // Obtiene las reservas de una cancha para un día específico
  static Stream<List<ReservationModel>> getCourtReservations({
    required String courtId,
    required DateTime selectedDate,
  }) {
    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
    );
    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
    );
    return _firestore
        .collection('canchas')
        .doc(courtId)
        .collection('reservas')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Actualiza el estado de una reserva (Confirmada, Pendiente, Cancelada)
  static Future<void> updateReservationStatus({
    required String courtId,
    required String reservationId,
    required String status,
    String? cancellationReason,
  }) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final courtDoc = await _firestore.collection('canchas').doc(courtId).get();
    if (!courtDoc.exists || courtDoc.data()?['empresaId'] != userId) {
      throw Exception('No tienes permiso para actualizar reservas de esta cancha');
    }
    final updateData = {
      'status': status,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
    await _firestore
        .collection('canchas')
        .doc(courtId)
        .collection('reservas')
        .doc(reservationId)
        .update(updateData);
  }
}