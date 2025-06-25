import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sintetico/models/reserva.dart';

/// Servicio para verificar disponibilidad de horarios en una cancha.
class AvailabilityService {
  /// Obtiene las reservas para una cancha en una fecha específica.
  static Future<List<ReservationModel>> getReservationsForDate({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('courts')
          .doc(courtId)
          .collection('reservations')
          .where('startTime', isGreaterThanOrEqualTo: startOfDay)
          .where('startTime', isLessThan: endOfDay)
          .get();

      return snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data() as String, doc.id as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  /// Obtiene los horarios disponibles en una fecha para una cancha.
  static Future<List<Map<String, DateTime>>> getAvailableSlots({
    required String courtId,
    required DateTime date,
    required int slotDurationMinutes, // Duración mínima de una reserva (ej. 60 min)
    required TimeOfDay openingTime, // Horario de apertura
    required TimeOfDay closingTime, // Horario de cierre
  }) async {
    final reservations = await getReservationsForDate(courtId: courtId, date: date);
    final availableSlots = <Map<String, DateTime>>[];
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Convertir horarios de apertura y cierre a DateTime del día actual
    final openingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      openingTime.hour,
      openingTime.minute,
    );
    final closingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      closingTime.hour,
      closingTime.minute,
    );

    // Ajustar límites si el horario de cierre es antes del inicio
    DateTime currentSlotStart = openingDateTime.isAfter(startOfDay)
        ? openingDateTime
        : startOfDay;
    DateTime currentSlotEnd = currentSlotStart.add(Duration(minutes: slotDurationMinutes));

    while (currentSlotEnd.isBefore(endOfDay) && currentSlotStart.isBefore(closingDateTime)) {
      bool isAvailable = true;

      for (final reservation in reservations) {
        if (!(currentSlotEnd.isBefore(reservation.startTime) ||
            currentSlotStart.isAfter(reservation.endTime))) {
          isAvailable = false;
          break;
        }
      }

      if (isAvailable) {
        availableSlots.add({
          'start': currentSlotStart,
          'end': currentSlotEnd,
        });
      }

      currentSlotStart = currentSlotEnd;
      currentSlotEnd = currentSlotStart.add(Duration(minutes: slotDurationMinutes));
    }

    return availableSlots;
  }

  /// Verifica si un horario está disponible.
  static Future<bool> isSlotAvailable({
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final reservations = await getReservationsForDate(
      courtId: courtId,
      date: startTime,
    );

    for (final reservation in reservations) {
      if (!(endTime.isBefore(reservation.startTime) ||
          startTime.isAfter(reservation.endTime))) {
        return false;
      }
    }
    return true;
  }
}