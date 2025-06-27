import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/home_empresas/controllers/reservas_controller.dart';
import 'package:sintetico/models/reserva.dart';

class ReservationsList extends StatelessWidget {
  final double padding;
  final double maxHeight;

  const ReservationsList({
    super.key,
    required this.padding,
    required this.maxHeight,
  });

  String _getDeviceType(double width) {
    if (width < AppDimensions.mobileBreakpoint) return 'mobile';
    if (width < AppDimensions.tabletBreakpoint) return 'tablet';
    return 'desktop';
  }

  Widget _buildReservationsHeader(BuildContext context, bool isMobile) {
    final controller = Provider.of<ReservationsController>(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservas ${DateFormat('dd/MM', 'es').format(controller.selectedDate)}',
            style: AppTextStyles.heading3(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(context, 'Todas'),
                _buildFilterButton(context, 'Confirmadas'),
                _buildFilterButton(context, 'Pendientes'),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Reservas para ${DateFormat('dd/MM/yyyy', 'es').format(controller.selectedDate)}',
            style: AppTextStyles.heading3(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            _buildFilterButton(context, 'Todas'),
            _buildFilterButton(context, 'Confirmadas'),
            _buildFilterButton(context, 'Pendientes'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context, String label) {
    final controller = Provider.of<ReservationsController>(context);
    final isActive = controller.filter == label;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;

    return TextButton(
      onPressed: () => controller.setFilter(label),
      style: TextButton.styleFrom(
        foregroundColor: isActive ? AppColors.primary : AppColors.textLight,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 4 : 8,
          horizontal: isMobile ? 6 : 8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 12 : null,
          fontWeight: isActive ? FontWeight.bold : null,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.primary,
          decorationThickness: 2,
        ),
      ),
    );
  }

  Widget _buildReservationItem(
      BuildContext context, ReservationModel reservation) {
    final controller = Provider.of<ReservationsController>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    final timeFormat = DateFormat('HH:mm', 'es');
    final isCancelled = reservation.status == 'Cancelada';
    final isPending = reservation.status == 'Pendiente';

    Color borderColor;
    Color statusBgColor;
    Color statusTextColor;
    switch (reservation.status) {
      case 'Confirmada':
        borderColor = AppColors.star;
        statusBgColor = AppColors.star.withOpacity(0.1);
        statusTextColor = AppColors.star;
        break;
      case 'Pendiente':
        borderColor = AppColors.accent;
        statusBgColor = AppColors.accent.withOpacity(0.1);
        statusTextColor = AppColors.accent;
        break;
      case 'Cancelada':
        borderColor = AppColors.error;
        statusBgColor = AppColors.error.withOpacity(0.1);
        statusTextColor = AppColors.error;
        break;
      default:
        borderColor = AppColors.gray;
        statusBgColor = AppColors.gray.withOpacity(0.1);
        statusTextColor = AppColors.gray;
    }

    return Opacity(
      opacity: isCancelled ? 0.7 : 1.0,
      child: Card(
        color: AppColors.backgroundLight,
        margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: borderColor, width: 4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}',
                      style: AppTextStyles.bodyBold(context).copyWith(
                        color: AppColors.primary,
                        fontSize: isMobile ? 14 : null,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reservation.status,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: isMobile ? 10 : 12,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: isMobile ? 24 : 30,
                      height: isMobile ? 24 : 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gray,
                        image: reservation.clientAvatarUrl.isNotEmpty
                            ? DecorationImage(
                                image:
                                    NetworkImage(reservation.clientAvatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reservation.clientName,
                        style: AppTextStyles.bodyBold(context).copyWith(
                          fontSize: isMobile ? 14 : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                if (isMobile) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reservation.endTime.difference(reservation.startTime).inMinutes / 60} horas • \$${reservation.totalPrice.toStringAsFixed(0)}',
                        style:
                            AppTextStyles.body(context).copyWith(fontSize: 12),
                      ),
                      Text(
                        'Tel: ${reservation.clientPhone}',
                        style:
                            AppTextStyles.body(context).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reservation.endTime.difference(reservation.startTime).inMinutes / 60} horas • \$${reservation.totalPrice.toStringAsFixed(0)}',
                        style:
                            AppTextStyles.body(context).copyWith(fontSize: 13),
                      ),
                      Text(
                        'Tel: ${reservation.clientPhone}',
                        style:
                            AppTextStyles.body(context).copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
                if (reservation.comprobantePago.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Image.network(reservation.comprobantePago),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Ver comprobante de pago',
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontSize: isMobile ? 12 : null,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Wrap(
                  spacing: 5,
                  children: reservation.metodosPago
                      .map((metodo) => Chip(
                            label: Text(
                              metodo,
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: isMobile ? 10 : 12,
                              ),
                            ),
                            backgroundColor: AppColors.light,
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 3 : 5),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                if (reservation.cancellationReason != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Motivo: ${reservation.cancellationReason}',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: isMobile ? 12 : 13,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildReservationActions(
                    context, reservation, isPending, isCancelled, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationActions(
    BuildContext context,
    ReservationModel reservation,
    bool isPending,
    bool isCancelled,
    bool isMobile,
  ) {
    final controller = Provider.of<ReservationsController>(context);

    if (isMobile) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () =>
                    controller.showReservationDetails(context, reservation),
                icon: Icon(Icons.visibility, size: isMobile ? 12 : 14),
                label: Text('Detalles',
                    style: TextStyle(fontSize: isMobile ? 12 : null)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () =>
                        controller.confirmReservation(context, reservation),
                    icon: Icon(Icons.check, size: isMobile ? 12 : 14),
                    label: Text('Confirmar',
                        style: TextStyle(fontSize: isMobile ? 12 : null)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.star,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () =>
                        controller.rejectReservation(context, reservation),
                    icon: Icon(Icons.close, size: isMobile ? 12 : 14),
                    label: Text('Rechazar',
                        style: TextStyle(fontSize: isMobile ? 12 : null)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (!isCancelled) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      controller.cancelReservation(context, reservation),
                  icon: Icon(Icons.close, size: isMobile ? 12 : 14),
                  label: Text('Cancelar',
                      style: TextStyle(fontSize: isMobile ? 12 : null)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () =>
              controller.showReservationDetails(context, reservation),
          icon: const Icon(Icons.visibility, size: 14),
          label: const Text('Detalles'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textLight,
          ),
        ),
        if (isPending) ...[
          TextButton.icon(
            onPressed: () =>
                controller.confirmReservation(context, reservation),
            icon: const Icon(Icons.check, size: 14),
            label: const Text('Confirmar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.star,
            ),
          ),
          TextButton.icon(
            onPressed: () => controller.rejectReservation(context, reservation),
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Rechazar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ] else if (!isCancelled) ...[
          TextButton.icon(
            onPressed: () => controller.cancelReservation(context, reservation),
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Cancelar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = _getDeviceType(width);
    final isMobile = deviceType == 'mobile';

    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Container(
        width: deviceType == 'desktop' ? null : double.infinity,
        constraints: deviceType == 'desktop'
            ? const BoxConstraints(minWidth: 300, maxWidth: 400)
            : null,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReservationsHeader(context, isMobile),
              SizedBox(height: padding),
              Expanded(
                child: StreamBuilder<List<ReservationModel>>(
                  stream: Provider.of<ReservationsController>(context)
                      .getReservationsForDate(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar reservas: ${snapshot.error}',
                          style: AppTextStyles.body(context)
                              .copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final reservations = snapshot.data ?? [];
                    final filteredReservations =
                        reservations.where((reservation) {
                      if (Provider.of<ReservationsController>(context).filter ==
                          'Todas') return true;
                      return reservation.status ==
                          Provider.of<ReservationsController>(context)
                              .filter
                              .replaceAll('s', '');
                    }).toList();

                    if (filteredReservations.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay reservas para este día',
                          style: AppTextStyles.body(context)
                              .copyWith(color: AppColors.gray),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredReservations.length,
                      itemBuilder: (context, index) {
                        final reservation = filteredReservations[index];
                        return _buildReservationItem(context, reservation);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}