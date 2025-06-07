import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/features/admin_empresas/components/map_selection_screen.dart';
import 'package:sintetico/features/admin_empresas/controllers/registrar_empresa_controlador.dart';
import 'dart:io';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';
import '../../../components/ui/rounded_button.dart';
import '../../features/admin_empresas/components/text_input_field.dart';

class RegisterCompanyModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el modal al tocar fuera
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => RegisterCompanyController(),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadius * 1.5),
            ),
            elevation: 8,
            backgroundColor: AppColors.white, // Fondo blanco sólido
            child: Container(
              // Ajusta el ancho según el tamaño de la pantalla
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width *
                        0.95 // 95% del ancho en pantallas pequeñas
                    : 800, // Ancho fijo para pantallas grandes
                maxHeight: 900,
              ),
              child: _RegisterCompanyModalContent(),
            ),
          ),
        );
      },
    );
  }
}

class _RegisterCompanyModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterCompanyController>(
      builder: (context, controller, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white, // Fondo blanco sólido
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadius * 1.5),
          ),
          child: Column(
            children: [
              // Encabezado con botón de cerrar
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.borderRadius * 1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registrar Nueva Empresa',
                      style: AppTextStyles.heading3(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.gray),
                      onPressed: () =>
                          Navigator.of(context).pop(), // Cierra solo con la "X"
                    ),
                  ],
                ),
              ),
              // Contenido del formulario
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado del formulario
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingLarge),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppDimensions.paddingMedium),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.business,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              'Registrar Nueva Empresa',
                              style: AppTextStyles.heading3(context),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              'Completa todos los campos para agregar una nueva empresa',
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.gray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge * 1.5),
                      // Formulario
                      Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información Básica
                            _buildSectionHeader('Información Básica',
                                Icons.info_outline, context),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: TextInputFieldEmpresas(
                                label: 'Nombre de la Empresa*',
                                controller: controller.nameController,
                                validator: (value) =>
                                    value!.isEmpty ? 'Ingresa el nombre' : null,
                                placeholder: 'Nombre de la Empresa',
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: Row(
                                children: [
                                  // Campo de Email
                                  Expanded(
                                    flex: 1,
                                    child: TextInputFieldEmpresas(
                                      label: 'Correo Electrónico*',
                                      controller: controller.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) => value!.isEmpty
                                          ? 'Ingresa el correo electrónico'
                                          : null,
                                      placeholder: 'correo@empresa.com',
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 16), // Espacio entre campos
                                  // Campo de Celular
                                  Expanded(
                                    flex: 1,
                                    child: TextInputFieldEmpresas(
                                      label: 'Celular*',
                                      controller: controller
                                          .phoneController, // Asegúrate de tener este controller
                                      keyboardType: TextInputType.phone,
                                      validator: (value) => value!.isEmpty
                                          ? 'Ingresa el número de celular'
                                          : null,
                                      placeholder: '+51 999 999 999',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Estado*',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusSmall),
                                    borderSide: BorderSide(
                                        color: AppColors.gray.withOpacity(0.3)),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'activo', child: Text('Activo')),
                                  DropdownMenuItem(
                                      value: 'inactivo',
                                      child: Text('Inactivo')),
                                  DropdownMenuItem(
                                      value: 'mantenimiento',
                                      child: Text('En Mantenimiento')),
                                ],
                                onChanged: (value) =>
                                    controller.status = value!,
                                validator: (value) => value == null
                                    ? 'Selecciona un estado'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: TextInputFieldEmpresas(
                                label: 'Descripción*',
                                controller: controller.descriptionController,
                                maxLines: 4,
                                validator: (value) => value!.isEmpty
                                    ? 'Ingresa una descripción'
                                    : null,
                              ),
                            ),
                            // Logo
                            const SizedBox(height: AppDimensions.paddingLarge),
                            _buildSectionHeader(
                                'Logo de la Empresa', Icons.image, context),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: GestureDetector(
                                onTap: controller.pickLogo,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                      AppDimensions.paddingLarge),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.gray,
                                        style: BorderStyle.solid,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusSmall),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.image,
                                          size: 40, color: AppColors.gray),
                                      const SizedBox(
                                          height: AppDimensions.paddingSmall),
                                      Text(
                                        'Haz clic para subir un logo (opcional)',
                                        style: AppTextStyles.body(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (controller.logo != null)
                              Container(
                                width: 150,
                                height: 150,
                                margin: const EdgeInsets.only(
                                    top: AppDimensions.paddingMedium),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.light),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSmall),
                                  image: DecorationImage(
                                    image:
                                        FileImage(File(controller.logo!.path)),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            // Horario
                            const SizedBox(height: AppDimensions.paddingLarge),
                            _buildSectionHeader('Horario de Atención',
                                Icons.access_time, context),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputContainer(
                                    child: TextInputFieldEmpresas(
                                      label: 'Apertura*',
                                      controller:
                                          controller.openingTimeController,
                                      readOnly: true,
                                      validator: (value) => value!.isEmpty
                                          ? 'Ingresa la hora de apertura'
                                          : null,
                                      onTap: () => controller
                                          .selectTime(context, isOpening: true),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingMedium),
                                Expanded(
                                  child: _buildInputContainer(
                                    child: TextInputFieldEmpresas(
                                      label: 'Cierre*',
                                      controller:
                                          controller.closingTimeController,
                                      readOnly: true,
                                      validator: (value) => value!.isEmpty
                                          ? 'Ingresa la hora de cierre'
                                          : null,
                                      onTap: () => controller.selectTime(
                                          context,
                                          isOpening: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Servicios
                            const SizedBox(height: AppDimensions.paddingLarge),
                            _buildSectionHeader(
                                'Servicios Ofrecidos', Icons.list, context),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputContainer(
                                    child: TextInputFieldEmpresas(
                                      label: 'Agregar Servicio',
                                      controller: controller.serviceController,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingSmall),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: AppColors.primary),
                                  onPressed: controller.addService,
                                ),
                              ],
                            ),
                            if (controller.services.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppDimensions.paddingMedium),
                                child: Wrap(
                                  spacing: AppDimensions.paddingSmall,
                                  runSpacing: AppDimensions.paddingSmall,
                                  children: controller.services.map((service) {
                                    return Chip(
                                      label: Text(service),
                                      deleteIcon: const Icon(Icons.close,
                                          size: 16, color: AppColors.error),
                                      onDeleted: () =>
                                          controller.removeService(service),
                                      backgroundColor: AppColors.light,
                                    );
                                  }).toList(),
                                ),
                              ),
                            // Dirección
                            const SizedBox(height: AppDimensions.paddingLarge),
                            _buildSectionHeader(
                                'Ubicación', Icons.location_on, context),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            _buildInputContainer(
                              child: TextInputFieldEmpresas(
                                label: 'Dirección*',
                                controller: controller.addressController,
                                validator: (value) => value!.isEmpty
                                    ? 'Ingresa la dirección'
                                    : null,
                              ),
                            ),
                            // Coordenadas
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputContainer(
                                    child: TextInputFieldEmpresas(
                                      label: 'Latitud*',
                                      controller: controller.latitudeController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (value) => value!.isEmpty ||
                                              double.tryParse(value) == null
                                          ? 'Ingresa una latitud válida'
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingMedium),
                                Expanded(
                                  child: _buildInputContainer(
                                    child: TextInputFieldEmpresas(
                                      label: 'Longitud*',
                                      controller:
                                          controller.longitudeController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (value) => value!.isEmpty ||
                                              double.tryParse(value) == null
                                          ? 'Ingresa una longitud válida'
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Botón para abrir mapa
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  MapSelectionModal.show(context, controller);
                                },
                                icon: const Icon(Icons.map),
                                label: const Text('Seleccionar en Mapa'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            // Mostrar coordenadas seleccionadas
                            if (controller.selectedPosition != null)
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppDimensions.paddingMedium),
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingMedium),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSmall),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 16),
                                    const SizedBox(
                                        width: AppDimensions.paddingSmall),
                                    Expanded(
                                      child: Text(
                                        'Ubicación seleccionada: ${controller.selectedPosition!.latitude.toStringAsFixed(6)}, ${controller.selectedPosition!.longitude.toStringAsFixed(6)}',
                                        style: AppTextStyles.body(context)
                                            .copyWith(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Mensaje de error
                            if (controller.errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppDimensions.paddingMedium),
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingMedium),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSmall),
                                  border: Border.all(
                                      color: AppColors.error.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: AppColors.error, size: 20),
                                    const SizedBox(
                                        width: AppDimensions.paddingSmall),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage!,
                                        style: AppTextStyles.body(context)
                                            .copyWith(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Botón de registro
                            const SizedBox(
                                height: AppDimensions.paddingLarge * 2),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: RoundedButton(
                                  text: controller.isLoading
                                      ? 'Registrando...'
                                      : 'Registrar Empresa',
                                  onPressed: () {
                                    if (controller.isLoading) return;
                                    controller.registerCompany(
                                        context); // No cierra el modal
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
        horizontal: AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(title, style: AppTextStyles.bodyBold(context)),
        ],
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: child,
      ),
    );
  }
}
