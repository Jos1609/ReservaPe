import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintetico/models/empresa.dart';

class CompanyService {
  final CollectionReference _companiesCollection =
      FirebaseFirestore.instance.collection('empresas');

  Future<List<CompanyModel>> getCompanies() async {
    try {
      final querySnapshot = await _companiesCollection.get();
      
      return querySnapshot.docs.map((doc) {
        // Combina los datos del documento con el ID
        final data = doc.data() as Map<String, dynamic>;
        return CompanyModel.fromMap(doc.id, data);
      }).toList();
      
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener empresas: $e');
      throw Exception('No se pudieron cargar las empresas: $e');
    }
  }
}