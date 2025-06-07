import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class TextInputFieldEmpresas extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final double? width;

  const TextInputFieldEmpresas({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta
          Text(
            label,
            style: AppTextStyles.bodyBold(context).copyWith(
              color: AppColors.dark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          // Campo de texto
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator,
            style: AppTextStyles.body(context).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body(context).copyWith(
                color: AppColors.gray,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0), // Borde gris claro del HTML
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.primary, // #2ECC71
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.error, // #E74C3C
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              // Sombra al enfocar (similar al HTML)
             
            ),
          ),
        ],
      ),
    );
  }
}

extension _InputDecorationExtension on InputDecoration {
}