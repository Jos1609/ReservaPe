import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintetico/features/perfil/services/perfil_service.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/models/empresa.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  // Estados
  bool _isLoading = false;
  String? _userType;
  dynamic _userData; // Puede ser UserModel o CompanyModel
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get userType => _userType;
  dynamic get userData => _userData;
  String? get errorMessage => _errorMessage;
  bool get isCompany => _userType == 'empresas';

  // Inicializar datos del perfil
  Future<void> initializeProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtener tipo de usuario
      _userType = await _profileService.getUserType();
      
      if (_userType == null) {
        _errorMessage = 'No se pudo determinar el tipo de usuario';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Cargar datos según el tipo
      switch (_userType) {
        case 'clients':
          _userData = await _profileService.getClientData(user.uid);
          break;
        case 'empresas':
          _userData = await _profileService.getCompanyData(user.uid);
          break;
        case 'SuperAdmin':
          _userData = await _profileService.getSuperAdminData(user.uid);
          break;
      }

      if (_userData == null) {
        _errorMessage = 'No se pudieron cargar los datos del perfil';
      }
    } catch (e) {
      _errorMessage = 'Error al cargar el perfil: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualizar perfil
  Future<bool> updateProfile(dynamic updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool success = false;

      switch (_userType) {
        case 'clients':
          success = await _profileService.updateClientData(user.uid, updatedData as UserModel);
          break;
        case 'empresas':
          success = await _profileService.updateCompanyData(user.uid, updatedData as CompanyModel);
          break;
        case 'SuperAdmin':
          success = await _profileService.updateSuperAdminData(user.uid, updatedData as UserModel);
          break;
      }

      if (success) {
        _userData = updatedData;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al actualizar el perfil';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar contraseña
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _profileService.updatePassword(currentPassword, newPassword);
      
      if (!success) {
        _errorMessage = 'Contraseña actual incorrecta';
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al actualizar contraseña: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _profileService.signOut();
    // Limpiar datos
    _userData = null;
    _userType = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}