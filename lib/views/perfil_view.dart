import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/barra_navegacion.dart';
import 'package:sintetico/components/barra_navegacion_empresa.dart';
import 'package:sintetico/features/perfil/components/avatar.dart';
import 'package:sintetico/features/perfil/components/cambiar_password.dart';
import 'package:sintetico/features/perfil/components/formulario_perfil_empresa.dart';
import 'package:sintetico/features/perfil/components/formulario_perfil_usuario.dart';
import 'package:sintetico/features/perfil/components/seccion_informacion.dart';
import 'package:sintetico/features/perfil/controllers/controlador_perfil.dart';
import 'package:sintetico/models/cliente.dart';
import 'package:sintetico/models/empresa.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos del perfil al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().initializeProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50], // O usa AppColors.background

          // Barra de navegación condicional según el tipo de usuario
          appBar: controller.isCompany
              ? NavigationEmpresa(
                  selectedIndex: 1, // Perfil seleccionado
                  onItemSelected: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushReplacementNamed(
                            context, '/empresa_dashboard');
                        break;
                      case 1:
                        // Ya estás en perfil
                        break;
                    }
                  },
                )
              : null, // Para clientes no hay AppBar, solo bottomNavigationBar

          // Barra inferior solo para clientes
          bottomNavigationBar: !controller.isCompany
              ? CustomBottomNavBar(
                  currentIndex: 2, // Perfil seleccionado
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushReplacementNamed(
                            context, '/cliente_dashboard');
                        break;
                      case 1:
                        Navigator.pushReplacementNamed(
                            context, '/historial_reservas');
                        break;
                      case 2:
                        // Ya estás en perfil
                        break;
                    }
                  },
                )
              : null,

          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(ProfileController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.initializeProfile(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (controller.userData == null) {
      return const Center(
        child: Text('No se encontraron datos del perfil'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Diseño responsivo
        final isDesktop = constraints.maxWidth > 1200;
        final isTablet =
            constraints.maxWidth > 600 && constraints.maxWidth <= 1200;

        return SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              padding: EdgeInsets.all(
                isDesktop ? 32 : (isTablet ? 24 : 16),
              ),
              child: Column(
                children: [
                  // Header del perfil
                  _buildProfileHeader(controller, constraints),
                  const SizedBox(height: 32),

                  // Contenido principal
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildMainContent(controller),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _buildSideContent(controller),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildMainContent(controller),
                        const SizedBox(height: 24),
                        _buildSideContent(controller),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
      ProfileController controller, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth <= 600;
    String initials = '';
    String displayName = '';

    if (controller.isCompany) {
      final company = controller.userData as CompanyModel;
      initials = company.name.isNotEmpty ? company.name[0] : 'E';
      displayName = company.name;
    } else {
      final user = controller.userData as UserModel;
      initials =
          '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}';
      displayName = '${user.firstName} ${user.lastName}'.trim();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                ProfileAvatar(
                  initials: initials,
                  imageUrl: controller.isCompany
                      ? (controller.userData as CompanyModel).logo
                      : null,
                  size: 100,
                  onTap: () {
                    // Implementar cambio de imagen
                    _showImagePickerDialog();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getUserTypeLabel(controller.userType),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                ProfileAvatar(
                  initials: initials,
                  imageUrl: controller.isCompany
                      ? (controller.userData as CompanyModel).logo
                      : null,
                  size: 120,
                  onTap: () {
                    _showImagePickerDialog();
                  },
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getUserTypeLabel(controller.userType),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMainContent(ProfileController controller) {
    if (_isEditingProfile) {
      return ProfileInfoSection(
        title: 'Editar información',
        showEditButton: false,
        children: [
          if (controller.isCompany)
            CompanyEditForm(
              companyData: controller.userData as CompanyModel,
              onSave: (updatedData) async {
                final success = await controller.updateProfile(updatedData);
                if (success) {
                  setState(() {
                    _isEditingProfile = false;
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          controller.errorMessage ?? 'Error al actualizar'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onCancel: () {
                setState(() {
                  _isEditingProfile = false;
                });
              },
            )
          else
            UserEditForm(
              userData: controller.userData as UserModel,
              onSave: (updatedData) async {
                final success = await controller.updateProfile(updatedData);
                if (success) {
                  setState(() {
                    _isEditingProfile = false;
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          controller.errorMessage ?? 'Error al actualizar'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onCancel: () {
                setState(() {
                  _isEditingProfile = false;
                });
              },
            ),
        ],
      );
    }

    return ProfileInfoSection(
      title: 'Información personal',
      onEdit: () {
        setState(() {
          _isEditingProfile = true;
        });
      },
      children: [
        if (controller.isCompany)
          ..._buildCompanyInfo(controller.userData as CompanyModel)
        else
          ..._buildUserInfo(controller.userData as UserModel),
      ],
    );
  }

  List<Widget> _buildUserInfo(UserModel user) {
    return [
      _buildInfoRow('Nombre completo', '${user.firstName} ${user.lastName}'),
      const SizedBox(height: 12),
      _buildInfoRow('Correo electrónico', user.email),
      const SizedBox(height: 12),
      _buildInfoRow('Teléfono', user.phone),
    ];
  }

  List<Widget> _buildCompanyInfo(CompanyModel company) {
    return [
      _buildInfoRow('Nombre', company.name),
      const SizedBox(height: 12),
      _buildInfoRow('Descripción', company.description),
      const SizedBox(height: 12),
      _buildInfoRow('Dirección', company.address),
      const SizedBox(height: 12),
      _buildInfoRow(
          'Horario', '${company.openingTime} - ${company.closingTime}'),
      if (company.email != null) ...[
        const SizedBox(height: 12),
        _buildInfoRow('Correo', company.email!),
      ],
      if (company.phoneNumber != null) ...[
        const SizedBox(height: 12),
        _buildInfoRow('Teléfono', company.phoneNumber!),
      ],
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideContent(ProfileController controller) {
    return Column(
      children: [
        ProfileInfoSection(
          title: 'Seguridad',
          showEditButton: false,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar contraseña'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(controller),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleSignOut(controller),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getUserTypeLabel(String? userType) {
    switch (userType) {
      case 'clients':
        return 'Cliente';
      case 'empresas':
        return 'Empresa';
      case 'SuperAdmin':
        return 'Super Administrador';
      default:
        return 'Usuario';
    }
  }

  void _showImagePickerDialog() {
    // Implementar selector de imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de cambio de imagen próximamente'),
      ),
    );
  }

  void _showChangePasswordDialog(ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onConfirm: (currentPassword, newPassword) async {
          final success = await controller.updatePassword(
            currentPassword,
            newPassword,
          );

          if (success) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    controller.errorMessage ?? 'Error al cambiar contraseña'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleSignOut(ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacementNamed('/sintetico');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
