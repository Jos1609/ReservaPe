import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/cancha.dart';

class ReservationModel {
  final String id;
  final String courtId;
  final String clientName;
  final String clientPhone;
  final String clientAvatarUrl;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final String? cancellationReason;
  final String comprobantePago; // URL de la foto del comprobante de pago
  final List<String> metodosPago; // Lista de métodos de pago

  ReservationModel({
    required this.id,
    required this.courtId,
    required this.clientName,
    required this.clientPhone,
    required this.clientAvatarUrl,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.cancellationReason,
    required this.comprobantePago,
    required this.metodosPago,
  });

  factory ReservationModel.fromMap(String id, Map<String, dynamic> data) {
    return ReservationModel(
      id: id,
      courtId: data['courtId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      clientAvatarUrl: data['clientAvatarUrl'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pendiente',
      cancellationReason: data['cancellationReason'],
      comprobantePago: data['comprobantePago'] ?? '',
      metodosPago: List<String>.from(data['metodosPago'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courtId': courtId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientAvatarUrl': clientAvatarUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'comprobantePago': comprobantePago,
      'metodosPago': metodosPago,
    };
  }

  // Método para calcular el precio total basado en horarios diurnos y nocturnos
  static double calculateTotalPrice({
    required DateTime startTime,
    required DateTime endTime,
    required CourtModel court,
  }) {
    const int dayStartHour = 6; // 6:00 AM - Inicio del horario diurno
    const int nightStartHour = 18; // 6:00 PM - Inicio del horario nocturno

    double totalPrice = 0.0;
    double hours = endTime.difference(startTime).inMinutes / 60.0;

    // Determinar si la reserva es completamente diurna, nocturna o mixta
    final startHour = startTime.hour;
    if (startHour >= dayStartHour && startHour < nightStartHour) {
      // Comienza en horario diurno
      final endHour = endTime.hour;
      if (endHour < nightStartHour) {
        // Toda la reserva es diurna
        totalPrice = hours * court.dayPrice;
      } else {
        // Reserva mixta: parte diurna y parte nocturna
        final diurnalEnd = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          nightStartHour,
        );
        final diurnalHours =
            diurnalEnd.difference(startTime).inMinutes / 60.0;
        final nocturnalHours =
            endTime.difference(diurnalEnd).inMinutes / 60.0;
        totalPrice = (diurnalHours * court.dayPrice) +
            (nocturnalHours * court.nightPrice);
      }
    } else {
      // Comienza en horario nocturno
      totalPrice = hours * court.nightPrice;
    }

    return totalPrice;
  }
}