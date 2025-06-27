import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/barra_navegacion.dart';
import 'package:sintetico/features/detalle_cancha/components/barra_inferior.dart';
import 'package:sintetico/features/detalle_cancha/components/carrusel_imagenes.dart';
import 'package:sintetico/features/detalle_cancha/components/franjas_horarias.dart';
import 'package:sintetico/features/detalle_cancha/components/informacion_cancha.dart';
import 'package:sintetico/features/detalle_cancha/components/selector_fecha.dart';
import 'package:sintetico/features/detalle_cancha/controllers/controlador_cancha.dart';
import 'package:sintetico/views/cliente/reserva.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';

class CourtDetailsView extends StatefulWidget {
  final String courtId;
  final String companyName;

  const CourtDetailsView({
    super.key,
    required this.courtId,
    required this.companyName,
  });

  @override
  State<CourtDetailsView> createState() => _CourtDetailsViewState();
}

class _CourtDetailsViewState extends State<CourtDetailsView> {
  late CourtDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CourtDetailsController();
    _controller.loadCourtDetails(widget.courtId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/cliente_dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/historial_reservas');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
        ),
        body: Consumer<CourtDetailsController>(
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
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: () =>
                          controller.loadCourtDetails(widget.courtId),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (controller.court == null) {
              return const Center(
                child: Text('No se encontró la cancha'),
              );
            }

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Carrusel de imágenes con AppBar transparente
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: CourtImageCarousel(
                          images: controller.court!.photos,
                          currentIndex: controller.currentPhotoIndex,
                          onPageChanged: controller.changePhotoIndex,
                        ),
                      ),
                    ),

                    // Información de la cancha
                    SliverToBoxAdapter(
                      child: CourtInfoSection(
                        court: controller.court!,
                        company: controller.company,
                      ),
                    ),

                    // Selector de fecha
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecciona una fecha',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            DateSelector(
                              selectedDate: controller.selectedDate,
                              onDateSelected: controller.changeSelectedDate,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Grid de horarios
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horarios disponibles',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            TimeSlotsGrid(
                              timeSlots: controller.timeSlots,
                              selectedSlots: controller
                                  .selectedSlots, // Cambiado de selectedSlot a selectedSlots
                              onSlotSelected: controller
                                  .toggleTimeSlot, // Cambiado de selectTimeSlot a toggleTimeSlot
                              canSelectSlot:
                                  controller.canSelectSlot, // Nuevo parámetro
                              court: controller.court!,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Espacio para el bottom bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),

                // Bottom bar para reservar
                if (controller.selectedSlots.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BookingBottomBar(
                      court: controller.court!,
                      selectedSlots: controller.selectedSlots,
                      totalPrice: controller.totalPrice,
                      onBookingPressed: () {
                        // Navegar a pantalla de resumen de reserva
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationSummaryView(
                              courtId: controller.court!.id,
                              startTime:
                                  controller.selectedSlots.first.startTime,
                              endTime: controller.selectedSlots.last.endTime,
                              totalPrice: controller.totalPrice,
                            ),
                          ),
                        );
                      },
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
