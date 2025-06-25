import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/cancha.dart';

class ReservationModel {
  final String id;
  final String courtId;
  final String clientName;
  final String clientPhone;
  final String clientAvatarUrl;
  final String? clientId; // Added optional clientId
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final String? cancellationReason;
  final String comprobantePago;
  final List<String> metodosPago;

  ReservationModel({
    required this.id,
    required this.courtId,
    required this.clientName,
    required this.clientPhone,
    required this.clientAvatarUrl,
    this.clientId, // Added to constructor
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
      clientId: data['clientId'], // Added to fromMap
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
      if (clientId != null) 'clientId': clientId, // Added to toMap
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'comprobantePago': comprobantePago,
      'metodosPago': metodosPago,
    };
  }

  static double calculateTotalPrice({
    required DateTime startTime,
    required DateTime endTime,
    required CourtModel court,
  }) {
    const int dayStartHour = 6;
    const int nightStartHour = 18;

    double totalPrice = 0.0;
    double hours = endTime.difference(startTime).inMinutes / 60.0;

    final startHour = startTime.hour;
    if (startHour >= dayStartHour && startHour < nightStartHour) {
      final endHour = endTime.hour;
      if (endHour < nightStartHour) {
        totalPrice = hours * court.dayPrice;
      } else {
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
      totalPrice = hours * court.nightPrice;
    }

    return totalPrice;
  }
}