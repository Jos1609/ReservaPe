import 'package:flutter/material.dart';
import 'package:sintetico/features/detalle_cancha/services/detalle_cancha_servicio.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/cancha.dart';

class CourtDetailsController extends ChangeNotifier {
  final CourtDetailsService _service = CourtDetailsService();

  // Estados
  CourtModel? _court;
  CompanyModel? _company; // Cambiado de Map a CompanyModel
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _timeSlots = [];
  final List<TimeSlot> _selectedSlots = [];
  int _currentPhotoIndex = 0;
  double _totalPrice = 0.0;

  // Getters
  CourtModel? get court => _court;
  CompanyModel? get company => _company; // Actualizado
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  List<TimeSlot> get timeSlots => _timeSlots;
  List<TimeSlot> get selectedSlots => _selectedSlots;
  int get currentPhotoIndex => _currentPhotoIndex;
  double get totalPrice => _totalPrice;

  // Getters adicionales para la selección múltiple
  DateTime? get startTime =>
      _selectedSlots.isNotEmpty ? _selectedSlots.first.startTime : null;

  DateTime? get endTime =>
      _selectedSlots.isNotEmpty ? _selectedSlots.last.endTime : null;

  int get totalHours => _selectedSlots.length;

  // Cargar detalles de la cancha
  Future<void> loadCourtDetails(String courtId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _court = await _service.getCourtDetails(courtId);

      if (_court != null) {
        // Cargar información de la empresa
        _company = await _service.getCompanyInfo(_court!.empresaId);

        if (_company != null) {
          // Cargar horarios disponibles para la fecha actual
          await loadAvailableSlots(_selectedDate);
        } else {
          _error = 'No se pudo cargar la información de la empresa';
        }
      } else {
        _error = 'No se pudo cargar la información de la cancha';
      }
    } catch (e) {
      _error = 'Error al cargar los detalles: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cargar slots disponibles para una fecha
  Future<void> loadAvailableSlots(DateTime date) async {
    if (_court == null || _company == null) return;

    try {
      // Limpiar slots anteriores antes de cargar nuevos
      _timeSlots = [];
      notifyListeners();

      // Cargar nuevos slots
      _timeSlots = await _service.getAvailableTimeSlots(
        _court!.id,
        date,
        _company!,
      );

      _selectedSlots.clear();
      _totalPrice = 0.0;

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error al cargar slots: $e');
    }
  }

  // Cambiar fecha seleccionada
  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedSlots.clear(); // Limpiar selección
    _timeSlots.clear(); // Limpiar slots anteriores
    notifyListeners(); // Notificar cambios inmediatamente
    loadAvailableSlots(date); // Cargar nuevos slots
  }

  // Seleccionar o deseleccionar un slot de tiempo
  void toggleTimeSlot(TimeSlot slot) {
    if (!slot.isAvailable || slot.isPastTime || _court == null) return;

    // Si el slot ya está seleccionado, lo quitamos
    if (_selectedSlots.contains(slot)) {
      _removeSlot(slot);
    } else {
      // Si no hay slots seleccionados, simplemente agregamos
      if (_selectedSlots.isEmpty) {
        _selectedSlots.add(slot);
      } else {
        // Verificar si el slot es consecutivo
        if (_isConsecutiveSlot(slot)) {
          _addSlot(slot);
        } else {
          // Si no es consecutivo, limpiamos la selección y empezamos de nuevo
          _selectedSlots.clear();
          _selectedSlots.add(slot);
        }
      }
    }

    _calculateTotalPrice();
    notifyListeners();
  }

  // Verificar si un slot es consecutivo a los ya seleccionados
  bool _isConsecutiveSlot(TimeSlot slot) {
    if (_selectedSlots.isEmpty) return true;

    // Ordenar los slots seleccionados
    final sortedSlots = List<TimeSlot>.from(_selectedSlots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final firstSlot = sortedSlots.first;
    final lastSlot = sortedSlots.last;

    // Verificar si es inmediatamente antes del primero
    if (slot.endTime.isAtSameMomentAs(firstSlot.startTime)) {
      return true;
    }

    // Verificar si es inmediatamente después del último
    if (slot.startTime.isAtSameMomentAs(lastSlot.endTime)) {
      return true;
    }

    return false;
  }

  // Verificar si un slot puede ser seleccionado
  bool canSelectSlot(TimeSlot slot) {
    if (!slot.isAvailable || slot.isPastTime || slot.isReserved) return false;
    if (_selectedSlots.isEmpty) return true;
    return _isConsecutiveSlot(slot);
  }

  // Agregar un slot a la selección
  void _addSlot(TimeSlot slot) {
    _selectedSlots.add(slot);
    // Mantener los slots ordenados
    _selectedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Quitar un slot de la selección
  void _removeSlot(TimeSlot slot) {
    final index = _selectedSlots.indexOf(slot);
    if (index == -1) return;

    // Si es el slot del medio, no permitir quitarlo
    if (_selectedSlots.length > 2 &&
        index != 0 &&
        index != _selectedSlots.length - 1) {
      return;
    }

    _selectedSlots.remove(slot);
  }

  // Calcular precio total
  void _calculateTotalPrice() {
    if (_court == null || _selectedSlots.isEmpty) {
      _totalPrice = 0.0;
      return;
    }

    _totalPrice = 0.0;
    for (final slot in _selectedSlots) {
      final isNightTime = slot.startTime.hour >= 18;
      _totalPrice += isNightTime ? _court!.nightPrice : _court!.dayPrice;
    }
  }

  // Limpiar selección
  void clearSelection() {
    _selectedSlots.clear();
    _totalPrice = 0.0;
    notifyListeners();
  }

  // Cambiar foto actual en el carrusel
  void changePhotoIndex(int index) {
    _currentPhotoIndex = index;
    notifyListeners();
  }

  // Limpiar controller
  @override
  void dispose() {
    _court = null;
    _company = null;
    _timeSlots = [];
    _selectedSlots.clear();
    _currentPhotoIndex = 0;
    _totalPrice = 0.0;
    super.dispose();
  }
}
