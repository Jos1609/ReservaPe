// components/composite/navigation_bar.dart
import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/text_styles.dart';
import '../../config/theme/dimensions.dart';

/// Barra de navegación responsiva "Navegación Empresa"
class NavigationEmpresa extends StatelessWidget implements PreferredSizeWidget {
  /// Índice del elemento seleccionado actualmente
  final int selectedIndex;
  
  /// Callback cuando se selecciona un elemento
  final ValueChanged<int>? onItemSelected;
  
  const NavigationEmpresa({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si usar diseño móvil basado en el ancho de pantalla
        final isCompact = constraints.maxWidth < 768;
        
        if (isCompact) {
          return _buildMobileNavigation(context);
        } else {
          return _buildDesktopNavigation(context);
        }
      },
    );
  }

  /// Construye la navegación para dispositivos móviles
  Widget _buildMobileNavigation(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 2,
      title: Text(
        'Navegación Empresa',
        style: AppTextStyles.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // Menú hamburguesa para móvil
        PopupMenuButton<int>(
          icon: const Icon(Icons.menu),
          onSelected: onItemSelected,
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 0,
              child: _buildMenuItem(
                Icons.home_outlined,
                Icons.home,
                'Inicio',
                0,
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: _buildMenuItem(
                Icons.person_outline,
                Icons.person,
                'Perfil',
                1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la navegación para desktop/tablet
  Widget _buildDesktopNavigation(BuildContext context) {
    return Container(
      height: AppDimensions.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Row(
          children: [
            // Logo/Título de la empresa
            Text(
              'Navegación Empresa',
              style: AppTextStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const Spacer(),
            
            // Elementos de navegación
            Row(
              children: [
                _buildNavItem(
                  Icons.home_outlined,
                  Icons.home,
                  'Inicio',
                  0,
                ),
                SizedBox(width: AppDimensions.spacingLarge),
                _buildNavItem(
                  Icons.person_outline,
                  Icons.person,
                  'Perfil',
                  1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de navegación para desktop
  Widget _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => onItemSelected?.call(index),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: AppDimensions.iconSmall,
            ),
            SizedBox(width: AppDimensions.spacingSmall),
            Text(
              label,
              style: AppTextStyles.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de menú para el popup en móvil
  Widget _buildMenuItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = selectedIndex == index;
    
    return Row(
      children: [
        Icon(
          isSelected ? filledIcon : outlinedIcon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: AppDimensions.iconSmall,
        ),
        SizedBox(width: AppDimensions.spacingMedium),
        Text(
          label,
          style: AppTextStyles.bodyMedium?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppDimensions.navBarHeight);
}