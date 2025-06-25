import 'package:flutter/material.dart';
import 'package:sintetico/features/detalle_cancha/services/detalle_cancha_servicio.dart';
import 'package:sintetico/models/cancha.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:intl/intl.dart';

class TimeSlotsGrid extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final List<TimeSlot> selectedSlots;
  final Function(TimeSlot) onSlotSelected;

  final bool Function(TimeSlot) canSelectSlot; // Corregido el tipo
  final CourtModel court;

  const TimeSlotsGrid({
    super.key,
    required this.timeSlots,
    required this.selectedSlots,
    required this.onSlotSelected,
    required this.canSelectSlot,
    required this.court,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                'No hay horarios disponibles para esta fecha',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instrucciones
        if (selectedSlots.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.info.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
              border: Border.all(
                // ignore: deprecated_member_use
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'Selecciona horarios consecutivos. ${selectedSlots.length} hora${selectedSlots.length > 1 ? 's' : ''} seleccionada${selectedSlots.length > 1 ? 's' : ''}',
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Grid de horarios
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
            // Ajustar el aspect ratio basado en el tamaño de pantalla
            final childAspectRatio = constraints.maxWidth > 600 ? 2.5 : 2.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: AppDimensions.paddingSmall,
                mainAxisSpacing: AppDimensions.paddingSmall,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                final isSelected = selectedSlots.contains(slot);
                final isPastTime = slot.isPastTime; // Usar el campo del slot
                final isReserved = slot.isReserved;
                final isNightTime = slot.startTime.hour >= 18;
                final canBeSelected =
                    canSelectSlot(slot); // Ahora es bool directamente
                final isDisabled = !slot.isAvailable ||
                    isPastTime ||
                    isReserved ||
                    (selectedSlots.isNotEmpty && !isSelected && !canBeSelected);

                return GestureDetector(
                  onTap: !isDisabled ? () => onSlotSelected(slot) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _getSlotColor(
                          slot, isSelected, isPastTime, isDisabled, isReserved),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall),
                      border: Border.all(
                        color: _getSlotBorderColor(slot, isSelected, isPastTime,
                            isDisabled, isReserved),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Contenido principal con Padding para evitar overflow
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icono de día/noche o reservado
                                  Icon(
                                    isReserved
                                        ? Icons.event_busy // Icono para reservado
                                        : (isNightTime
                                            ? Icons.nightlight_round
                                            : Icons.wb_sunny),
                                    size: 14,
                                    color: _getTextColor(slot, isSelected,
                                        isPastTime, isDisabled, isReserved),
                                  ),
                                  const SizedBox(height: 2),
                                  // Hora
                                  Text(
                                    DateFormat('HH:mm').format(slot.startTime),
                                    style: AppTextStyles.caption1.copyWith(
                                      color: _getTextColor(slot, isSelected,
                                          isPastTime, isDisabled, isReserved),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      decoration: isReserved
                                          ? TextDecoration
                                              .lineThrough // Tachar si está reservado
                                          : null,
                                    ),
                                  ),
                                  // Mostrar "Reservado" en lugar del precio
                                  if (isReserved)
                                    Text(
                                      'Reservado',
                                      style: AppTextStyles.caption2.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10, // Reducir tamaño de fuente
                                      ),
                                    )
                                  else if (slot.isAvailable && !isPastTime)
                                    Text(
                                      'S/ ${_getSlotPrice(slot).toStringAsFixed(0)}',
                                      style: AppTextStyles.caption2.copyWith(
                                        color: _getTextColor(slot, isSelected,
                                            isPastTime, isDisabled, isReserved),
                                        fontSize: 10, // Reducir tamaño de fuente
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Indicador de horario pasado (mantener el existente)
                        if (isPastTime)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusSmall),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.block,
                                  size: 20,
                                  color:
                                      // ignore: deprecated_member_use
                                      AppColors.textSecondary.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getSlotColor(TimeSlot slot, bool isSelected, bool isPastTime,
      bool isDisabled, bool isReserved) {
    if (isReserved) {
      return AppColors.error
          // ignore: deprecated_member_use
          .withOpacity(0.1); // Fondo rojo claro para reservados
    }
    if (isPastTime || !slot.isAvailable) {
      return AppColors.surface;
    }
    if (isDisabled && !isSelected) {
      // ignore: deprecated_member_use
      return AppColors.surface.withOpacity(0.5);
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return Colors.white;
  }

  Color _getSlotBorderColor(TimeSlot slot, bool isSelected, bool isPastTime,
      bool isDisabled, bool isReserved) {
    if (isReserved) {
      return AppColors.error; // Borde rojo para reservados
    }
    if (isPastTime || !slot.isAvailable) {
      return AppColors.divider;
    }
    if (isDisabled && !isSelected) {
      // ignore: deprecated_member_use
      return AppColors.divider.withOpacity(0.5);
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return AppColors.divider;
  }

  Color _getTextColor(TimeSlot slot, bool isSelected, bool isPastTime,
      bool isDisabled, bool isReserved) {
    if (isReserved) {
      return AppColors.error; // Texto rojo para reservados
    }
    if (isPastTime || !slot.isAvailable) {
      // ignore: deprecated_member_use
      return AppColors.textSecondary.withOpacity(0.5);
    }
    if (isDisabled && !isSelected) {
      // ignore: deprecated_member_use
      return AppColors.textSecondary.withOpacity(0.3);
    }
    if (isSelected) {
      return Colors.white;
    }
    return AppColors.textPrimary;
  }

  double _getSlotPrice(TimeSlot slot) {
    final isNightTime = slot.startTime.hour >= 18;
    return isNightTime ? court.nightPrice : court.dayPrice;
  }
}