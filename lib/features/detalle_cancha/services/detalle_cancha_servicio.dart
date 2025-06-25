import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';

class CourtDetailsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener detalles completos de una cancha
  Future<CourtModel?> getCourtDetails(String courtId) async {
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

  // Stream para escuchar cambios en tiempo real
  Stream<CourtModel?> streamCourtDetails(String courtId) {
    return _firestore.collection('canchas').doc(courtId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return CourtModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }

  // Obtener información de la empresa - ACTUALIZADO
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

  // Obtener reservas de una cancha para una fecha específica
  Future<List<ReservationModel>> getCourtReservations(
      String courtId, DateTime date) async {
    try {

      final querySnapshot = await _firestore
          .collection('reservas')
          .where('courtId', isEqualTo: courtId)
          .where('status', whereIn: ['Confirmada', 'Pendiente']).get();

      final reservationsForDate = querySnapshot.docs.where((doc) {
      final data = doc.data();
      final startTime = (data['startTime'] as Timestamp).toDate();
      
      // Verificar si la reserva es del día solicitado
      return startTime.year == date.year &&
             startTime.month == date.month &&
             startTime.day == date.day;
    }).toList();

    final reservations = reservationsForDate
        .map((doc) => ReservationModel.fromMap(doc.id, doc.data()))
        .toList();

      return reservations;
    } catch (e) {
      return [];
    }
  }

// Calcular horarios disponibles - ACTUALIZADO
  Future<List<TimeSlot>> getAvailableTimeSlots(
    String courtId,
    DateTime date,
    CompanyModel company,
  ) async {
    try {
      print(
          '\n=== getAvailableTimeSlots for ${date.toString().split(' ')[0]} ===');

      final reservations = await getCourtReservations(courtId, date);
      final List<TimeSlot> allSlots = [];
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      // Parsear horarios de apertura y cierre
      final openingHour = _parseTimeToHour(company.openingTime);
      final closingHour = _parseTimeToHour(company.closingTime);

      // Generar slots basados en el horario de la empresa
      for (int hour = openingHour; hour < closingHour; hour++) {
        final startTime = DateTime(date.year, date.month, date.day, hour, 0);
        final endTime = startTime.add(const Duration(hours: 1));

        // Si es hoy, verificar que el horario no haya pasado
        bool isPastTime = false;
        if (isToday) {
          final minimumStartTime = now.add(const Duration(minutes: 30));
          isPastTime = startTime.isBefore(minimumStartTime);
        }

        // Verificar si el slot está reservado
        bool isReserved = false;
        for (final reservation in reservations) {
          if (_isTimeOverlapping(
              startTime, endTime, reservation.startTime, reservation.endTime)) {
            isReserved = true;
            break;
          }
        }

        // El slot está disponible si no está en el pasado ni reservado
        bool isAvailable = !isPastTime && !isReserved;

        allSlots.add(TimeSlot(
          startTime: startTime,
          endTime: endTime,
          isAvailable: isAvailable,
          isPastTime: isPastTime,
          isReserved: isReserved,
        ));
      }

      print(
          'Summary: ${allSlots.where((s) => s.isReserved).length} reserved slots out of ${allSlots.length}');

      return allSlots;
    } catch (e) {
      print('ERROR in getAvailableTimeSlots: $e');
      return [];
    }
  }

  // Parsear hora en formato "HH:mm AM/PM" a entero de hora
  int _parseTimeToHour(String time) {
    try {
      // Limpiar espacios en blanco
      final cleanTime = time.trim();

      // Separar la hora del AM/PM
      final isAM = cleanTime.toUpperCase().contains('AM');
      final isPM = cleanTime.toUpperCase().contains('PM');

      // Remover AM/PM del string
      final timeWithoutAmPm =
          cleanTime.replaceAll(RegExp(r'[AaPp][Mm]'), '').trim();

      // Obtener la hora
      final parts = timeWithoutAmPm.split(':');
      if (parts.isEmpty) return 8;

      var hour = int.tryParse(parts[0]) ?? 8;

      // Convertir a formato 24 horas
      if (isPM && hour != 12) {
        // PM: sumar 12 horas (excepto para 12 PM que ya es mediodía)
        hour += 12;
      } else if (isAM && hour == 12) {
        // 12 AM es medianoche (00:00)
        hour = 0;
      }

      // Validar que esté en rango válido
      if (hour < 0 || hour > 23) {
        return 8;
      }

      return hour;
    } catch (e) {
      return 8; // Valor por defecto
    }
  }

  // Verificar si dos rangos de tiempo se superponen
  bool _isTimeOverlapping(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
}

// Modelo para representar un slot de tiempo
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final bool isPastTime;
  final bool isReserved;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.isPastTime = false,
    this.isReserved = false,
  });
}
