import 'package:flutter/material.dart';
import 'package:sintetico/models/calificacion.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/services/firebase/companies_service.dart';
import '../../auth/services/auth_service.dart';

class CompaniesController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CompaniesService _companiesService = CompaniesService();
  List<CompanyModel> companies = [];
  Map<String, List<RatingModel>> ratings = {};
  bool isLoading = true;
  String? errorMessage;
  bool hasPermission = false;

  Future<void> checkPermissions() async {
    try {
      hasPermission = await _authService.isSuperAdmin();
      if (hasPermission) {
        await loadCompanies();
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error verificando permisos: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanies() async {
    try {
      companies = await _companiesService.getCompanies();
      for (var company in companies) {
        ratings[company.id] = await _companiesService.getRatingsForCompany(company.id);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error cargando empresas: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  double getAverageRating(String companyId) {
    final companyRatings = ratings[companyId] ?? [];
    if (companyRatings.isEmpty) return 0.0;
    final total = companyRatings.fold<double>(0, (sum, rating) => sum + rating.rating);
    return total / companyRatings.length;
  }
}