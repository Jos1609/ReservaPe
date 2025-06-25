import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/utils/error_messages.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicia sesión con email y contraseña, retorna un mapa con el resultado.
  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user == null) {
        return {'success': false, 'error': ErrorMessages.authFailed};
      }

      String? userType = await _findUserType(user.uid);
      if (userType == null) {
        return {'success': false, 'error': ErrorMessages.userNotFound};
      }

      return {'success': true, 'userType': userType};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = ErrorMessages.wrongPassword;
          break;
        case 'user-not-found':
          errorMessage = ErrorMessages.userNotFound;
          break;
        case 'invalid-email':
          errorMessage = ErrorMessages.invalidEmailFormat;
          break;
        default:
          errorMessage = ErrorMessages.unexpectedError;
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': ErrorMessages.unexpectedError};
    }
  }

  /// Busca el tipo de usuario en las colecciones de Firestore.
  Future<String?> _findUserType(String userId) async {
    var clientDoc = await _firestore.collection('clients').doc(userId).get();
    if (clientDoc.exists) return 'cliente';

    var companyDoc = await _firestore.collection('companies').doc(userId).get();
    if (companyDoc.exists) return 'empresa';

    var adminDoc = await _firestore.collection('superadmins').doc(userId).get();
    if (adminDoc.exists) return 'superadmin';

    return null;
  }

 /// Verifica en qué colección está el usuario
  Future<String?> getUserCollection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Verificar en SuperAdmin
      final superAdminDoc = await _firestore.collection('SuperAdmin').doc(user.uid).get();
      if (superAdminDoc.exists) return 'SuperAdmin';

      // Verificar en empresas
      final companyDoc = await _firestore.collection('empresas').doc(user.uid).get();
      if (companyDoc.exists) return 'empresas';

      // Verificar en clients
      final clientDoc = await _firestore.collection('clients').doc(user.uid).get();
      if (clientDoc.exists) return 'clients';

      return null;
    } catch (e) {
      throw Exception('Error verificando colección: $e');
    }
  }

  /// Registra un nuevo usuario con email/contraseña y guarda datos en Firestore
  Future<User?> registerUser(UserModel user, String password) async {
    try {
      // Crear usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      // Guardar datos adicionales en Firestore con el mismo UID
      await _firestore.collection('clients').doc(userCredential.user!.uid).set({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phone': user.phone,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Envía un correo de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('El correo electrónico no es válido');
        case 'user-not-found':
          throw Exception('No existe una cuenta con este correo');
        case 'too-many-requests':
          throw Exception('Demasiados intentos. Intenta más tarde');
        default:
          throw Exception('Ocurrió un error al enviar el correo');
      }
    } catch (e) {
      throw Exception('Ocurrió un error al enviar el correo');
    }
  }
/// Verifica si el usuario es SuperAdmin
  Future<bool> isSuperAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('SuperAdmin').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error verificando permisos: $e');
    }
  }
/// Verifica si el usuario esta autenticado
  Future<bool> currentUser() async {
    try {
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      throw Exception('Error verificando autenticación: $e');
    }
  }

/// Crea un usuario con email y contraseña
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

/// Obtiene el ID del usuario autenticado actualmente.
  /// Retorna null si no hay usuario autenticado.
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}