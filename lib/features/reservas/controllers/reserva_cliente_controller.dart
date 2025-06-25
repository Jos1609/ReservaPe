import 'package:flutter/material.dart';
import 'package:sintetico/features/reservas/services/reserva_cliente_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationController extends ChangeNotifier {
  final ReservationService _service = ReservationService();
  
  // Estados
  bool _isLoading = false;
  String? _error;
  
  // Datos de la reserva
  CourtModel? _court;
  CompanyModel? _company;
  DateTime? _startTime;
  DateTime? _endTime;
  double _totalPrice = 0.0;
  double _depositAmount = 0.0;
  double _remainingAmount = 0.0;
  
  // Datos del cliente (ahora viene del usuario autenticado)
  UserModel? _currentUser;
  String _alternativePhone = ''; // Por si quiere usar otro número
  
  // Pago
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  File? _receiptImage;
  String? _uploadedReceiptUrl;
  
  // Estado de la reserva
  String? _reservationId;
  bool _isReservationComplete = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  CourtModel? get court => _court;
  CompanyModel? get company => _company;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  double get totalPrice => _totalPrice;
  double get depositAmount => _depositAmount;
  double get remainingAmount => _remainingAmount;
  UserModel? get currentUser => _currentUser;
  String get clientName => _currentUser != null 
      ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
      : '';
  String get clientPhone => _alternativePhone.isNotEmpty 
      ? _alternativePhone 
      : (_currentUser?.phone ?? '');
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  File? get receiptImage => _receiptImage;
  String? get uploadedReceiptUrl => _uploadedReceiptUrl;
  String? get reservationId => _reservationId;
  bool get isReservationComplete => _isReservationComplete;

  // Inicializar datos de la reserva
  Future<void> initializeReservation({
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar información del usuario actual
      _currentUser = await _service.getCurrentUserInfo();
      
      if (_currentUser == null) {
        _error = 'No se pudo obtener la información del usuario';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Cargar información de la cancha
      _court = await _service.getCourtInfo(courtId);
      
      if (_court != null) {
        // Cargar información de la empresa
        _company = await _service.getCompanyInfo(_court!.empresaId);
      }

      // Establecer datos de la reserva
      _startTime = startTime;
      _endTime = endTime;
      _totalPrice = totalPrice;
      
      // Calcular montos (50% de adelanto)
      _depositAmount = totalPrice * 0.5;
      _remainingAmount = totalPrice - _depositAmount;

      // Cargar métodos de pago disponibles
      _paymentMethods = await _service.getAvailablePaymentMethods();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar información: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar teléfono alternativo (opcional)
  void updateAlternativePhone(String phone) {
    _alternativePhone = phone;
    notifyListeners();
  }

  // Seleccionar método de pago
  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Establecer imagen del comprobante
  void setReceiptImage(File image) {
    _receiptImage = image;
    notifyListeners();
  }

  // Confirmar reserva
  Future<bool> confirmReservation() async {
    if (_court == null || _receiptImage == null || 
        _selectedPaymentMethod == null || _startTime == null || 
        _endTime == null || _currentUser == null) {
      _error = 'Faltan datos para completar la reserva';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validar disponibilidad
      final isAvailable = await _service.validateAvailability(
        _court!.id,
        _startTime!,
        _endTime!,
      );

      if (!isAvailable) {
        _error = 'El horario seleccionado ya no está disponible';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Subir comprobante
      _uploadedReceiptUrl = await _service.uploadPaymentReceipt(_receiptImage!);
      
      if (_uploadedReceiptUrl == null) {
        _error = 'Error al subir el comprobante de pago';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener usuario actual para el ID
      final user = FirebaseAuth.instance.currentUser;

      // Crear modelo de reserva
      final reservation = ReservationModel(
        id: '', // Se generará en Firebase
        courtId: _court!.id,
        clientId: user?.uid,
        clientName: clientName,
        clientPhone: clientPhone,
        clientAvatarUrl: user?.photoURL ?? '',
        startTime: _startTime!,
        endTime: _endTime!,
        totalPrice: _totalPrice,
        status: 'Pendiente', // Estado inicial
        comprobantePago: _uploadedReceiptUrl!,
        metodosPago: [_selectedPaymentMethod!.id],
      );

      // Crear reserva usando el modelo
      _reservationId = await _service.createReservation(reservation);

      if (_reservationId != null) {
        _isReservationComplete = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al crear la reserva';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al confirmar reserva: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Compartir reserva
  Future<void> shareReservation() async {
    if (_court == null || _company == null || _startTime == null) return;

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    final message = '''
🏟️ ¡Reserva Confirmada!

📍 Cancha: ${_court!.name}
🏢 Lugar: ${_company!.name}
📅 Fecha: ${dateFormat.format(_startTime!)}
⏰ Hora: ${timeFormat.format(_startTime!)} - ${timeFormat.format(_endTime!)}
💰 Total: S/ ${_totalPrice.toStringAsFixed(2)}
💳 Adelanto pagado: S/ ${_depositAmount.toStringAsFixed(2)}
📞 Contacto: $clientPhone

¡Nos vemos en la cancha! ⚽
    ''';

    await Share.share(message);
  }

  // Abrir navegación en Google Maps
  Future<void> openNavigation() async {
    if (_company == null) return;

    final lat = _company!.coordinates['latitude'] ?? 0.0;
    final lng = _company!.coordinates['longitude'] ?? 0.0;
    
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _error = 'No se pudo abrir Google Maps';
      notifyListeners();
    }
  }

  // Limpiar controller
  @override
  void dispose() {
    _court = null;
    _company = null;
    _currentUser = null;
    _receiptImage = null;
    _selectedPaymentMethod = null;
    _isReservationComplete = false;
    super.dispose();
  }
}