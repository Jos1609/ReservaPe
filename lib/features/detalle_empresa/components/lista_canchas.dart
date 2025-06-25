import 'package:flutter/material.dart';
import 'package:sintetico/features/detalle_empresa/components/tarjeta_cancha.dart';
import 'package:sintetico/models/cancha.dart';
import '../../../config/theme/dimensions.dart';

class CourtListSection extends StatelessWidget {
  final List<CourtModel> courts;
  final String companyName;

  const CourtListSection({
    super.key,
    required this.courts,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el número de columnas según el ancho
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getAspectRatio(constraints.maxWidth);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: AppDimensions.paddingMedium,
              mainAxisSpacing: AppDimensions.paddingMedium,
            ),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              return CourtCard(
                court: courts[index],
                companyName: companyName,
              );
            },
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Móvil
    } else if (width < 900) {
      return 2; // Tablet
    } else if (width < 1200) {
      return 3; // Desktop pequeño
    } else {
      return 4; // Desktop grande
    }
  }

  double _getAspectRatio(double width) {
    if (width < 600) {
      return 1.2; // Móvil - más alto
    } else if (width < 900) {
      return 1.1; // Tablet
    } else {
      return 1.0; // Desktop - cuadrado
    }
  }
}