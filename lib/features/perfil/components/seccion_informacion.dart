import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;
  final bool showEditButton;

  // ignore: use_super_parameters
  const ProfileInfoSection({
    Key? key,
    required this.title,
    required this.children,
    this.onEdit,
    this.showEditButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24), // O usa AppDimensions
      padding: const EdgeInsets.all(20), // O usa AppDimensions.paddingLarge
      decoration: BoxDecoration(
        color: Colors.white, // O usa AppColors.surface
        borderRadius: BorderRadius.circular(16), // O usa AppDimensions.radiusLarge
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18, // O usa AppTextStyles.headlineSmall
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // O usa AppColors.textPrimary
                ),
              ),
              if (showEditButton && onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).primaryColor, // O usa AppColors.primary
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16), // O usa AppDimensions.paddingMedium
          ...children,
        ],
      ),
    );
  }
}