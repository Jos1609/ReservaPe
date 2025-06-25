import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';
import 'dart:io';

class HomeEmpresaService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await _auth
        .authStateChanges()
        .first; // Asegura que el estado de autenticación esté listo
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

    // Subir imágenes a Firebase Storage y obtener URLs
    List<String> uploadedPhotoUrls = [];
    for (String photoPath in court.photos) {
      // Solo subir si es una ruta local (no una URL existente)
      if (photoPath.startsWith('/')) {
        try {
          File file = File(photoPath);
          // Crear un nombre único para la imagen
          String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          // Definir el path en Firebase Storage
          Reference storageRef =
              FirebaseStorage.instance.ref().child('courts/$userId/$fileName');
          // Subir el archivo
          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          // Obtener la URL de descarga
          String downloadUrl = await snapshot.ref.getDownloadURL();
          uploadedPhotoUrls.add(downloadUrl);
        } catch (e) {
          throw Exception('Error al subir imagen: $e');
        }
      } else {
        uploadedPhotoUrls.add(photoPath); // Mantener URLs existentes
      }
    }

    // Crear un nuevo CourtModel con las URLs de las imágenes subidas
    CourtModel updatedCourt = court.copyWith(photos: uploadedPhotoUrls);

    // Guardar en Firestore
    await _firestore.collection('canchas').add(updatedCourt.toMap());
  }

  static Future<void> updateCourt(CourtModel court) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    if (court.id.isEmpty) {
      throw Exception('El ID de la cancha no puede estar vacío');
    }
    final docSnapshot =
        await _firestore.collection('canchas').doc(court.id).get();
    if (!docSnapshot.exists || docSnapshot.data()?['empresaId'] != userId) {
      throw Exception('No tienes permiso para actualizar esta cancha');
    }

    // Subir nuevas imágenes a Firebase Storage
    List<String> uploadedPhotoUrls = [];
    for (String photoPath in court.photos) {
      if (photoPath.startsWith('/')) {
        try {
          File file = File(photoPath);
          String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          Reference storageRef =
              FirebaseStorage.instance.ref().child('courts/$userId/$fileName');
          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          uploadedPhotoUrls.add(downloadUrl);
        } catch (e) {
          throw Exception('Error al subir imagen: $e');
        }
      } else {
        uploadedPhotoUrls.add(photoPath); // Mantener URLs existentes
      }
    }

    // Actualizar el modelo con las URLs
    CourtModel updatedCourt = court.copyWith(photos: uploadedPhotoUrls);

    // Actualizar en Firestore
    await _firestore
        .collection('canchas')
        .doc(court.id)
        .update(updatedCourt.toMap());
  }

  static Future<void> addReservation({
    required ReservationModel reservation,
    required CourtModel court,
  }) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final docSnapshot =
        await _firestore.collection('canchas').doc(court.id).get();
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
    await _firestore.collection('reservas').add(updatedReservation.toMap());
  }

  // Obtiene las reservas de una cancha para un mes específico, agrupadas por día
  static Stream<Map<DateTime, List<ReservationModel>>>
      getCourtReservationsForMonth({
    required String courtId,
    required DateTime month,
  }) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59);
    return _firestore
        .collection('reservas')
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('startTime',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
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
        .collection('reservas')
        .where('courtId', isEqualTo: courtId)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
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
      throw Exception(
          'No tienes permiso para actualizar reservas de esta cancha');
    }
    final updateData = {
      'status': status,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
    await _firestore
        .collection('reservas')
        .doc(reservationId)
        .update(updateData);
  }
}
