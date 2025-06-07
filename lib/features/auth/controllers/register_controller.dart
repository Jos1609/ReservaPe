import 'package:flutter/material.dart';
import 'package:sintetico/models/cliente.dart';
import '../services/auth_service.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    // Validaciones
    if (firstName.isEmpty) {
      errorMessage = 'Por favor ingresa tus nombres';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (lastName.isEmpty) {
      errorMessage = 'Por favor ingresa tus apellidos';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (phone.isEmpty || phone.length < 9) {
      errorMessage = 'Por favor ingresa un número válido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (!email.contains('@')) {
      errorMessage = 'Por favor ingresa un correo válido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (password != confirmPassword) {
      errorMessage = 'Las contraseñas no coinciden';
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final userModel = UserModel(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );
      await _authService.registerUser(userModel, password);
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