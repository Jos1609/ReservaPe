import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/auth/components/register_screen.dart';
import 'package:sintetico/features/auth/components/text_input_field.dart';
import '../controllers/login_controller.dart';
import './recovery_modal.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => ChangeNotifierProvider(
        create: (_) => LoginController(),
        child: const LoginDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 520
            ? (MediaQuery.of(context).size.width - 500) / 2
            : 20,
        vertical: 20,
      ),
      child: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Consumer<LoginController>(
              builder: (context, controller, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón de cerrar - deshabilitado durante carga
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.close, 
                          color: controller.isLoading 
                            ? AppColors.gray.withOpacity(0.5) 
                            : AppColors.gray
                        ),
                        onPressed: controller.isLoading 
                          ? null 
                          : () => Navigator.of(context).pop(),
                      ),
                    ),

                    // Logo y título
                    Column(
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 50,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Text(
                          'Iniciar Sesión',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'Ingresa tus credenciales',
                          style: AppTextStyles.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge * 1.5),

                    // Formulario
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // Campo de email
                          TextInputField(
                            label: 'Correo Electrónico',
                            placeholder: 'tucorreo@ejemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            controller: controller.emailController,
                            enabled: !controller.isLoading, // Deshabilitar durante carga
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),

                          // Campo de contraseña
                          TextInputField(
                            label: 'Contraseña',
                            placeholder: 'Ingresa tu contraseña',
                            isPassword: true,
                            controller: controller.passwordController,
                            enabled: !controller.isLoading, // Deshabilitar durante carga
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingSmall),

                          // Recordar y olvidé contraseña
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: controller.rememberMe,
                                    onChanged: controller.isLoading 
                                      ? null 
                                      : (value) {
                                          controller.rememberMe = value ?? false;
                                        },
                                    activeColor: AppColors.primary,
                                  ),
                                  Text(
                                    'Recordar sesión',
                                    style: AppTextStyles.body(context).copyWith(
                                      color: controller.isLoading 
                                        ? AppColors.gray.withOpacity(0.5)
                                        : AppColors.gray,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: controller.isLoading 
                                  ? null 
                                  : () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) => const RecoveryModal(),
                                      );
                                    },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: AppTextStyles.linkText.copyWith(
                                    color: controller.isLoading 
                                      ? AppColors.gray.withOpacity(0.5)
                                      : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),

                          // Mensaje de error mejorado con animación
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: controller.errorMessage != null
                              ? Container(
                                  key: ValueKey(controller.errorMessage),
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                    border: Border.all(color: AppColors.error),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                      const SizedBox(width: AppDimensions.paddingSmall),
                                      Expanded(
                                        child: Text(
                                          controller.errorMessage!,
                                          style: AppTextStyles.body(context).copyWith(
                                            color: AppColors.error,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                          ),

                          // Botón de login mejorado con icono de carga
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () => controller.handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isLoading 
                                  ? AppColors.gray.withOpacity(0.3)
                                  : AppColors.primary,
                                foregroundColor: AppColors.white,
                                elevation: controller.isLoading ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                ),
                              ),
                              child: controller.isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.white.withOpacity(0.8)
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Iniciando sesión...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Enlace a registro - deshabilitado durante carga
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta? ',
                          style: AppTextStyles.subtitle.copyWith(
                            color: controller.isLoading 
                              ? AppColors.gray.withOpacity(0.5)
                              : null,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.isLoading 
                            ? null 
                            : () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => const RegisterModal(),
                                );
                              },
                          child: Text(
                            'Regístrate aquí',
                            style: AppTextStyles.linkText.copyWith(
                              color: controller.isLoading 
                                ? AppColors.gray.withOpacity(0.5)
                                : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}