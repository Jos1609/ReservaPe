import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/home_empresas/services/home_service.dart';
import 'package:sintetico/models/cancha.dart';

class AddCourtModal extends StatefulWidget {
  final CourtModel? court; // Cancha para editar (null para crear nueva)
  
  const AddCourtModal({super.key, this.court});

  @override
  State<AddCourtModal> createState() => _AddCourtModalState();

  static void show(BuildContext context, {CourtModel? court}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddCourtModal(court: court);
      },
    );
  }
}

class _AddCourtModalState extends State<AddCourtModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sportTypeController = TextEditingController();
  final _dayPriceController = TextEditingController();
  final _nightPriceController = TextEditingController();
  final _teamCapacityController = TextEditingController();
  final _materialController = TextEditingController();
  bool _hasRoof = false;
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.court != null;
    if (_isEditing) {
      _loadCourtData();
    }
  }

  void _loadCourtData() {
    final court = widget.court!;
    _nameController.text = court.name;
    _sportTypeController.text = court.sportType;
    _dayPriceController.text = court.dayPrice.toString();
    _nightPriceController.text = court.nightPrice.toString();
    _teamCapacityController.text = court.teamCapacity.toString();
    _materialController.text = court.material;
    _hasRoof = court.hasRoof;
    
    // Cargar fotos existentes (convertir de String paths a XFile)
    _selectedImages = court.photos.map((path) => XFile(path)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportTypeController.dispose();
    _dayPriceController.dispose();
    _nightPriceController.dispose();
    _teamCapacityController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = HomeEmpresaService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }
      
      // Convertir las imágenes a una lista de strings (paths)
      List<String> photoPaths = _selectedImages.map((image) => image.path).toList();
      
      final court = CourtModel(
        id: _isEditing ? widget.court!.id : '', // Mantener ID si es edición
        empresaId: userId,
        name: _nameController.text,
        sportType: _sportTypeController.text,
        photos: photoPaths,
        dayPrice: double.parse(_dayPriceController.text),
        nightPrice: double.parse(_nightPriceController.text),
        hasRoof: _hasRoof,
        teamCapacity: int.parse(_teamCapacityController.text),
        material: _materialController.text,
      );
      
      try {
        if (_isEditing) {
          await HomeEmpresaService.updateCourt(court);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancha ${court.name} actualizada con éxito')),
          );
        } else {
          await HomeEmpresaService.addCourt(court);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancha ${court.name} agregada con éxito')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al ${_isEditing ? 'actualizar' : 'agregar'} cancha: $e')),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // Limitar a máximo 5 imágenes
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.take(5).toList();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
          // Limitar a máximo 5 imágenes
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.take(5).toList();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Agregar Fotos',
              style: AppTextStyles.heading3(context),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add photo button
        InkWell(
          onTap: _showImageOptions,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Agregar fotos',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Máximo 5 fotos',
                  style: AppTextStyles.body(context).copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Selected images grid
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            '${_selectedImages.length} foto${_selectedImages.length > 1 ? 's' : ''} seleccionada${_selectedImages.length > 1 ? 's' : ''}',
            style: AppTextStyles.body(context).copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < _selectedImages.length - 1 ? AppDimensions.paddingSmall : 0,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadius * 2),
          topRight: Radius.circular(AppDimensions.borderRadius * 2),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle indicator
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar Cancha' : 'Agregar Nueva Cancha',
                        style: AppTextStyles.heading3(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    children: [
                      // Basic Information Section
                      _buildSectionTitle('Información Básica'),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      _buildElegantTextField(
                        controller: _nameController,
                        label: 'Nombre de la cancha',
                        icon: Icons.sports_soccer,
                        validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      _buildElegantTextField(
                        controller: _sportTypeController,
                        label: 'Tipo de deporte',
                        icon: Icons.sports,
                        validator: (value) => value!.isEmpty ? 'Ingrese el tipo de deporte' : null,
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Photos Section
                      _buildSectionTitle('Fotos de la cancha'),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      _buildPhotoSection(),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Pricing Section
                      _buildSectionTitle('Precios'),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildElegantTextField(
                              controller: _dayPriceController,
                              label: 'Precio día',
                              icon: Icons.wb_sunny,
                              keyboardType: TextInputType.number,
                              prefix: 'S/ ',
                              validator: (value) {
                                if (value!.isEmpty) return 'Precio requerido';
                                if (double.tryParse(value) == null) return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Expanded(
                            child: _buildElegantTextField(
                              controller: _nightPriceController,
                              label: 'Precio noche',
                              icon: Icons.nightlight_round,
                              keyboardType: TextInputType.number,
                              prefix: 'S/ ',
                              validator: (value) {
                                if (value!.isEmpty) return 'Precio requerido';
                                if (double.tryParse(value) == null) return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Specifications Section
                      _buildSectionTitle('Especificaciones'),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildElegantTextField(
                              controller: _teamCapacityController,
                              label: 'Capacidad por equipo',
                              icon: Icons.group,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) return 'Capacidad requerida';
                                if (int.tryParse(value) == null) return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Expanded(
                            child: _buildElegantTextField(
                              controller: _materialController,
                              label: 'Material',
                              icon: Icons.texture,
                              validator: (value) => value!.isEmpty ? 'Ingrese el material' : null,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Roof checkbox with elegant design
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                        child: CheckboxListTile(
                          title: Text('¿Tiene techo?', style: AppTextStyles.body(context)),
                          subtitle: Text(
                            'Indica si la cancha cuenta con techo',
                            style: AppTextStyles.body(context).copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          value: _hasRoof,
                          onChanged: (value) => setState(() => _hasRoof = value!),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge * 2),
                    ],
                  ),
                ),
              ),
              
              // Bottom action buttons
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _isEditing ? 'Actualizar Cancha' : 'Agregar Cancha', 
                            style: AppTextStyles.buttonText
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3(context).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: AppTextStyles.inputLabel,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
      ),
    );
  }
}