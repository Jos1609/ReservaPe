// lib/views/company_detail_view.dart

import 'package:flutter/material.dart';
import 'package:sintetico/components/barra_navegacion.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/config/ui/carga_widget.dart';
import 'package:sintetico/config/ui/error_carga.dart';
import 'package:sintetico/features/detalle_empresa/components/header_section.dart';
import 'package:sintetico/features/detalle_empresa/components/info_section.dart';
import 'package:sintetico/features/detalle_empresa/components/lista_canchas.dart';
import 'package:sintetico/features/detalle_empresa/services/detalle_empresa_service.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';

class CompanyDetailView extends StatefulWidget {
  final CompanyModel company;

  const CompanyDetailView({
    super.key,
    required this.company,
  });

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  final CourtService _courtService = CourtService();
  late Future<List<CourtModel>> _courtsFuture;

  @override
  void initState() {
    super.initState();
    _courtsFuture = _courtService.getCourtsByCompanyId(widget.company.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0, 
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/cliente_dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/historial_reservas');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
        ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar personalizado
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.company.name,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                background: CompanyHeaderSection(company: widget.company),
              ),
            ),

            // Información de la empresa
            SliverToBoxAdapter(
              child: CompanyInfoSection(company: widget.company),
            ),

            // Título de la sección de canchas
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLarge),
                child: Text(
                  'Canchas Disponibles',
                  style: AppTextStyles.h2,
                ),
              ),
            ),

            // Lista de canchas
            SliverToBoxAdapter(
              child: FutureBuilder<List<CourtModel>>(
                future: _courtsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingXLarge),
                        child: LoadingWidget(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingXLarge),
                        child: CustomErrorWidget(
                          message: 'Error al cargar las canchas',
                          onRetry: () {
                            setState(() {
                              _courtsFuture = _courtService
                                  .getCourtsByCompanyId(widget.company.id);
                            });
                          },
                        ),
                      ),
                    );
                  }

                  final courts = snapshot.data ?? [];

                  if (courts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingXLarge),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              'No hay canchas disponibles',
                              style: AppTextStyles.bodycard.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return CourtListSection(
                    courts: courts,
                    companyName: widget.company.name,
                  );
                },
              ),
            ),

            // Espacio adicional al final
            SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingXLarge),
            ),
          ],
        ),
      ),
    );
  }
}