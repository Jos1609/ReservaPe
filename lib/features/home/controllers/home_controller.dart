import 'package:flutter/material.dart';
import 'package:sintetico/models/empresa.dart';
import '../services/company_service.dart';

class HomeController extends ChangeNotifier {
  final CompanyService _companyService = CompanyService();
  List<CompanyModel> _companies = [];
  bool _isLoading = false;
  String _error = '';

  List<CompanyModel> get companies => _companies;
  bool get isLoading => _isLoading;
  String get error => _error;

  HomeController() {
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _companies = (await _companyService.getCompanies()).cast<CompanyModel>();
     
      _error = '';
    } catch (e) {
      _error = 'Error al cargar las empresas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}