import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/home_empresas/controllers/reservas_controller.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';

class ReservationsView extends StatelessWidget {
  final CourtModel court;

  const ReservationsView({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReservationsController(court: court),
      child: _ReservationsViewContent(court: court),
    );
  }
}

class _ReservationsViewContent extends StatelessWidget {
  final CourtModel court;

  const _ReservationsViewContent({required this.court});

  // Helper para obtener el tipo de dispositivo
  String _getDeviceType(double width) {
    if (width < AppDimensions.mobileBreakpoint) return 'mobile';
    if (width < AppDimensions.tabletBreakpoint) return 'tablet';
    return 'desktop';
  }

  // Helper para obtener padding responsivo
  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = _getDeviceType(width);
    
    switch (deviceType) {
      case 'mobile':
        return AppDimensions.paddingSmall;
      case 'tablet':
        return AppDimensions.paddingMedium;
      default:
        return AppDimensions.paddingLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = _getResponsivePadding(context);
    
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: padding),
              _buildFieldInfo(context),
              SizedBox(height: padding),
              Expanded(child: _buildReservationsContainer(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            label: Text(
              'Volver',
              style: AppTextStyles.body(context).copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Reservas - ${court.name}',
            style: AppTextStyles.heading3(context).copyWith(
              color: AppColors.primary,
              fontSize: isMobile ? 18 : null,
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            label: Text(
              'Volver a canchas',
              style: AppTextStyles.body(context).copyWith(color: AppColors.primary),
            ),
          ),
        ),
        Flexible(
          child: Text(
            'Reservas - ${court.name}',
            style: AppTextStyles.heading3(context).copyWith(color: AppColors.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInfo(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    final imageSize = isMobile ? 60.0 : 80.0;
    
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppDimensions.paddingSmall : AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.gray,
                image: court.photos.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(court.photos.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            SizedBox(width: isMobile ? AppDimensions.spacingSmall : AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: AppTextStyles.heading3(context).copyWith(
                      fontSize: isMobile ? 16 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: AppDimensions.spacingSmall,
                    runSpacing: AppDimensions.spacingXSmall,
                    children: [
                      _buildMetaItem(
                        context,
                        icon: Icons.group,
                        text: '${court.teamCapacity}v${court.teamCapacity}',
                      ),
                      _buildMetaItem(
                        context,
                        icon: Icons.attach_money,
                        text: '${court.dayPrice.toStringAsFixed(0)}/h',
                      ),
                      _buildMetaItem(
                        context,
                        icon: Icons.roofing,
                        text: court.hasRoof ? 'Cubierta' : 'Sin techo',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, {required IconData icon, required String text}) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 14 : 16, color: AppColors.textLight),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: isMobile ? 12 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationsContainer(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = _getDeviceType(width);
        
        if (deviceType == 'mobile') {
          return Column(
            children: [
              Expanded(flex: 3, child: _buildCalendarSection(context)),
              const SizedBox(height: AppDimensions.spacingMedium),
              Expanded(flex: 2, child: _buildReservationsList(context, double.infinity)),
            ],
          );
        }
        
        if (deviceType == 'tablet') {
          return Column(
            children: [
              Expanded(flex: 2, child: _buildCalendarSection(context)),
              const SizedBox(height: AppDimensions.spacingMedium),
              Expanded(flex: 3, child: _buildReservationsList(context, double.infinity)),
            ],
          );
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildCalendarSection(context)),
            const SizedBox(width: AppDimensions.spacingLarge),
            Expanded(flex: 2, child: _buildReservationsList(context, constraints.maxHeight)),
          ],
        );
      },
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(_getResponsivePadding(context)),
        child: Column(
          children: [
            _buildCalendarHeader(context),
            SizedBox(height: _getResponsivePadding(context)),
            Expanded(child: _buildCalendarGrid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    final controller = Provider.of<ReservationsController>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    
    if (isMobile) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () => controller.changeMonth(-1),
              ),
              SizedBox(
                width: 150,
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy', 'es').format(controller.selectedMonth),
                    style: AppTextStyles.bodyBold(context).copyWith(
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () => controller.changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar lógica para agregar nueva reserva
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nueva Reserva'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              onPressed: () => controller.changeMonth(-1),
            ),
            SizedBox(
              width: 150,
              child: Center(
                child: Text(
                  DateFormat('MMMM yyyy', 'es').format(controller.selectedMonth),
                  style: AppTextStyles.bodyBold(context),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.primary),
              onPressed: () => controller.changeMonth(1),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar lógica para agregar nueva reserva
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nueva Reserva'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final controller = Provider.of<ReservationsController>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    final firstDayOfMonth = DateTime(controller.selectedMonth.year, controller.selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(controller.selectedMonth.year, controller.selectedMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday - 1;
    final totalDays = lastDayOfMonth.day + startingWeekday;

    return StreamBuilder<Map<DateTime, List<ReservationModel>>>(
      stream: controller.getReservationsForMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar reservas: ${snapshot.error}',
              style: AppTextStyles.body(context).copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          );
        }
        final reservationsByDate = snapshot.data ?? {};

        return Column(
          children: [
            Row(
              children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            isMobile ? day.substring(0, 1) : day,
                            style: AppTextStyles.body(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                              fontSize: isMobile ? 12 : null,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: isMobile ? 2 : 5,
                  mainAxisSpacing: isMobile ? 2 : 5,
                  childAspectRatio: isMobile ? 0.8 : 1,
                ),
                itemCount: (totalDays / 7).ceil() * 7,
                itemBuilder: (context, index) {
                  if (index < startingWeekday) {
                    return const SizedBox.shrink();
                  }
                  final day = index - startingWeekday + 1;
                  if (day > lastDayOfMonth.day) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(controller.selectedMonth.year, controller.selectedMonth.month, day);
                  final reservations = reservationsByDate[DateTime(date.year, date.month, date.day)] ?? [];
                  final hasReservations = reservations.isNotEmpty;
                  final isToday = date.day == DateTime.now().day &&
                      date.month == DateTime.now().month &&
                      date.year == DateTime.now().year;
                  final isSelected = date.day == controller.selectedDate.day &&
                      date.month == controller.selectedDate.month &&
                      date.year == controller.selectedDate.year;

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary
                            : isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : hasReservations
                                    ? AppColors.primary.withOpacity(0.1)
                                    : null,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: AppTextStyles.body(context).copyWith(
                              color: isToday ? AppColors.white : AppColors.dark,
                              fontWeight: isToday || isSelected ? FontWeight.bold : null,
                              fontSize: isMobile ? 12 : null,
                            ),
                          ),
                          if (hasReservations) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: reservations
                                  .take(isMobile ? 2 : 3)
                                  .map((reservation) => Container(
                                        width: isMobile ? 4 : 6,
                                        height: isMobile ? 4 : 6,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: reservation.status == 'Confirmada'
                                              ? AppColors.star
                                              : AppColors.accent,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReservationsList(BuildContext context, double maxHeight) {
    final controller = Provider.of<ReservationsController>(context);
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
          padding: EdgeInsets.all(_getResponsivePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReservationsHeader(context, isMobile),
              SizedBox(height: _getResponsivePadding(context)),
              Expanded(
                child: StreamBuilder<List<ReservationModel>>(
                  stream: controller.getReservationsForDate(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar reservas: ${snapshot.error}',
                          style: AppTextStyles.body(context).copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final reservations = snapshot.data ?? [];
                    final filteredReservations = reservations.where((reservation) {
                      if (controller.filter == 'Todas') return true;
                      return reservation.status == controller.filter.replaceAll('s', '');
                    }).toList();

                    if (filteredReservations.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay reservas para este día',
                          style: AppTextStyles.body(context).copyWith(color: AppColors.gray),
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

  Widget _buildReservationItem(BuildContext context, ReservationModel reservation) {
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
                                image: NetworkImage(reservation.clientAvatarUrl),
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
                        style: AppTextStyles.body(context).copyWith(fontSize: 12),
                      ),
                      Text(
                        'Tel: ${reservation.clientPhone}',
                        style: AppTextStyles.body(context).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reservation.endTime.difference(reservation.startTime).inMinutes / 60} horas • \$${reservation.totalPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.body(context).copyWith(fontSize: 13),
                      ),
                      Text(
                        'Tel: ${reservation.clientPhone}',
                        style: AppTextStyles.body(context).copyWith(fontSize: 13),
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
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 5),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                _buildReservationActions(context, reservation, isPending, isCancelled, isMobile),
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
                onPressed: () => controller.showReservationDetails(context, reservation),
                icon: Icon(Icons.visibility, size: isMobile ? 12 : 14),
                label: Text('Detalles', style: TextStyle(fontSize: isMobile ? 12 : null)),
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
                    onPressed: () => controller.confirmReservation(context, reservation),
                    icon: Icon(Icons.check, size: isMobile ? 12 : 14),
                    label: Text('Confirmar', style: TextStyle(fontSize: isMobile ? 12 : null)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.star,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.rejectReservation(context, reservation),
                    icon: Icon(Icons.close, size: isMobile ? 12 : 14),
                    label: Text('Rechazar', style: TextStyle(fontSize: isMobile ? 12 : null)),
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
                  onPressed: () => controller.cancelReservation(context, reservation),
                  icon: Icon(Icons.close, size: isMobile ? 12 : 14),
                  label: Text('Cancelar', style: TextStyle(fontSize: isMobile ? 12 : null)),
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
          onPressed: () => controller.showReservationDetails(context, reservation),
          icon: const Icon(Icons.visibility, size: 14),
          label: const Text('Detalles'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textLight,
          ),
        ),
        if (isPending) ...[
          TextButton.icon(
            onPressed: () => controller.confirmReservation(context, reservation),
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
  }}