import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/admin_empresas/controllers/registrar_empresa_controlador.dart';

class MapSelectionModal {
  static void show(BuildContext context, RegisterCompanyController controller) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar al tocar fuera
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: controller,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius * 1.5),
            ),
            elevation: 8,
            backgroundColor: AppColors.white, // Fondo blanco sólido
            child: Container(
              // Ajusta el ancho según el tamaño de la pantalla
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width * 0.95 // 95% del ancho en pantallas pequeñas
                    : 900, // Ancho fijo para pantallas grandes
                maxHeight: 800, // Altura máxima para el modal del mapa
              ),
              child: _MapSelectionModalContent(),
            ),
          ),
        );
      },
    );
  }
}

class _MapSelectionModalContent extends StatefulWidget {
  @override
  _MapSelectionModalContentState createState() => _MapSelectionModalContentState();
}

class _MapSelectionModalContentState extends State<_MapSelectionModalContent> {
  LatLng? _selectedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Inicializa la posición seleccionada desde el controlador
    final controller = Provider.of<RegisterCompanyController>(context, listen: false);
    _selectedPosition = controller.selectedPosition != null
        ? LatLng(
            controller.selectedPosition!.latitude,
            controller.selectedPosition!.longitude,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterCompanyController>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // Fondo blanco sólido
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius * 1.5),
      ),
      child: Column(
        children: [
          // Encabezado con título y botón de cerrar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.borderRadius * 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar Ubicación',
                  style: AppTextStyles.heading3(context),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.gray),
                  onPressed: () => Navigator.of(context).pop(), // Cierra con la "X"
                ),
              ],
            ),
          ),
          // Mapa
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _selectedPosition ?? LatLng(-5.9433, -77.3414), // Nueva Cajamarca por defecto
                zoom: 14.0,
                onTap: (_, latlng) {
                  setState(() {
                    _selectedPosition = latlng;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: _selectedPosition != null
                      ? [
                          Marker(
                            point: _selectedPosition!,
                            builder: (ctx) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          // Botón Guardar y coordenadas
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Botón Guardar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                  child: ElevatedButton(
                    onPressed: _selectedPosition != null
                        ? () {
                            // Actualiza las coordenadas en el controlador
                            controller.updateCoordinates(
                              _selectedPosition!.latitude,
                              _selectedPosition!.longitude,
                            );
                            // Cierra el modal
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                    ),
                    child: const Text(
                      'GUARDAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                // Coordenadas o instrucción
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  color: _selectedPosition != null
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.gray.withOpacity(0.1),
                  child: Text(
                    _selectedPosition != null
                        ? 'Coordenadas: ${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}'
                        : 'Toca en el mapa para seleccionar una ubicación',
                    style: AppTextStyles.body(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}