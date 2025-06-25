import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sintetico/features/reservas/services/reservacion_service.dart';
import 'package:sintetico/features/reservas/services/verificar_horarios.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';

class NewReservationController extends ChangeNotifier {
  final CourtModel court;
  final String enterpriseId;
  String clientName = '';
  String clientPhone = '';
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? paymentMethod;
  XFile? receiptImage;
  double totalPrice = 0.0;
  bool isLoading = false;  
  List<Map<String, DateTime>> availableSlots = [];

  NewReservationController({required this.court, required this.enterpriseId});

  void setClientName(String name) {
    clientName = name;
    notifyListeners();
  }

  void setClientPhone(String phone) {
    clientPhone = phone;
    notifyListeners();
  }

  Future<void> setDateTime(DateTime? start, DateTime? end) async {
    if (start != null && end != null) {
      // Verificar disponibilidad
      final isAvailable = await AvailabilityService.isSlotAvailable(
        courtId: court.id,
        startTime: start,
        endTime: end,
      );

      if (!isAvailable) {
        startDateTime = null;
        endDateTime = null;
        totalPrice = 0.0;
        notifyListeners();
        return;
      }
    }

    startDateTime = start;
    endDateTime = end;
    _calculatePrice();
    notifyListeners();
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    availableSlots = await AvailabilityService.getAvailableSlots(
      courtId: court.id,
      date: date,
      slotDurationMinutes: 60, // Reservas de 1 hora
      openingTime: TimeOfDay(hour: 8, minute: 0), // Horario de apertura
      closingTime: TimeOfDay(hour: 22, minute: 0), // Horario de cierre
    );
    notifyListeners();
  }

  void setPaymentMethod(String? method) {
    paymentMethod = method;
    notifyListeners();
  }

  void setReceiptImage(XFile? image) {
    receiptImage = image;
    notifyListeners();
  }

  void _calculatePrice() {
    if (startDateTime != null && endDateTime != null) {
      final durationHours =
          endDateTime!.difference(startDateTime!).inMinutes / 60.0;
      final isNight = startDateTime!.hour >= 18; // Considerar noche después de las 6 PM
      final pricePerHour = isNight ? court.nightPrice : court.dayPrice;

      totalPrice = durationHours * pricePerHour;
    } else {
      totalPrice = 0.0;
    }
  }

  Future<bool> submitReservation(BuildContext context) async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos requeridos')),
      );
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Crear modelo de reserva
      final reservation = ReservationModel(
        id: '',
        courtId: court.id,
        clientName: clientName,
        clientPhone: clientPhone,
        clientAvatarUrl: '',
        clientId: enterpriseId,
        startTime: startDateTime!,
        endTime: endDateTime!,
        totalPrice: totalPrice,
        status: 'Confirmada',
        comprobantePago: '',
        metodosPago: [paymentMethod!],
      );

      // Usar ReservationService para crear la reserva
      await ReservationService.createReservation(
        courtId: court.id,
        reservation: reservation,
        receiptFile: receiptImage != null ? File(receiptImage!.path) : null,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      
      isLoading = false;
      notifyListeners();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear reserva: $e')),
      );
      return false;
    }
  }

  bool _validateForm() {
    return clientName.isNotEmpty &&
        clientPhone.isNotEmpty &&
        startDateTime != null &&
        endDateTime != null &&
        paymentMethod != null &&
        receiptImage != null &&
        endDateTime!.isAfter(startDateTime!);
  }
}