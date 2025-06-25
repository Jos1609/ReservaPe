import 'package:flutter/material.dart';
import 'package:sintetico/features/reservas/services/reserva_cliente_service.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

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
          Text(
            'Método de Pago',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Lista de métodos de pago
          ...paymentMethods.map((method) => _buildPaymentMethodTile(method)),

          // Instrucciones del método seleccionado
          if (selectedMethod != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'Instrucciones de pago',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    selectedMethod!.instructions,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.info,
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

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = selectedMethod?.id == method.id;

    return GestureDetector(
      onTap: () => onMethodSelected(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícono del método de pago
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Center(
                child: _getPaymentIcon(method.id),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),

            // Nombre del método
            Expanded(
              child: Text(
                method.name,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),

            // Radio button
            Radio<String>(
              value: method.id,
              groupValue: selectedMethod?.id,
              onChanged: (_) => onMethodSelected(method),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPaymentIcon(String methodId) {
    IconData iconData;
    Color iconColor;

    switch (methodId) {
      case 'yape':
        iconData = Icons.qr_code;
        iconColor = const Color(0xFF6F2C91); // Color morado de Yape
        break;
      case 'plin':
        iconData = Icons.qr_code_scanner;
        iconColor = const Color(0xFF00BFA5); // Color turquesa de Plin
        break;
      case 'transferencia':
        iconData = Icons.account_balance;
        iconColor = AppColors.primary;
        break;
      default:
        iconData = Icons.payment;
        iconColor = AppColors.textSecondary;
    }

    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }
}