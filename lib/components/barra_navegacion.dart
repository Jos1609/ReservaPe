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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 768;
        
        if (isCompact) {
          return _buildMobileNavigation(context);
        } else {
          return _buildDesktopNavigation(context);
        }
      },
    );
  }

  /// Construye la navegación para móvil (BottomNavigationBar)
  Widget _buildMobileNavigation(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      elevation: 8,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.navItemActive,
      unselectedItemColor: AppColors.navItemInactive,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history_rounded),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  /// Construye la navegación para desktop (AppBar style)
  Widget _buildDesktopNavigation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.navBarBackgroundDark : AppColors.navBarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Row(
          children: [
            // Logo/Título
            Text(
              'Reserva Pe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            
            const Spacer(),
            
            // Elementos de navegación
            Row(
              children: [
                _buildDesktopNavItem(
                  context: context,
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  index: 0,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                SizedBox(width: AppDimensions.spacingLarge),
                _buildDesktopNavItem(
                  context: context,
                  icon: Icons.history_rounded,
                  label: 'Historial',
                  index: 1,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                SizedBox(width: AppDimensions.spacingLarge),
                _buildDesktopNavItem(
                  context: context,
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  index: 2,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de navegación para desktop
  Widget _buildDesktopNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.navItemActive;
    final inactiveColor = isDarkMode 
        ? AppColors.navItemInactiveDark 
        : AppColors.navItemInactive;
    
    final currentColor = isActive ? activeColor : inactiveColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? activeColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: currentColor,
              size: 20,
            ),
            SizedBox(width: AppDimensions.spacingSmall),
            Text(
              label,
              style: TextStyle(
                color: currentColor,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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