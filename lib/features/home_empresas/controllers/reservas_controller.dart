import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintetico/features/home_empresas/services/home_service.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';

/// Controlador para la vista de reservas, maneja la lógica de negocio y estado.
class ReservationsController extends ChangeNotifier {
  final CourtModel court;
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String _filter = 'Todas';

  ReservationsController({required this.court});

  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedDate => _selectedDate;
  String get filter => _filter;

  /// Cambia el mes seleccionado y notifica a los listeners.
  void changeMonth(int increment) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment);
    notifyListeners();
  }

  /// Cambia la fecha seleccionada y notifica a los listeners.
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Cambia el filtro de reservas y notifica a los listeners.
  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  /// Obtiene el stream de reservas para un mes específico.
  Stream<Map<DateTime, List<ReservationModel>>> getReservationsForMonth() {
    return HomeEmpresaService.getCourtReservationsForMonth(
      courtId: court.id,
      month: _selectedMonth,
    );
  }

  /// Obtiene el stream de reservas para una fecha específica.
  Stream<List<ReservationModel>> getReservationsForDate() {
    return HomeEmpresaService.getCourtReservations(
      courtId: court.id,
      selectedDate: _selectedDate,
    );
  }

  /// Confirma una reserva y muestra un mensaje de éxito o error.
  Future<void> confirmReservation(BuildContext context, ReservationModel reservation) async {
    try {
      await HomeEmpresaService.updateReservationStatus(
        courtId: court.id,
        reservationId: reservation.id,
        status: 'Confirmada',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva confirmada')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Rechaza una reserva y muestra un mensaje de éxito o error.
  Future<void> rejectReservation(BuildContext context, ReservationModel reservation) async {
    try {
      await HomeEmpresaService.updateReservationStatus(
        courtId: court.id,
        reservationId: reservation.id,
        status: 'Cancelada',
        cancellationReason: 'Rechazada por el administrador',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva rechazada')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Cancela una reserva y muestra un mensaje de éxito o error.
  Future<void> cancelReservation(BuildContext context, ReservationModel reservation) async {
    try {
      await HomeEmpresaService.updateReservationStatus(
        courtId: court.id,
        reservationId: reservation.id,
        status: 'Cancelada',
        cancellationReason: 'Cancelada por el administrador',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Muestra los detalles de una reserva en un diálogo.
  void showReservationDetails(BuildContext context, ReservationModel reservation) {
    final timeFormat = DateFormat('HH:mm', 'es');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Reserva'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${reservation.clientName}'),
              Text('Teléfono: ${reservation.clientPhone}'),
              Text(
                  'Horario: ${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}'),
              Text('Total: \$${reservation.totalPrice.toStringAsFixed(0)}'),
              Text('Estado: ${reservation.status}'),
              if (reservation.comprobantePago.isNotEmpty)
                Text('Comprobante: ${reservation.comprobantePago}'),
              Text('Métodos de Pago: ${reservation.metodosPago.join(', ')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}