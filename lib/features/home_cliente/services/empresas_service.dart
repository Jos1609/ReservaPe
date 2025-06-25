import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/empresa.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CompanyModel>> getCompanies() {
    return _firestore.collection('empresas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CompanyModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
  
}