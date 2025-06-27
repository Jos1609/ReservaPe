import 'package:flutter/material.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ReservationDetailModal extends StatelessWidget {
  final ReservationModel reservation;
  final CourtModel? court;
  final CompanyModel? company;
  final VoidCallback? onCancel;

  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.court,
    this.company,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required ReservationModel reservation,
    CourtModel? court,
    CompanyModel? company,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReservationDetailModal(
        reservation: reservation,
        court: court,
        company: company,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d \'de\' MMMM \'de\' yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: _getStatusColor(reservation.status).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Reserva',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${reservation.id.substring(0, 8).toUpperCase()}',
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  ),
                  child: Text(
                    _getStatusText(reservation.status),
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de la cancha
                  _buildSection(
                    title: 'Cancha',
                    icon: Icons.sports_soccer,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court?.name ?? 'Cargando...',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (court != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${court!.sportType} • ${court!.teamCapacity}v${court!.teamCapacity}',
                            style: AppTextStyles.caption1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Material: ${court!.material} ${court!.hasRoof ? "• Techada" : ""}',
                            style: AppTextStyles.caption1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Información del lugar
                  if (company != null)
                    _buildSection(
                      title: 'Lugar',
                      icon: Icons.business,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company!.name,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company!.address,
                            style: AppTextStyles.caption1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (company!.phoneNumber != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  company!.phoneNumber!,
                                  style: AppTextStyles.caption1.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Fecha y hora
                  _buildSection(
                    title: 'Fecha y Hora',
                    icon: Icons.calendar_today,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(reservation.startTime),
                          style: AppTextStyles.body1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}',
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${reservation.endTime.difference(reservation.startTime).inHours} ${reservation.endTime.difference(reservation.startTime).inHours > 1 ? "horas" : "hora"})',
                              style: AppTextStyles.caption1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Información de pago
                  _buildSection(
                    title: 'Información de Pago',
                    icon: Icons.payment,
                    content: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total de la reserva:',
                              style: AppTextStyles.body2,
                            ),
                            Text(
                              'S/ ${reservation.totalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Adelanto pagado (50%)',
                              style: AppTextStyles.caption1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'S/ ${(reservation.totalPrice * 0.5).toStringAsFixed(2)}',
                              style: AppTextStyles.body2,
                            ),
                          ],
                        ),
                        if (reservation.status == 'Confirmada') ...[
                          const SizedBox(height: AppDimensions.paddingSmall),
                          Row(
                            children: [
                              Icon(
                                Icons.pending,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Por pagar en cancha',
                                style: AppTextStyles.caption1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'S/ ${(reservation.totalPrice * 0.5).toStringAsFixed(2)}',
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Container(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSmall),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Método: ',
                                style: AppTextStyles.caption1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              ...reservation.metodosPago.map(
                                (metodo) => Text(
                                  metodo.toUpperCase(),
                                  style: AppTextStyles.caption1.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Razón de cancelación/rechazo
                  if (reservation.cancellationReason != null) ...[
                    const SizedBox(height: AppDimensions.paddingLarge),
                    _buildSection(
                      title: reservation.status == 'Rechazada'
                          ? 'Motivo del Rechazo'
                          : 'Motivo de Cancelación',
                      icon: Icons.info_outline,
                      content: Text(
                        reservation.cancellationReason!,
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Botones de acción
                  if (company != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareReservation(context),
                            icon: Icon(Icons.share, color: AppColors.primary),
                            label: const Text('Compartir',
                            style: TextStyle(color: AppColors.primary)
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadius),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openNavigation(context),
                            icon: const Icon(Icons.directions, color: Colors.white),
                            label: const Text('Cómo llegar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadius),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Botón cancelar si aplica
                  if (onCancel != null && _canCancelReservation()) ...[
                    const SizedBox(height: AppDimensions.paddingMedium),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadius),
                          ),
                        ),
                        child: const Text('Cancelar Reserva'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              title,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: content,
        ),
      ],
    );
  }

  bool _canCancelReservation() {
    return (reservation.status == 'Pendiente' ||
            reservation.status == 'Confirmada') &&
        reservation.startTime.isAfter(DateTime.now());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return AppColors.warning;
      case 'Confirmada':
        return AppColors.success;
      case 'Rechazada':
        return AppColors.error;
      case 'Cancelada':
        return AppColors.textSecondary;
      case 'Completada':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pendiente':
        return 'Pendiente';
      case 'Confirmada':
        return 'Confirmada';
      case 'Rechazada':
        return 'Rechazada';
      case 'Cancelada':
        return 'Cancelada';
      case 'Completada':
        return 'Completada';
      default:
        return status;
    }
  }

  Future<void> _shareReservation(BuildContext context) async {
    if (court == null || company == null) {
      return;
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    final lat = company!.coordinates['latitude'] ?? 0.0;
    final lng = company!.coordinates['longitude'] ?? 0.0;
    final mapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    final message = '''
    ⚽ ¡Tenemos partido!

    📍 *Cancha*: ${court!.name}
    🏢 *Lugar*: ${company!.name}
    📅 *Fecha*: ${dateFormat.format(reservation.startTime)}
    ⏰ *Hora*: ${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}
    💰 *Total*: S/ ${reservation.totalPrice.toStringAsFixed(2)}

    🗺️ Cómo llegar: $mapsUrl

    📌 *Estado*: ${_getStatusText(reservation.status)}
    🆔 *ID*: ${reservation.id.substring(0, 8).toUpperCase()}

    ¡No faltes, nos vemos en la cancha! 🔥
''';

    await Share.share(message);
  }

  Future<void> _openNavigation(BuildContext context) async {
    if (company == null) return;

    final lat = company!.coordinates['latitude'] ?? 0.0;
    final lng = company!.coordinates['longitude'] ?? 0.0;

    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Google Maps'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
