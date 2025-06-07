import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecoveryController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<bool> recoverPassword(String email) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    if (email.isEmpty || !email.contains('@')) {
      errorMessage = 'Por favor ingresa un correo válido';
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      isSuccess = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}