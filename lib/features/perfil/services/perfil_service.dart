import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/models/empresa.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el tipo de usuario actual
  Future<String?> getUserType() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Verificar en cada colección
      final collections = ['clients', 'empresas', 'SuperAdmin'];
      
      for (String collection in collections) {
        final doc = await _firestore.collection(collection).doc(user.uid).get();
        if (doc.exists) {
          return collection;
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener tipo de usuario: $e');
      return null;
    }
  }

  // Obtener datos del cliente
  Future<UserModel?> getClientData(String uid) async {
    try {
      final doc = await _firestore.collection('clients').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener datos de la empresa
  Future<CompanyModel?> getCompanyData(String uid) async {
    try {
      final doc = await _firestore.collection('empresas').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return CompanyModel(
          id: uid,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          logo: data['logo'],
          openingTime: data['openingTime'] ?? '',
          closingTime: data['closingTime'] ?? '',
          services: List<String>.from(data['services'] ?? []),
          address: data['address'] ?? '',
          coordinates: Map<String, double>.from(data['coordinates'] ?? {'latitude': 0.0, 'longitude': 0.0}),
          status: data['status'] ?? 'Cerrado',
          email: data['email'],
          phoneNumber: data['phoneNumber'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener datos del SuperAdmin
  Future<UserModel?> getSuperAdminData(String uid) async {
    try {
      final doc = await _firestore.collection('SuperAdmin').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Actualizar datos del cliente
  Future<bool> updateClientData(String uid, UserModel userData) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'firstName': userData.firstName,
        'lastName': userData.lastName,
        'phone': userData.phone,
        'email': userData.email,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar datos de la empresa
  Future<bool> updateCompanyData(String uid, CompanyModel companyData) async {
    try {
      await _firestore.collection('empresas').doc(uid).update(companyData.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar datos del SuperAdmin
  Future<bool> updateSuperAdminData(String uid, UserModel userData) async {
    try {
      await _firestore.collection('SuperAdmin').doc(uid).update({
        'firstName': userData.firstName,
        'lastName': userData.lastName,
        'phone': userData.phone,
        'email': userData.email,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar contraseña
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-autenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}