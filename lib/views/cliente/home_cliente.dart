import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/components/barra_navegacion.dart';
import 'package:sintetico/features/home_cliente/components/tarjeta_empresa.dart';
import 'package:sintetico/features/home_cliente/controllers/controlador.dart';
import 'package:sintetico/features/home_cliente/services/empresas_service.dart';
import 'package:sintetico/models/empresa.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/dimensions.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompaniesController(FirestoreService()),
      child: Consumer<CompaniesController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.light,
            body: SafeArea(
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // Header con buscador y filtros
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimensions.spacing),

                          // Buscador mejorado
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadius * 2),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar empresas por nombre o categoría...',
                                // ignore: deprecated_member_use
                                hintStyle: TextStyle(
                                    color: AppColors.gray.withOpacity(0.7)),
                                prefixIcon: Container(
                                  margin: EdgeInsets.all(12),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadius * 2),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: controller.updateSearchQuery,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing * 1.5),

                          // Filtros mejorados
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 12),
                                child: Text(
                                  'Filtrar por estado',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    children: [
                                      _buildFilterChip('Todos', controller,
                                          null, Icons.apps),
                                      _buildFilterChip('Abierto', controller,
                                          'activo', Icons.check_circle),
                                      _buildFilterChip('Cerrado', controller,
                                          'inactivo', Icons.cancel),
                                      _buildFilterChip(
                                          'Mantenimiento',
                                          controller,
                                          'En mantenimiento',
                                          Icons.build),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.spacing * 1.5),
                        ],
                      ),
                    ),
                  ),

                  // Grid de empresas scrollable
                  StreamBuilder<List<CompanyModel>>(
                    stream: controller.getFilteredCompanies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                    strokeWidth: 3,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Cargando empresas...',
                                  style: TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.all(AppDimensions.padding),
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadius),
                                // ignore: deprecated_member_use
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 48),
                                  SizedBox(height: 12),
                                  Text(
                                    'Error al cargar empresas',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Por favor, intenta de nuevo más tarde',
                                    // ignore: deprecated_member_use
                                    style: TextStyle(
                                        color: Colors.red.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final companies = snapshot.data ?? [];

                      if (companies.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: AppColors.gray.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(
                                      Icons.business_outlined,
                                      size: 64,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'No hay empresas disponibles',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Intenta ajustar los filtros de búsqueda',
                                    style: TextStyle(
                                      color: AppColors.gray,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppDimensions.spacing,
                            mainAxisSpacing: AppDimensions.spacing,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: CompanyCard(company: companies[index]),
                              );
                            },
                            childCount: companies.length,
                          ),
                        ),
                      );
                    },
                  ),

                  // Espaciado final para mejor UX
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spacing * 2),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex:
                  0, // Esta pantalla de empresas sería "Inicio" del módulo
              onTap: (index) {
                switch (index) {
                  case 0:
                    // Ya estás en la pantalla principal del módulo (empresas)
                    break;
                  case 1:
                    // Navegar al historial de este módulo específico
                    Navigator.pushReplacementNamed(
                        context, '/historial_reservas');
                    break;
                  case 2:
                    // Navegar al perfil
                    Navigator.pushReplacementNamed(context, '/profile');
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, CompaniesController controller,
      String? status, IconData icon) {
    final isSelected = controller.selectedStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: AppDimensions.spacingSmall),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: FilterChip(
          avatar: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.updateStatusFilter(status);
            }
          },
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          elevation: isSelected ? 4 : 1,
          // ignore: deprecated_member_use
          shadowColor: AppColors.primary.withOpacity(0.3),
          side: BorderSide(
            // ignore: deprecated_member_use
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            width: isSelected ? 0 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
