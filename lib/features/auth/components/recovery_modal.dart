import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/auth/components/custom_input.dart';
import 'package:sintetico/features/auth/components/login_screen.dart';
import 'package:sintetico/features/auth/controllers/recovery_controller.dart';

class RecoveryModal extends StatelessWidget {
  const RecoveryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecoveryController(),
      child: const _RecoveryModalContent(),
    );
  }
}

class _RecoveryModalContent extends StatefulWidget {
  const _RecoveryModalContent();

  @override
  _RecoveryModalContentState createState() => _RecoveryModalContentState();
}

class _RecoveryModalContentState extends State<_RecoveryModalContent> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RecoveryController>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white70,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Recuperar Contraseña',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppDimensions.paddingExtraSmall),
                  Text(
                    'Ingresa tu correo para restablecerla',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  if (controller.isSuccess)
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(height: AppDimensions.paddingSmall),
                          Text(
                            '¡Correo enviado!',
                            style: AppTextStyles.heading3(context).copyWith(color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: AppDimensions.paddingExtraSmall),
                          Text(
                            'Hemos enviado un enlace de recuperación a tu correo electrónico.',
                            style: AppTextStyles.body(context).copyWith(color: AppColors.primaryDark),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Text(
                      'Ingresa la dirección de correo electrónico asociada a tu cuenta y te enviaremos un enlace para restablecer tu contraseña.',
                      style: AppTextStyles.body(context).copyWith(color: AppColors.dark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    CustomInput(
                      label: 'Correo Electrónico',
                      placeholder: 'tucorreo@ejemplo.com',
                      controller: _emailController,
                      errorText: controller.errorMessage,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final success = await controller.recoverPassword(
                                _emailController.text.trim(),
                              );
                              if (success) {
                                // El mensaje de éxito se muestra automáticamente
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                      ),
                      child: controller.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingSmall),
                                Text('Enviando...', style: AppTextStyles.buttonText),
                              ],
                            )
                          : Text('Enviar enlace de recuperación', style: AppTextStyles.buttonText),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.paddingMedium),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      LoginDialog.show(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_left, color: AppColors.primary),
                        Text(
                          'Volver al inicio de sesión',
                          style: AppTextStyles.linkText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}