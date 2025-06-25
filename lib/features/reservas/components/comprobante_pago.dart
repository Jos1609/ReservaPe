import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class ReceiptUploader extends StatelessWidget {
  final XFile? image;
  final Function(XFile?) onImageSelected;

  const ReceiptUploader({
    super.key,
    required this.image,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprobante de Pago*',
          style: AppTextStyles.heading3(context).copyWith(fontSize: isMobile ? 16 : null),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        
        // Contenedor principal con mejor diseño
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: isMobile ? 120 : 140,
            maxHeight: image != null ? (isMobile ? 300 : 400) : (isMobile ? 120 : 140),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              // ignore: deprecated_member_use
              color: image != null ? AppColors.primary.withOpacity(0.3) : AppColors.gray,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            // ignore: deprecated_member_use
            color: image != null ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
          ),
          child: image == null ? _buildUploadArea(context, isMobile) : _buildImagePreview(context, isMobile),
        ),
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context, bool isMobile) {
    return InkWell(
      onTap: _selectImage,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: isMobile ? 32 : 40,
              color: AppColors.gray,
            ),
            const SizedBox(height: 8),
            Text(
              'Haz clic para subir comprobante',
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.gray,
                fontSize: isMobile ? 12 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG (Max. 5MB)',
              style: AppTextStyles.body(context).copyWith(
                // ignore: deprecated_member_use
                color: AppColors.gray.withOpacity(0.7),
                fontSize: isMobile ? 10 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, bool isMobile) {
    return Stack(
      children: [
        // Imagen de previsualización
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall - 4),
            child: _buildImageWidget(),
          ),
        ),
        
        // Botones de acción superpuestos
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón para cambiar imagen
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _selectImage,
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Cambiar imagen',
                ),
              ),
              const SizedBox(width: 8),
              // Botón para eliminar imagen
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.error.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => onImageSelected(null),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Eliminar imagen',
                ),
              ),
            ],
          ),
        ),
        
        // Indicador de estado en la parte inferior
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.success.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Comprobante cargado correctamente',
                    style: AppTextStyles.body(context).copyWith(
                      color: Colors.white,
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      onImageSelected(pickedImage);
    } catch (e) {
      // Aquí podrías mostrar un mensaje de error o usar un sistema de notificaciones
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      // Para Flutter Web, usar Image.network con la URL de la imagen
      return FutureBuilder<Uint8List>(
        future: image!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: _buildErrorWidget,
            );
          } else if (snapshot.hasError) {
            return _buildErrorWidget(context, snapshot.error, null);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      // Para móviles, usar Image.file normalmente
      return Image.file(
        File(image!.path),
        fit: BoxFit.contain,
        errorBuilder: _buildErrorWidget,
      );
    }
  }

  Widget _buildErrorWidget(BuildContext context, Object? error, StackTrace? stackTrace) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
    return Container(
      // ignore: deprecated_member_use
      color: AppColors.gray.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 24 : 32,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Error al cargar imagen',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.error,
              fontSize: isMobile ? 12 : null,
            ),
          ),
        ],
      ),
    );
  }
}