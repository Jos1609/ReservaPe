// lib/components/ui/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/dimensions.dart';

class CustomBottomNavBar extends StatelessWidget {
  /// Índice del tab actualmente seleccionado (0: Inicio, 1: Historial, 2: Perfil)
  final int currentIndex;
  
  /// Callback que se ejecuta cuando se selecciona un tab
  final Function(int) onTap;
  
  /// Constructor de la barra de navegación
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Determinar si es una pantalla grande (tablet/desktop)
    final isLargeScreen = screenWidth > 600;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.navBarBackgroundDark : AppColors.navBarBackground,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: isLargeScreen ? 70 : 60,
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? AppDimensions.paddingXL : AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Inicio',
                index: 0,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.history_rounded,
                label: 'Historial',
                index: 1,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_rounded,
                label: 'Perfil',
                index: 2,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un elemento individual de navegación
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    // Colores según el estado y tema
    final activeColor = AppColors.navItemActive;
    final inactiveColor = isDarkMode 
        ? AppColors.navItemInactiveDark 
        : AppColors.navItemInactive;
    
    final currentColor = isActive ? activeColor : inactiveColor;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: activeColor.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.paddingXS,
              horizontal: AppDimensions.paddingS,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono con animación de escala
                AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    icon,
                    color: currentColor,
                    size: isLargeScreen ? 26 : 24,
                  ),
                ),
                
                SizedBox(height: AppDimensions.spacingXS),
                
                // Etiqueta con animación de color
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: currentColor,
                    fontSize: isLargeScreen ? 12 : 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Indicador de estado activo
                SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 2,
                  width: isActive ? 20 : 0,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enumeración para los índices de navegación
/// Facilita el manejo de los estados de navegación
enum NavIndex {
  home(0),
  history(1), 
  profile(2);
  
  const NavIndex(this.value);
  final int value;
}