import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import 'dart:io';
import 'package:sintetico/models/cancha.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Subir comprobante de pago a Storage
  Future<String?> uploadPaymentReceipt(File receiptFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Generar nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_${user.uid}_$timestamp.jpg';

      // Referencia al archivo en Storage
      final ref = _storage.ref().child('receipts/$fileName');

      // Subir archivo
      final uploadTask = await ref.putFile(receiptFile);

      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Obtener información del usuario actual
  Future<UserModel?> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('clients').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? user.email ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Crear nueva reserva usando el modelo existente
  Future<String?> createReservation(ReservationModel reservation) async {
    try {
      // Convertir el modelo a Map y agregar timestamps
      final reservationData = reservation.toMap();
      reservationData['createdAt'] = FieldValue.serverTimestamp();
      reservationData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef =
          await _firestore.collection('reservas').add(reservationData);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Obtener información de la cancha
  Future<CourtModel?> getCourtInfo(String courtId) async {
    try {
      final doc = await _firestore.collection('canchas').doc(courtId).get();

      if (doc.exists && doc.data() != null) {
        return CourtModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener información de la empresa
  Future<CompanyModel?> getCompanyInfo(String companyId) async {
    try {
      final doc = await _firestore.collection('empresas').doc(companyId).get();

      if (doc.exists && doc.data() != null) {
        return CompanyModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Validar disponibilidad antes de confirmar
  Future<bool> validateAvailability(
    String courtId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Buscar reservas que se superpongan con el horario seleccionado
      final reservations = await _firestore
          .collection('reservas')
          .where('courtId', isEqualTo: courtId)
          .where('status', whereIn: ['Pendiente', 'Confirmada']).get();

      // Verificar si hay superposición
      for (final doc in reservations.docs) {
        final reservation = ReservationModel.fromMap(doc.id, doc.data());

        // Verificar superposición de horarios
        if (startTime.isBefore(reservation.endTime) &&
            endTime.isAfter(reservation.startTime)) {
          return false; // Hay superposición
        }
      }

      return true; // No hay superposición
    } catch (e) {
      return false;
    }
  }

  // Obtener métodos de pago disponibles
  Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    // Por ahora retornamos métodos hardcodeados
    // En el futuro podrían venir de Firebase
    return [
      PaymentMethod(
        id: 'yape',
        name: 'Yape',
        icon: 'assets/icons/yape.png',
        instructions: 'Escanea el código QR o usa el número 999 999 999',
      ),
      PaymentMethod(
        id: 'plin',
        name: 'Plin',
        icon: 'assets/icons/plin.png',
        instructions: 'Escanea el código QR o usa el número 999 999 999',
      ),
      PaymentMethod(
        id: 'transferencia',
        name: 'Transferencia Bancaria',
        icon: 'assets/icons/bank.png',
        instructions: 'BCP: 123-456789-0-12\nInterbank: 098-765432-1-09',
      ),
    ];
  }
}

// Modelo para métodos de pago
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String instructions;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.instructions,
  });
}
