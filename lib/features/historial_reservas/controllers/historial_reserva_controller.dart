import 'package:flutter/material.dart';
import 'package:sintetico/features/historial_reservas/services/historial_reserva_service.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import 'package:sintetico/models/cancha.dart';

class ReservationHistoryController extends ChangeNotifier {
  final ReservationHistoryService _service = ReservationHistoryService();
  
  // Estados
  List<ReservationModel> _reservations = [];
  final Map<String, CourtModel> _courtsCache = {};
  final Map<String, CompanyModel> _companiesCache = {};
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'Todas'; // Todas, Pendiente, Confirmada, Rechazada, Cancelada
  UserReservationStats? _stats;
  
  // Stream subscription
  Stream<List<ReservationModel>>? _reservationsStream;

  // Getters
  List<ReservationModel> get reservations => _reservations;
  Map<String, CourtModel> get courtsCache => _courtsCache;
  Map<String, CompanyModel> get companiesCache => _companiesCache;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  UserReservationStats? get stats => _stats;
  
  // Filtrar reservas por estado
  List<ReservationModel> get filteredReservations {
    if (_selectedStatus == 'Todas') {
      return _reservations;
    }
    return _reservations.where((r) => r.status == _selectedStatus).toList();
  }

  // Obtener reservas agrupadas por estado
  Map<String, List<ReservationModel>> get groupedReservations {
    final Map<String, List<ReservationModel>> grouped = {
      'Pendiente': [],
      'Confirmada': [],
      'Rechazada': [],
      'Cancelada': [],
      'Completada': [],
    };

    for (final reservation in _reservations) {
      if (grouped.containsKey(reservation.status)) {
        grouped[reservation.status]!.add(reservation);
      }
    }

    return grouped;
  }

  // Inicializar
  void init() {
    _loadStats();
    _startListeningToReservations();
  }

  // Cargar estadísticas
  Future<void> _loadStats() async {
    try {
      _stats = await _service.getUserStats();
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error al cargar estadísticas: $e');
    }
  }

  // Escuchar cambios en las reservas
  void _startListeningToReservations() {
    _isLoading = true;
    notifyListeners();

    _reservationsStream = _service.streamUserReservations(
      statusFilter: _selectedStatus == 'Todas' ? null : _selectedStatus,
    );

    _reservationsStream?.listen(
      (reservations) async {
        _reservations = reservations;
        _isLoading = false;
        
        // Cargar información de canchas y empresas
        await _loadAdditionalInfo();
        
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar reservas: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Cargar información adicional (canchas y empresas)
  Future<void> _loadAdditionalInfo() async {
    for (final reservation in _reservations) {
      // Cargar cancha si no está en caché
      if (!_courtsCache.containsKey(reservation.courtId)) {
        final court = await _service.getCourtInfo(reservation.courtId);
        if (court != null) {
          _courtsCache[reservation.courtId] = court;
          
          // Cargar empresa si no está en caché
          if (!_companiesCache.containsKey(court.empresaId)) {
            final company = await _service.getCompanyInfo(court.empresaId);
            if (company != null) {
              _companiesCache[court.empresaId] = company;
            }
          }
        }
      }
    }
    notifyListeners();
  }

  // Cambiar filtro de estado
  void changeStatusFilter(String status) {
    _selectedStatus = status;
    _startListeningToReservations();
  }

  // Cancelar reserva
  Future<bool> cancelReservation(String reservationId, String reason) async {
    try {
      final success = await _service.cancelReservation(reservationId, reason);
      if (success) {
        await _loadStats(); // Actualizar estadísticas
      }
      return success;
    } catch (e) {
      _error = 'Error al cancelar la reserva';
      notifyListeners();
      return false;
    }
  }

  // Obtener cancha para una reserva
  CourtModel? getCourtForReservation(String courtId) {
    return _courtsCache[courtId];
  }

  // Obtener empresa para una cancha
  CompanyModel? getCompanyForCourt(String courtId) {
    final court = _courtsCache[courtId];
    if (court != null) {
      return _companiesCache[court.empresaId];
    }
    return null;
  }

  // Verificar si una reserva se puede cancelar
  bool canCancelReservation(ReservationModel reservation) {
    // Solo se pueden cancelar reservas pendientes o confirmadas
    // y que no hayan pasado
    return (reservation.status == 'Pendiente' || reservation.status == 'Confirmada') &&
           reservation.startTime.isAfter(DateTime.now());
  }

  @override
  void dispose() {
    _reservations.clear();
    _courtsCache.clear();
    _companiesCache.clear();
    super.dispose();
  }
}