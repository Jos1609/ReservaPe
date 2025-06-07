import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/models/cancha.dart';

class FieldCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 👈 ESTO es la clave
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen o placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: court.photos.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(court.photos.first),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(child: Icon(Icons.sports_soccer, size: 48, color: Colors.grey)),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 👈 IMPORTANTE también aquí
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: AppTextStyles.heading3(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _InfoColumn(label: 'Tamaño', value: '${court.teamCapacity} vs ${court.teamCapacity}')),
                    Expanded(child: _InfoColumn(label: 'Precio/H', value: 'S/ ${court.dayPrice.toStringAsFixed(0)}')),
                    Expanded(child: _InfoColumn(label: 'Cubierta', value: court.hasRoof ? 'Sí' : 'No')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onViewReservations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onViewReservations == null ? Colors.grey[300] : AppColors.success,
                          foregroundColor: onViewReservations == null ? Colors.grey : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Ver Reservas'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        Text(label, style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
