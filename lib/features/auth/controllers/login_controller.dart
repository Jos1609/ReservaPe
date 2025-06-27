import 'package:flutter/material.dart';
import 'package:sintetico/features/auth/components/modal_erores.dart';
import '../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool _rememberMe = false;

  bool get rememberMe => _rememberMe;
  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> authenticateUser({
    required String email, 
    required String password
  }) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      // 1. Autenticar al usuario
      await _authService.signInWithEmailAndPassword(email, password);
      
      // 2. Obtener información adicional del usuario (como su rol)
      final collection = await _authService.getUserCollection();
      
      isLoading = false;
      notifyListeners();
      
      // Retornamos un mapa con la información necesaria para la redirección
      return {
        'success': true,
        'userCollection': collection,
        // Puedes agregar más datos aquí si los necesitas
      };
    } catch (e) {
      isLoading = false;
      _handleLoginError(e);
      notifyListeners();
      return null;
    }
  }

  void _handleLoginError(dynamic error) {
    print('🔴 Error capturado: ${error.toString()}'); // Debug
    
    switch (error.toString()) {
      case 'Exception: [firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.':
        errorMessage = 'Correo no registrado';
        break;
      case 'Exception: [firebase_auth/wrong-password] The password is invalid or the user does not have a password.':
        errorMessage = 'Contraseña incorrecta';
        break;
      case 'Exception: [firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.':
        errorMessage = 'Demasiados intentos. Intenta de nuevo más tarde';
        break;
      case 'Exception: [firebase_auth/invalid-email] The email address is badly formatted.':
        errorMessage = 'Correo inválido';
        break;
      default:
        errorMessage = 'Error al iniciar sesión: ${error.toString().replaceFirst('Exception: ', '')}';
    }
    
    print('🔴 ErrorMessage establecido: $errorMessage'); // Debug
  }

  Future<void> handleLogin(BuildContext context) async {
    // Limpiar mensaje de error previo
    errorMessage = null;
    notifyListeners();
    
    if (formKey.currentState?.validate() ?? false) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final authResult = await authenticateUser(
        email: email, 
        password: password
      );

      // Solo si la autenticación fue exitosa
      if (authResult != null && 
          authResult['success'] == true && 
          authResult['userCollection'] != null) {
        
        if (context.mounted) {
          Navigator.of(context).pop(); // Cerrar modal de login
          _redirectBasedOnRole(context, authResult['userCollection']);
        }
      } else {
        // Si hay error, mostrar modal de error
        if (context.mounted) {
          await _showErrorModal(context);
        }
      }
    }
  }

  Future<void> _showErrorModal(BuildContext context) async {
    // Determinar el mensaje específico del error
    String errorTitle = 'Error al iniciar sesión';
    String errorMsg = errorMessage ?? 'Verifica tus credenciales e intenta nuevamente';
    
    // Personalizar el mensaje según el tipo de error
    if (errorMessage?.contains('Correo no registrado') == true) {
      errorTitle = 'Usuario no encontrado';
      errorMsg = 'El correo electrónico no está registrado en nuestro sistema.';
    } else if (errorMessage?.contains('Contraseña incorrecta') == true) {
      errorTitle = 'Contraseña incorrecta';
      errorMsg = 'La contraseña ingresada no es correcta. Verifica e intenta nuevamente.';
    } else if (errorMessage?.contains('Demasiados intentos') == true) {
      errorTitle = 'Cuenta bloqueada temporalmente';
      errorMsg = 'Se han realizado demasiados intentos. Espera unos minutos antes de intentar nuevamente.';
    } else if (errorMessage?.contains('Correo inválido') == true) {
      errorTitle = 'Correo inválido';
      errorMsg = 'El formato del correo electrónico no es válido.';
    }

    await ErrorModal.show(
      context,
      title: errorTitle,
      message: errorMsg,
      buttonText: 'Intentar de nuevo',
      onPressed: () {
        // Limpiar campos si es necesario
        if (errorMessage?.contains('Correo inválido') == true) {
          emailController.clear();
        }
        if (errorMessage?.contains('Contraseña incorrecta') == true) {
          passwordController.clear();
        }
        // Limpiar el error
        errorMessage = null;
        notifyListeners();
      },
    );
  }

  void _redirectBasedOnRole(BuildContext context, String? userCollection) {
    switch (userCollection) {
      case 'SuperAdmin':
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
        break;
      case 'empresas':
        Navigator.of(context).pushReplacementNamed('/empresa_dashboard');
        break; 
      case 'clients':
        Navigator.of(context).pushReplacementNamed('/cliente_dashboard');
        break;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}