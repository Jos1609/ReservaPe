import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/constants/strings_home.dart';
import 'package:sintetico/features/auth/components/custom_input.dart';
import 'package:sintetico/features/auth/components/login_screen.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../features/auth/controllers/register_controller.dart';

class RegisterModal extends StatelessWidget {
  const RegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: const _RegisterModalContent(),
    );
  }
}

class _RegisterModalContent extends StatefulWidget {
  const _RegisterModalContent();

  @override
  _RegisterModalContentState createState() => _RegisterModalContentState();
}

class _RegisterModalContentState extends State<_RegisterModalContent> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);

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
                    AppStrings.textcrearcuenta,
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppDimensions.paddingExtraSmall),
                  Text(
                    'Crea tu cuenta para reservar canchas',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  CustomInput(
                    label: 'Nombres',
                    placeholder: 'Ingresa tus nombres',
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomInput(
                    label: 'Apellidos',
                    placeholder: 'Ingresa tus apellidos',
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomInput(
                    label: 'Celular',
                    placeholder: 'Ingresa tu número celular',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomInput(
                    label: 'Correo Electrónico',
                    placeholder: 'tucorreo@ejemplo.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomInput(
                    label: 'Contraseña',
                    placeholder: 'Crea una contraseña segura',
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomInput(
                    label: 'Confirmar Contraseña',
                    placeholder: 'Repite tu contraseña',
                    isPassword: true,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  if (controller.errorMessage != null)
                    Text(
                      controller.errorMessage!,
                      style: AppTextStyles.body(context).copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            final success = await controller.register(
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                            );
                            if (success) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                              // Opcional: Navegar a otra pantalla
                              // Navigator.pushReplacementNamed(context, '/home');
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
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(width: AppDimensions.paddingSmall),
                              Text('Creando cuenta...', style: AppTextStyles.buttonText),
                            ],
                          )
                        : Text('Registrarse', style: AppTextStyles.buttonText),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      LoginDialog.show(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes una cuenta? ',
                        style: AppTextStyles.body(context).copyWith(color: AppColors.gray),
                        children: [
                          TextSpan(
                            text: 'Inicia sesión aquí',
                            style: AppTextStyles.linkText,
                            
                          ),
                        ],
                      ),
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