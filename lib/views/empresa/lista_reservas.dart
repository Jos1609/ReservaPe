import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/barra_navegacion_empresa.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/features/home_empresas/components/lista_reservas/calendario.dart';
import 'package:sintetico/features/home_empresas/components/lista_reservas/encabezado.dart';
import 'package:sintetico/features/home_empresas/components/lista_reservas/lista_reservas.dart';
import 'package:sintetico/features/home_empresas/components/lista_reservas/tarjeta_informacion.dart';
import 'package:sintetico/features/home_empresas/controllers/reservas_controller.dart';
import 'package:sintetico/models/cancha.dart';

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

  String _getDeviceType(double width) {
    if (width < AppDimensions.mobileBreakpoint) return 'mobile';
    if (width < AppDimensions.tabletBreakpoint) return 'tablet';
    return 'desktop';
  }

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
     final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.light,
       appBar: isDesktop 
          ? PreferredSize(
              preferredSize: Size.fromHeight(AppDimensions.navBarHeight),
              child: NavigationEmpresa(
                selectedIndex: 0,
                onItemSelected: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacementNamed(context, '/empresa_dashboard');
                      break;
                    case 1:
                      Navigator.pushReplacementNamed(context, '/profile');
                      break;
                  }
                },
              ),
            )
          : null,
      // BottomNavigationBar solo para móvil
      bottomNavigationBar: !isDesktop
          ? NavigationEmpresa(
              selectedIndex: 0,
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/empresa_dashboard');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/profile');
                    break;
                }
              },
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final deviceType = _getDeviceType(width);

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  ReservationHeader(
                    court: court,
                    onBackPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: padding),
                  FieldInfoCard(court: court),
                  SizedBox(height: padding),
                  
                  // Contenido responsive
                  if (deviceType == 'mobile') ...[
                    // Mobile: Todo en columna
                    SizedBox(
                      height: 350, // Altura fija más pequeña para el calendario
                      child: CalendarSection(
                        court: court,
                        padding: padding,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    SizedBox(
                      height: 400, // Altura fija para la lista
                      child: ReservationsList(
                        padding: padding,
                        maxHeight: 400,
                      ),
                    ),
                  ] else if (deviceType == 'tablet') ...[
                    // Tablet: Todo en columna con más altura
                    SizedBox(
                      height: 400, // Altura fija para el calendario
                      child: CalendarSection(
                        court: court,
                        padding: padding,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    SizedBox(
                      height: 500, // Mayor altura para la lista
                      child: ReservationsList(
                        padding: padding,
                        maxHeight: 500,
                      ),
                    ),
                  ] else ...[
                    // Desktop: Diseño en fila
                    SizedBox(
                      height: 600, // Altura fija para el contenedor
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 450, // Altura fija más pequeña para el calendario
                              child: CalendarSection(
                                court: court,
                                padding: padding,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingLarge),
                          Expanded(
                            flex: 2,
                            child: ReservationsList(
                              padding: padding,
                              maxHeight: 600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Espacio adicional al final para mejor scroll
                  SizedBox(height: padding * 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}