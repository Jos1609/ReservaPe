import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/auth/services/auth_service.dart';
import 'package:sintetico/features/home_empresas/controllers/reservas_controller.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/reserva.dart';
import 'package:sintetico/views/empresa/add_reserva.dart';

class CalendarSection extends StatelessWidget {
  final CourtModel court;
  final double padding;

  const CalendarSection({
    super.key,
    required this.court,
    required this.padding,
  });

  Widget _buildCalendarHeader(BuildContext context) {
    final controller = Provider.of<ReservationsController>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;

    return Column(
      children: [
        Row(
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
                      DateFormat('MMMM yyyy', 'es')
                          .format(controller.selectedMonth),
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
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final enterpriseId = AuthService.getCurrentUserId();
                    if (enterpriseId != null) {
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewReservationView(
                              court: court,
                              enterpriseId: enterpriseId,
                            ),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Usuario no autenticado. Por favor, inicia sesión.')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al redirigir: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva Reserva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: AppDimensions.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final enterpriseId = AuthService.getCurrentUserId();
                  if (enterpriseId != null) {
                    if (context.mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewReservationView(
                            court: court,
                            enterpriseId: enterpriseId,
                          ),
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Usuario no autenticado. Por favor, inicia sesión.')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al redirigir: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nueva Reserva'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final controller = Provider.of<ReservationsController>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    final firstDayOfMonth = DateTime(
        controller.selectedMonth.year, controller.selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(
        controller.selectedMonth.year, controller.selectedMonth.month + 1, 0);
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
              style:
                  AppTextStyles.body(context).copyWith(color: AppColors.error),
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
                  final date = DateTime(controller.selectedMonth.year,
                      controller.selectedMonth.month, day);
                  final reservations = reservationsByDate[
                          DateTime(date.year, date.month, date.day)] ??
                      [];
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
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : null,
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
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              reservation.status == 'Confirmada'
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildCalendarHeader(context),
            SizedBox(height: padding),
            Expanded(child: _buildCalendarGrid(context)),
          ],
        ),
      ),
    );
  }
}