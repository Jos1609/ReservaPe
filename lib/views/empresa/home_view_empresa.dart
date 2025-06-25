import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/home_empresas/components/tarjeta_canchas.dart';
import 'package:sintetico/features/home_empresas/services/home_service.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/views/empresa/add_cancha.dart';
import 'package:sintetico/views/empresa/lista_reservas.dart';

class HomeViewEmpresa extends StatelessWidget {
  const HomeViewEmpresa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Canchas Sintéticas',
            style: AppTextStyles.heading3(context)),
        backgroundColor: AppColors.primary,
        elevation: AppDimensions.cardElevation,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: ElevatedButton(
              onPressed: () {
                AddCourtModal.show(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
              ),
              child: const Text('+ Agregar Cancha'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(  // Añade esto para permitir scroll
        child: StreamBuilder<List<CourtModel>>(
          stream: HomeEmpresaService.getUserCourts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las canchas',
                  style: AppTextStyles.body(context),
                ),
              );
            }
            final courts = snapshot.data ?? [];
            if (courts.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'No hay canchas registradas',
                        style: AppTextStyles.heading3(context).copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Toca el botón "Agregar Cancha" para comenzar',
                        style: AppTextStyles.body(context).copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 768;
                  final itemWidth = isWide
                      ? (constraints.maxWidth / 3) - AppDimensions.paddingMedium
                      : constraints.maxWidth;
                  return Column(
                    children: [
                      Wrap(
                        spacing: AppDimensions.paddingMedium,
                        runSpacing: AppDimensions.paddingMedium,
                        children: courts.map((court) {
                          return SizedBox(
                            width: itemWidth,
                            child: FieldCard(
                                court: court,
                                onEdit: () {
                                  AddCourtModal.show(context, court: court);
                                },
                                onViewReservations: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReservationsView(court: court),
                                    ),
                                  );
                                }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge), // Espacio extra al final
                    ],
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