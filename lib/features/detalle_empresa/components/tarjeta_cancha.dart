import 'package:flutter/material.dart';
import 'package:sintetico/features/detalle_cancha/components/carrusel_imagenes.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/views/cliente/detalle_cancha.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';

class CourtCard extends StatefulWidget {
  final CourtModel court;
  final String companyName;

  const CourtCard({
    super.key,
    required this.court,
    required this.companyName,
  });

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinamos si es una pantalla pequeña
        final isSmallScreen = constraints.maxWidth < 360;
        final isMediumScreen = constraints.maxWidth < 600;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourtDetailsView(
                  courtId: widget.court.id,
                  companyName: widget.companyName,
                ),
              ),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 280 : 320,
              maxHeight: isSmallScreen ? 350 : 400,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carrusel de imágenes con altura fija responsiva
                _buildImageSection(isSmallScreen),

                // Información de la cancha
                Expanded(
                  child: _buildInfoSection(isSmallScreen, isMediumScreen),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 120 : 160,
      child: Stack(
        children: [
          // Carrusel de imágenes
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.borderRadius),
              topRight: Radius.circular(AppDimensions.borderRadius),
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

          // Badges responsivos
          Positioned(
            top: AppDimensions.paddingSmall,
            left: AppDimensions.paddingSmall,
            right: AppDimensions.paddingSmall,
            child: _buildBadgesRow(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesRow(bool isSmallScreen) {
    return Wrap(
      spacing: AppDimensions.paddingXSmall,
      runSpacing: AppDimensions.paddingXSmall,
      children: [
        // Tipo de deporte
        _buildBadge(
          icon: _getSportIcon(widget.court.sportType),
          label: isSmallScreen
              ? _getShortSportName(widget.court.sportType)
              : widget.court.sportType,
          backgroundColor: AppColors.primary,
          isSmall: isSmallScreen,
        ),

        // Indicador de techo
        if (widget.court.hasRoof)
          _buildBadge(
            icon: Icons.roofing,
            label: isSmallScreen ? 'Techo' : 'Techada',
            backgroundColor: AppColors.secondary,
            isSmall: isSmallScreen,
          ),
      ],
    );
  }

  Widget _buildInfoSection(bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.all(
        isSmallScreen
            ? AppDimensions.paddingSmall
            : AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre de la cancha
          Flexible(
            child: Text(
              widget.court.name,
              style: isSmallScreen
                  ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)
                  : AppTextStyles.h3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: AppDimensions.paddingXSmall),

          // Material y capacidad
          _buildCourtDetails(isSmallScreen),

          const Spacer(),

          // Precios
          _buildPriceSection(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildCourtDetails(bool isSmallScreen) {
    return Wrap(
      spacing: isSmallScreen ? 8 : AppDimensions.paddingMedium,
      runSpacing: 4,
      children: [
        _buildDetailItem(
          icon: Icons.grass,
          text: widget.court.material,
          isSmall: isSmallScreen,
        ),
        _buildDetailItem(
          icon: Icons.group,
          text: '${widget.court.teamCapacity}v${widget.court.teamCapacity}',
          isSmall: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required bool isSmall,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isSmall ? 12 : 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: (isSmall ? AppTextStyles.caption2 : AppTextStyles.caption1)
                .copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isSmallScreen
            ? AppDimensions.paddingXSmall
            : AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildPriceItem(
                icon: Icons.wb_sunny,
                label: 'Día',
                price: widget.court.dayPrice,
                isSmall: isSmallScreen,
              ),
            ),
            Container(
              width: 1,
              color: AppColors.divider,
              margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
              ),
            ),
            Expanded(
              child: _buildPriceItem(
                icon: Icons.nightlight_round,
                label: 'Noche',
                price: widget.court.nightPrice,
                isSmall: isSmallScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem({
    required IconData icon,
    required String label,
    required double price,
    required bool isSmall,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style:
                    (isSmall ? AppTextStyles.caption2 : AppTextStyles.caption1)
                        .copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'S/ ${price.toStringAsFixed(2)}',
            style: (isSmall ? AppTextStyles.caption1 : AppTextStyles.body2)
                .copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : AppDimensions.paddingSmall,
        vertical: isSmall ? 4 : AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 12 : 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: (isSmall ? AppTextStyles.caption2 : AppTextStyles.caption1)
                  .copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortSportName(String sportType) {
    final sport = sportType.toLowerCase();

    if (sport.contains('fútbol') || sport.contains('futbol')) {
      return 'Fútbol';
    } else if (sport.contains('básquet') || sport.contains('basket')) {
      return 'Basket';
    } else if (sport.contains('vóley') || sport.contains('voley')) {
      return 'Vóley';
    } else if (sport.contains('tenis')) {
      return 'Tenis';
    } else if (sport.contains('padel')) {
      return 'Padel';
    }

    return sportType.length > 8 ? '${sportType.substring(0, 8)}...' : sportType;
  }

  IconData _getSportIcon(String sportType) {
    final sport = sportType.toLowerCase();

    if (sport.contains('fútbol') ||
        sport.contains('futbol') ||
        sport.contains('soccer')) {
      return Icons.sports_soccer;
    } else if (sport.contains('básquet') || sport.contains('basket')) {
      return Icons.sports_basketball;
    } else if (sport.contains('vóley') ||
        sport.contains('voley') ||
        sport.contains('volley')) {
      return Icons.sports_volleyball;
    } else if (sport.contains('tenis') || sport.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (sport.contains('padel') || sport.contains('paddle')) {
      return Icons.sports_tennis;
    }

    return Icons.sports;
  }
}