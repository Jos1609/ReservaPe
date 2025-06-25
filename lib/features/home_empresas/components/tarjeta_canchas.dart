import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/detalle_cancha/components/carrusel_imagenes.dart';
import 'package:sintetico/models/cancha.dart';

class FieldCard extends StatefulWidget {
  final CourtModel court;
  final VoidCallback? onEdit;
  final VoidCallback? onViewReservations;

  const FieldCard({
    super.key,
    required this.court,
    this.onEdit,
    this.onViewReservations,
  });

  @override
  State<FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<FieldCard> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Usar el componente CourtImageCarousel
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CourtImageCarousel(
                images: widget.court.photos,
                currentIndex: _currentPhotoIndex,
                onPageChanged: (index) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.court.name,
                  style: AppTextStyles.heading3(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _InfoColumn(
                            label: 'Tamaño',
                            value:
                                '${widget.court.teamCapacity} vs ${widget.court.teamCapacity}')),
                    Expanded(
                        child: _InfoColumn(
                            label: 'Precio/H',
                            value:
                                'S/ ${widget.court.dayPrice.toStringAsFixed(0)}')),
                    Expanded(
                        child: _InfoColumn(
                            label: 'Techo',
                            value: widget.court.hasRoof ? 'Sí' : 'No')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onViewReservations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.onViewReservations == null
                              ? Colors.grey[300]
                              : AppColors.success,
                          foregroundColor: widget.onViewReservations == null
                              ? Colors.grey
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reservas'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption(context)
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.body(context)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}