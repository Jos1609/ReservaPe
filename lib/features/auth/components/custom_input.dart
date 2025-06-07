import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isPassword;
  final String? errorText;
  final TextEditingController controller;

  const CustomInput({
    super.key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.errorText,
    required this.controller,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.inputLabel),
        const SizedBox(height: AppDimensions.paddingSmall),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: widget.controller,
              obscureText: widget.isPassword && _obscureText,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppTextStyles.body(context).copyWith(color: AppColors.gray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  borderSide: BorderSide(
                    color: widget.errorText != null ? AppColors.error : AppColors.gray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.inputHeight / 2,
                  horizontal: 15,
                ),
              ),
            ),
            if (widget.isPassword)
              IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.gray,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingExtraSmall),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.body(context).copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}