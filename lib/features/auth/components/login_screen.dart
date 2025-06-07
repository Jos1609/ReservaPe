import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/ui/rounded_button.dart';
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
                    // Botón de cerrar
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gray),
                        onPressed: () => Navigator.of(context).pop(),
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
                                    onChanged: (value) {
                                      controller.rememberMe = value ?? false;
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                  Text(
                                    'Recordarme',
                                    style: AppTextStyles.body(context),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) => const RecoveryModal(),
                                  );
                                },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: AppTextStyles.linkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),

                          // Mensaje de error mejorado
                          if (controller.errorMessage != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error),
                                  const SizedBox(width: AppDimensions.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage!,
                                      style: AppTextStyles.body(context).copyWith(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Botón de login
                          RoundedButton(
                            text: controller.isLoading ? 'Iniciando...' : 'Iniciar Sesión',
                            onPressed: controller.isLoading
                                ? () {} // Función vacía durante la carga
                                : () => controller.handleLogin(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Enlace a registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta? ',
                          style: AppTextStyles.subtitle,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => const RegisterModal(),
                            );
                          },
                          child: Text(
                            'Regístrate aquí',
                            style: AppTextStyles.linkText,
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