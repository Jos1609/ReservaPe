import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sintetico/features/admin_empresas/services/registrar_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:sintetico/features/auth/services/auth_service.dart';

class RegisterCompanyController extends ChangeNotifier {
  final CompanyService _companyService = CompanyService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Controladores de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  
  
  // Variables de estado
  String? status;
  XFile? logo;
  List<String> services = [];
  bool isLoading = false;
  String? errorMessage;
  LatLng? selectedPosition; // Ahora usa LatLng de latlong2

  // Método para actualizar coordenadas desde el mapa
  void updateCoordinates(double latitude, double longitude) {
    selectedPosition = LatLng(latitude, longitude);
    latitudeController.text = latitude.toString();
    longitudeController.text = longitude.toString();
    notifyListeners();
  }

  // Método para agregar servicio
  void addService() {
    final service = serviceController.text.trim();
    if (service.isNotEmpty && !services.contains(service)) {
      services.add(service);
      serviceController.clear();
      notifyListeners();
    }
  }

  // Método para eliminar servicio
  void removeService(String service) {
    services.remove(service);
    notifyListeners();
  }

  // Método para seleccionar logo
  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedLogo = await picker.pickImage(source: ImageSource.gallery);
    if (pickedLogo != null) {
      logo = pickedLogo;
      notifyListeners();
    }
  }

  // Método para seleccionar hora
  Future<void> selectTime(BuildContext context, {required bool isOpening}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      final formattedTime = picked.format(context);
      if (isOpening) {
        openingTimeController.text = formattedTime;
      } else {
        closingTimeController.text = formattedTime;
      }
      notifyListeners();
    }
  }

  // Método para registrar empresa
  Future<void> registerCompany(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      errorMessage = 'Por favor corrige los errores en el formulario';
      notifyListeners();
      return;
    }

    // Validación adicional de coordenadas
    if (selectedPosition == null) {
      errorMessage = 'Por favor selecciona una ubicación en el mapa';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Subir logo (si existe)
      String? logoUrl;
      if (logo != null) {
        logoUrl = await _companyService.uploadLogo(File(logo!.path));
      }
      final email = emailController.text.trim();
      final password = '${nameController.text.trim()}2025@';

      // ignore: non_constant_identifier_names
      final UserCredential = await _authService.createUserWithEmailAndPassword(
        email,
         password,
      );

      if (UserCredential == null) {
        throw Exception('Error al crear usuario');
      }

      final userId = UserCredential.uid;

      // Guardar en Firestore
      await _companyService.registerCompany({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'description': descriptionController.text.trim(),
        'logo': logoUrl,
        'openingTime': openingTimeController.text,
        'closingTime': closingTimeController.text,
        'services': services,
        'address': addressController.text.trim(),
        'coordinates': {
          'latitude': selectedPosition!.latitude,
          'longitude': selectedPosition!.longitude,
        },
        'status': status,
        'createdAt': DateTime.now(),
        'phoneNumber': phoneController.text.trim(), 
        
      }, userId);

      isLoading = false;
      notifyListeners();
      
      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa registrada correctamente')),
      );
      
      // Esperar un momento antes de cerrar
      await Future.delayed(const Duration(milliseconds: 500));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    serviceController.dispose();
    super.dispose();
  }
}