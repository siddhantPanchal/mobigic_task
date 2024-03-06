import 'package:flutter/material.dart';
import 'package:mobigic_task/core/splash/splash_screen.dart';
import 'package:mobigic_task/game/presentation/screens/game_screen.dart';

class IRoutes {
  IRoutes._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget route = const Placeholder();

    switch (settings.name) {
      case "/":
        route = const SplashScreen();
        break;

      case "/game":
        route = const GameScreen();
        break;
    }

    return MaterialPageRoute(
      builder: (context) => route,
    );
  }
}
