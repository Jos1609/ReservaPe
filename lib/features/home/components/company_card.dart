import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/models/empresa.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/text_styles.dart';

class HomeCompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onPressed;

  const HomeCompanyCard({
    super.key,
    required this.company,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 600;
    final isMedium = screenSize.width >= 600 && screenSize.width < 900;
    final isLarge = screenSize.width >= 900;

    final cardWidth = isSmall
        ? double.infinity
        : isMedium
            ? screenSize.width * 0.45
            : 360.0;

    final cardHeight = isSmall
        ? null
        : isMedium
            ? 420.0
            : 1200.0;

    final textScale = isSmall ? 0.9 : 1.0;
    final padding = isSmall ? 12.0 : 16.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen con altura proporcional
          AspectRatio(
            aspectRatio: isSmall
                ? 16 / 9
                : isLarge
                    ? 16 / 10
                    : 4 / 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: company.logo != null
                      ? Image.network(
                          company.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.backgroundLight,
                            child: Center(
                                child: Icon(Icons.broken_image, size: 40)),
                          ),
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Image.network(
                          'https://st2.depositphotos.com/1998651/6951/v/450/depositphotos_69511739-stock-illustration-football-field-top-view.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.backgroundLight,
                            child: Center(
                                child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Contenido flexible
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    // Título con etiqueta de estado al lado derecho
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Nombre de la empresa
                        Expanded(
                          child: Text(
                            company.name,
                            style: AppTextStyles.heading3(context).copyWith(
                              fontSize:
                                  (AppTextStyles.heading3(context).fontSize ??
                                          16) *
                                      textScale,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Etiqueta de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (company.status == 'active')
                                ? const Color.fromARGB(255, 237, 242, 237)
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.99)
                                // ignore: deprecated_member_use
                                : Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            company.status == 'active' ? "Abierto" : "Cerrado",
                            style: AppTextStyles.body(context).copyWith(
                              fontSize:
                                  (AppTextStyles.body(context).fontSize ?? 14) *
                                      textScale,
                              color: const Color.fromARGB(255, 1, 243, 50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Horario de atención (nuevo campo)
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 18 * textScale, color: AppColors.textLight),
                        SizedBox(width: 6),
                        Text(
                          company.openingTime.isNotEmpty
                              ? '${company.openingTime} - ${company.closingTime}'
                              : 'Horario no disponible',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize:
                                (AppTextStyles.body(context).fontSize ?? 14) *
                                    textScale,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Descripción con más líneas en pantallas grandes
                    Text(
                      company.description,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: (AppTextStyles.body(context).fontSize ?? 14) *
                            textScale,
                        height: 1.4,
                      ),
                      maxLines: isSmall
                          ? 2
                          : isLarge
                              ? 5
                              : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Servicios (nuevo campo)
                    if (company.services.isNotEmpty) ...[
                      Text(
                        'Servicios:',
                        style: AppTextStyles.body(context).copyWith(
                          fontSize:
                              (AppTextStyles.body(context).fontSize ?? 12) *
                                  textScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: company.services
                            .take(isSmall
                                ? 3
                                : isMedium
                                    ? 4
                                    : 6)
                            .map((service) => Chip(
                                  label: Text(service),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Dirección
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18 * textScale, color: AppColors.textLight),
                        SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            company.address,
                            style: AppTextStyles.body(context).copyWith(
                              fontSize:
                                  (AppTextStyles.body(context).fontSize ?? 14) *
                                      textScale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
