import 'package:flutter/material.dart';
import 'package:sintetico/models/cliente.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class ClientInfoDisplay extends StatelessWidget {
  final UserModel? user;
  final String? alternativePhone;
  final Function(String) onAlternativePhoneChanged;

  const ClientInfoDisplay({
    super.key,
    required this.user,
    this.alternativePhone,
    required this.onAlternativePhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
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
        child: Center(
          child: Text(
            'Cargando información del usuario...',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

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
          Text(
            'Datos del Cliente',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Información del usuario
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Nombre',
            value: '${user!.firstName} ${user!.lastName}',
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user!.email,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: user!.phone,
          ),

          // Opción para usar otro número
          const SizedBox(height: AppDimensions.paddingMedium),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppDimensions.paddingMedium),

          Text(
            '¿Usar otro número para esta reserva?',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          TextFormField(
            initialValue: alternativePhone,
            onChanged: onAlternativePhoneChanged,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Número alternativo (opcional)',
              prefixIcon: const Icon(Icons.phone_android),
              prefixText: '+51 ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}