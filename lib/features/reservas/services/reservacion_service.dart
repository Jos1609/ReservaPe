import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sintetico/models/reserva.dart';
import 'dart:io' show File; // Solo disponible en móviles
import 'dart:typed_data';  // Para Flutter Web
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio para manejar operaciones relacionadas con reservas.
class ReservationService {
  /// Crea una nueva reserva en Firestore y sube el comprobante a Firebase Storage.
  static Future<void> createReservation({
    required String courtId,
    required ReservationModel reservation,
    File? receiptFile,              // Usado en móviles
    Uint8List? receiptBytesWeb,     // Usado en Flutter Web
  }) async {
    try {
      String comprobanteUrl = '';

      if (!kIsWeb && receiptFile != null) {
        // 📱 Android/iOS: subir archivo local
        final ref = FirebaseStorage.instance
            .ref()
            .child('receipts')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(receiptFile);
        comprobanteUrl = await ref.getDownloadURL();

      } else if (kIsWeb && receiptBytesWeb != null) {
        // 🌐 Web: subir como bytes
        final ref = FirebaseStorage.instance
            .ref()
            .child('receipts')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final metadata = SettableMetadata(contentType: 'image/jpeg');
        await ref.putData(receiptBytesWeb, metadata);
        comprobanteUrl = await ref.getDownloadURL();

      } else {
        // Sin comprobante
        comprobanteUrl = '';
      }

      // Agregar comprobante al mapa
      final reservationData = reservation.toMap();
      reservationData['comprobantePago'] = comprobanteUrl;

      await FirebaseFirestore.instance
          .collection('reservas')
          .add(reservationData);
    } catch (e) {
      throw Exception('Error al crear la reserva: $e');
    }
  }
}
