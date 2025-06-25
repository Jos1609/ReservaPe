import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/features/reservas/components/cliente/acciones_reserva.dart';
import 'package:sintetico/features/reservas/components/cliente/dialogo_confirmacion.dart';
import 'package:sintetico/features/reservas/components/cliente/encabezado_reserva.dart';
import 'package:sintetico/features/reservas/components/cliente/info_cliente.dart';
import 'package:sintetico/features/reservas/components/cliente/metodo_pago.dart';
import 'package:sintetico/features/reservas/components/cliente/subir_comprobante_pago.dart';
import 'package:sintetico/features/reservas/controllers/reserva_cliente_controller.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';

class ReservationSummaryView extends StatefulWidget {
  final String courtId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;

  const ReservationSummaryView({
    super.key,
    required this.courtId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
  });

  @override
  State<ReservationSummaryView> createState() => _ReservationSummaryViewState();
}

class _ReservationSummaryViewState extends State<ReservationSummaryView> {
  late ReservationController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ReservationController();
    _initializeReservation();
  }

  Future<void> _initializeReservation() async {
    await _controller.initializeReservation(
      courtId: widget.courtId,
      startTime: widget.startTime,
      endTime: widget.endTime,
      totalPrice: widget.totalPrice,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmReservation() async {
    // Validar que todo esté completo
    if (_controller.selectedPaymentMethod == null) {
      _showError('Por favor selecciona un método de pago');
      return;
    }

    if (_controller.receiptImage == null) {
      _showError('Por favor sube el comprobante de pago');
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await _showConfirmationDialog();
    if (!confirm) return;

    // Confirmar reserva
    final success = await _controller.confirmReservation();
    
    if (success) {
      await ReservationConfirmationDialog.show(
        // ignore: use_build_context_synchronously
        context,
        isSuccess: true,
        message: 'Tu reserva ha sido registrada exitosamente. Recibirás una confirmación cuando se verifique tu pago.',
        onDismiss: () {
          // Hacer scroll hasta las acciones
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      );
    } else {
      await ReservationConfirmationDialog.show(
        // ignore: use_build_context_synchronously
        context,
        isSuccess: false,
        message: _controller.error ?? 'Ocurrió un error al procesar tu reserva',
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Text(
          '¿Estás seguro de confirmar esta reserva?\n\n'
          'Monto del adelanto: S/ ${_controller.depositAmount.toStringAsFixed(2)}\n'
          'Método de pago: ${_controller.selectedPaymentMethod?.name ?? ""}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Confirmar Reserva'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Consumer<ReservationController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.court == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (controller.error != null && controller.court == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      controller.error!,
                      style: AppTextStyles.body1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: _initializeReservation,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (controller.court == null || controller.company == null) {
              return const Center(
                child: Text('No se pudo cargar la información'),
              );
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      // Header con información de la reserva
                      ReservationHeader(
                        court: controller.court!,
                        company: controller.company!,
                        startTime: controller.startTime!,
                        endTime: controller.endTime!,
                        totalPrice: controller.totalPrice,
                        depositAmount: controller.depositAmount,
                        remainingAmount: controller.remainingAmount,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Información del cliente
                      ClientInfoDisplay(
                        user: controller.currentUser,
                        alternativePhone: null,
                        onAlternativePhoneChanged: controller.updateAlternativePhone,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Selector de método de pago
                      PaymentMethodSelector(
                        paymentMethods: controller.paymentMethods,
                        selectedMethod: controller.selectedPaymentMethod,
                        onMethodSelected: controller.selectPaymentMethod,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Uploader de comprobante
                      PaymentReceiptUploader(
                        receiptImage: controller.receiptImage,
                        onImageSelected: controller.setReceiptImage,
                        isLoading: controller.isLoading,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Acciones post-reserva
                      ReservationActions(
                        onShare: controller.shareReservation,
                        onNavigate: controller.openNavigation,
                        isReservationComplete: controller.isReservationComplete,
                      ),
                      
                      // Espacio para el botón flotante
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Botón flotante de confirmación
                if (!controller.isReservationComplete)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: AppDimensions.paddingMedium,
                        right: AppDimensions.paddingMedium,
                        top: AppDimensions.paddingMedium,
                        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : _confirmReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                          ),
                        ),
                        child: controller.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Confirmar Reserva',
                                style: AppTextStyles.button1,
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}