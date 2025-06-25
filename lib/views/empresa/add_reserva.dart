import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/features/reservas/components/calculo_pago.dart';
import 'package:sintetico/features/reservas/components/comprobante_pago.dart';
import 'package:sintetico/features/reservas/components/fecha_hora.dart';
import 'package:sintetico/features/reservas/components/metodo_pago.dart';
import 'package:sintetico/features/reservas/components/selector_cancha.dart';
import 'package:sintetico/features/reservas/controllers/nueva_reserva_controller.dart';
import 'package:sintetico/models/cancha.dart';

class NewReservationView extends StatelessWidget {
  final CourtModel court;
  final String enterpriseId;

  const NewReservationView({
    super.key,
    required this.court,
    required this.enterpriseId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          NewReservationController(court: court, enterpriseId: enterpriseId),
      child: _NewReservationViewContent(court: court),
    );
  }
}

class _NewReservationViewContent extends StatelessWidget {
  final CourtModel court;

  const _NewReservationViewContent({required this.court});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewReservationController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    // Responsive padding y constraints
    double horizontalPadding = isMobile
        ? AppDimensions.paddingSmall
        : isTablet
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingLarge;

    double maxWidth = isDesktop
        ? 600
        : isTablet
            ? screenWidth * 0.8
            : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: !isMobile,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card para información de la cancha
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: CourtSelector(court: court),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Sección de datos del cliente
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                                size: isMobile ? 20 : 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Datos del Cliente',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingMedium),

                          // Responsive layout para campos de cliente
                          if (isDesktop || isTablet) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    labelText: 'Nombre Completo*',
                                    onChanged: controller.setClientName,
                                    prefixIcon: Icons.person,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.spacingMedium),
                                Expanded(
                                  child: _buildTextField(
                                    labelText: 'Teléfono*',
                                    onChanged: controller.setClientPhone,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icons.phone,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildTextField(
                              labelText: 'Nombre Completo*',
                              onChanged: controller.setClientName,
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: AppDimensions.spacingMedium),
                            _buildTextField(
                              labelText: 'Teléfono*',
                              onChanged: controller.setClientPhone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Sección de fecha y hora
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                color: AppColors.primary,
                                size: isMobile ? 20 : 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fecha y Hora',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingMedium),
                          DateTimePicker(
                            onDateTimeChanged: controller.setDateTime,
                            initialStartDateTime: controller.startDateTime,
                            initialEndDateTime: controller.endDateTime,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Sección de pago
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                color: AppColors.primary,
                                size: isMobile ? 20 : 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información de Pago',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingMedium),

                          // Layout responsive para precio y método de pago
                          if (isDesktop) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: PriceDisplay(
                                      price: controller.totalPrice),
                                ),
                                const SizedBox(
                                    width: AppDimensions.spacingMedium),
                                Expanded(
                                  flex: 2,
                                  child: PaymentMethodSelector(
                                    selectedMethod: controller.paymentMethod,
                                    onMethodSelected:
                                        controller.setPaymentMethod,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            PriceDisplay(price: controller.totalPrice),
                            const SizedBox(height: AppDimensions.spacingMedium),
                            PaymentMethodSelector(
                              selectedMethod: controller.paymentMethod,
                              onMethodSelected: controller.setPaymentMethod,
                            ),
                          ],

                          const SizedBox(height: AppDimensions.spacingMedium),
                          ReceiptUploader(
                            image: controller.receiptImage,
                            onImageSelected: controller.setReceiptImage,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingLarge),

                  // Botón de confirmación con diseño mejorado
                  Container(
                    width: double.infinity,
                    height: isMobile ? 50 : 56,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final success =
                                  await controller.submitReservation(context);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: controller.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Procesando...',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirmar Reserva',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Espacio adicional en la parte inferior
                  SizedBox(height: isMobile ? 20 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.7), size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
