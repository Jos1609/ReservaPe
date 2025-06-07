import 'package:flutter/material.dart';
import 'package:sintetico/views/home_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /*case '/client':
        return MaterialPageRoute(builder: (_) => ClientScreen());
      case '/company':
        return MaterialPageRoute(builder: (_) => CompanyScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => AdminScreen()); */
      default:
        return MaterialPageRoute(builder: (_) => HomeView());
    }
  }
}