import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints ajustados para mejor control
  static const double smallMobileBreakpoint = 360;
  static const double mobileBreakpoint = 500;
  static const double tabletBreakpoint = 800;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  static String getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < smallMobileBreakpoint) {
      return 'smallMobile';
    } else if (width < mobileBreakpoint) {
      return 'mobile';
    } else if (width < tabletBreakpoint) {
      return 'tablet';
    } else if (width < largeDesktopBreakpoint) {
      return 'desktop';
    } else {
      return 'largeDesktop';
    }
  }

  static double getResponsiveSize(BuildContext context, double size, {double baseWidth = 1440}) {
    final double width = MediaQuery.of(context).size.width;
    final double scale = width / baseWidth;
    final double adjustedSize = size * scale;
    // Limitar tamaños para evitar que sean demasiado pequeños o grandes
    return adjustedSize.clamp(size * 0.7, size * 1.3);
  }

  static int getGridColumns(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < smallMobileBreakpoint) {
      return 1;
    } else if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else if (width < desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final String deviceType = getDeviceType(context);
    switch (deviceType) {
      case 'smallMobile':
        return const EdgeInsets.all(8);
      case 'mobile':
        return const EdgeInsets.all(12);
      case 'tablet':
        return const EdgeInsets.all(16);
      case 'desktop':
      case 'largeDesktop':
      default:
        return const EdgeInsets.all(20);
    }
  }

  static double getGridAspectRatio(BuildContext context) {
    final String deviceType = getDeviceType(context);
    switch (deviceType) {
      case 'smallMobile':
        return 0.65;
      case 'mobile':
        return 0.7;
      case 'tablet':
        return 0.75;
      case 'desktop':
      case 'largeDesktop':
      default:
        return 0.8;
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final double size = getResponsiveSize(context, baseFontSize);
    // Asegurar que las fuentes no sean demasiado pequeñas
    return size.clamp(baseFontSize * 0.8, baseFontSize * 1.2);
  }

  static double getMaxContentWidth(BuildContext context, {double maxWidth = 1200}) {
    final double width = MediaQuery.of(context).size.width;
    return width > maxWidth ? maxWidth : width;
  }

  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    return getResponsiveSize(context, baseIconSize).clamp(baseIconSize * 0.8, baseIconSize * 1.2);
  }
}