import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  
  Future<String> uploadLogo(File file) async {
    try {
      final ref = _storage
          .ref()
          .child('logos/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir logo: $e');
    }
  }

  Future<void> registerCompany(Map<String, dynamic> data, String id) async {
    try {
      await _firestore.collection('empresas').doc(id).set({
        ...data,
        'companyId': id,
      });
    } catch (e) {
      throw Exception('Error al registrar empresa: $e');
    }
  }

}