import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class PaymentReceiptUploader extends StatelessWidget {
  final File? receiptImage;
  final Function(File) onImageSelected;
  final bool isLoading;

  const PaymentReceiptUploader({
    super.key,
    required this.receiptImage,
    required this.onImageSelected,
    this.isLoading = false,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70, // Comprimir para reducir tamaño
      );
      
      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar imagen desde',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comprobante de Pago',
                style: AppTextStyles.h3,
              ),
              if (receiptImage != null)
                TextButton(
                  onPressed: () => _showImageSourceDialog(context),
                  child: Text(
                    'Cambiar',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          
          Text(
            'Sube una foto o captura del comprobante del adelanto (50% del total)',
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Área de carga/previsualización
          GestureDetector(
            onTap: receiptImage == null && !isLoading
                ? () => _showImageSourceDialog(context)
                : null,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                border: Border.all(
                  color: receiptImage != null 
                      ? AppColors.success 
                      : AppColors.divider,
                  width: receiptImage != null ? 2 : 1,
                  style: receiptImage == null 
                      ? BorderStyle.solid 
                      : BorderStyle.solid,
                ),
              ),
              child: _buildContent(),
            ),
          ),

          if (receiptImage != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppDimensions.paddingXSmall),
                  Text(
                    'Comprobante cargado correctamente',
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (receiptImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            child: Image.file(
              receiptImage!,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay para indicar que se puede hacer tap para ver completo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.borderRadius),
                  bottomRight: Radius.circular(AppDimensions.borderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.zoom_in,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap para ver completo',
                    style: AppTextStyles.caption2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          // ignore: deprecated_member_use
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'Tap para subir comprobante',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXSmall),
        Text(
          'JPG, PNG - Max 5MB',
          style: AppTextStyles.caption2.copyWith(
            // ignore: deprecated_member_use
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}