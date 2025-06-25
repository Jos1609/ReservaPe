import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sintetico/features/home_cliente/services/empresas_service.dart';
import 'package:sintetico/models/empresa.dart';

class CompaniesController extends ChangeNotifier {
  final FirestoreService _firestoreService;
  String _searchQuery = '';
  String? _selectedStatus;

  CompaniesController(this._firestoreService);

  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void updateStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Stream<List<CompanyModel>> getFilteredCompanies() {
    return _firestoreService.getCompanies().map((companies) {
      return companies.where((company) {
        final matchesSearch = company.name.toLowerCase().contains(_searchQuery) ||
            company.description.toLowerCase().contains(_searchQuery);
        final matchesStatus = _selectedStatus == null || company.status == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }
}