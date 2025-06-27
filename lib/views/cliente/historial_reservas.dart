import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/barra_navegacion.dart';
import 'package:sintetico/features/historial_reservas/componentes/filtro_estados.dart';
import 'package:sintetico/features/historial_reservas/componentes/modal_detalle.dart';
import 'package:sintetico/features/historial_reservas/componentes/reservas_vacias.dart';
import 'package:sintetico/features/historial_reservas/componentes/tarjeta_reserva.dart';
import 'package:sintetico/features/historial_reservas/controllers/historial_reserva_controller.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';

class ReservationHistoryView extends StatefulWidget {
  const ReservationHistoryView({super.key});

  @override
  State<ReservationHistoryView> createState() => _ReservationHistoryViewState();
}

class _ReservationHistoryViewState extends State<ReservationHistoryView> {
  late ReservationHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReservationHistoryController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCancelDialog(String reservationId) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro de que deseas cancelar esta reserva?',
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                hintText: 'Ingresa el motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.cancelReservation(
        reservationId,
        reasonController.text.isEmpty
            ? 'Cancelado por el usuario'
            : reasonController.text,
      );

      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar la reserva'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 1, // Estamos en el historial
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/cliente_dashboard');
                break;
              case 1:
                // Ya estás en historial
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
        ),
        appBar: AppBar(
          title: const Text('Mis Reservas'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Consumer<ReservationHistoryController>(
              builder: (context, controller, _) {
                // Contar reservas por estado
                final counts = <String, int>{
                  'Todas': controller.reservations.length,
                };

                for (final group in controller.groupedReservations.entries) {
                  counts[group.key] = group.value.length;
                }

                return ReservationStatusFilter(
                  selectedStatus: controller.selectedStatus,
                  onStatusChanged: controller.changeStatusFilter,
                  counts: counts,
                );
              },
            ),
          ),
        ),
        body: Consumer<ReservationHistoryController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (controller.error != null) {
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
                  ],
                ),
              );
            }

            final reservations = controller.filteredReservations;

            if (reservations.isEmpty) {
              return EmptyReservations(
                statusFilter: controller.selectedStatus,
                onExplore: () {
                  Navigator.pushReplacementNamed(context, '/cliente_dashboard');
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                controller.init();
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  final court =
                      controller.getCourtForReservation(reservation.courtId);
                  final company =
                      controller.getCompanyForCourt(reservation.courtId);

                  return ReservationCard(
                    reservation: reservation,
                    court: court,
                    company: company,
                    onTap: () {
                      ReservationDetailModal.show(
                        context,
                        reservation: reservation,
                        court: court,
                        company: company,
                        onCancel: controller.canCancelReservation(reservation)
                            ? () => _showCancelDialog(reservation.id)
                            : null,
                      );
                    },
                    onCancel: controller.canCancelReservation(reservation)
                        ? () => _showCancelDialog(reservation.id)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
