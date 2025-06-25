import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sintetico/config/theme/app_theme.dart';
import 'package:sintetico/features/home_empresas/services/home_service.dart';
import 'package:sintetico/firebase_options.dart';
import 'package:sintetico/views/cliente/home_cliente.dart';
import 'package:sintetico/views/empresa/home_view_empresa.dart';
import 'package:sintetico/views/home_view.dart';
import 'package:sintetico/views/superAdm/home.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await HomeEmpresaService.initialize();
  await initializeDateFormatting('es', null); // Inicializa español
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva pe',
      theme: AppTheme.theme,
    initialRoute: '/sintetico',
      routes: {   
        '/sintetico': (context) => HomeView(),     
        '/admin_dashboard': (context) => CompaniesScreen(),
        '/empresa_dashboard': (context) => HomeViewEmpresa(),
        '/cliente_dashboard': (context) => CompaniesPage(),
      },
    );
  }
}