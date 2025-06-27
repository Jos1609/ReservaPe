import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sintetico/features/perfil/components/campos_texto.dart';
import 'package:sintetico/models/cliente.dart';

class UserEditForm extends StatefulWidget {
  final UserModel userData;
  final Function(UserModel) onSave;
  final VoidCallback onCancel;

  const UserEditForm({
    super.key,
    required this.userData,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userData.firstName);
    _lastNameController = TextEditingController(text: widget.userData.lastName);
    _phoneController = TextEditingController(text: widget.userData.phone);
    _emailController = TextEditingController(text: widget.userData.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ProfileTextField(
            label: 'Nombre',
            controller: _firstNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // O usa AppDimensions.paddingMedium
          
          ProfileTextField(
            label: 'Apellido',
            controller: _lastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu apellido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          ProfileTextField(
            label: 'Teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              if (value.length < 10) {
                return 'El teléfono debe tener 10 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          ProfileTextField(
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: false, // Email no se puede cambiar
          ),
          const SizedBox(height: 24), // O usa AppDimensions.paddingLarge
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey[600], // O usa AppColors.textSecondary
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // O usa AppDimensions.radiusMedium
                  ),
                ),
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
      widget.onSave(updatedUser);
    }
  }
}