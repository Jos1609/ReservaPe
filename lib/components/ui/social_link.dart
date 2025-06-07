import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';

class SocialLink extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialLink({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: AppColors.white,
        size: 24,
      ),
      onPressed: onPressed,
    );
  }
}