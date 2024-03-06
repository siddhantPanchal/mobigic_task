import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobigic_task/core/routes/routes.dart';

void main() {
  Animate.restartOnHotReload = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobigic Task',
      theme: ThemeData(
        primaryColor: Colors.amber,
        useMaterial3: true,
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.amber,
        useMaterial3: true,
        brightness: Brightness.dark,
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      onGenerateRoute: IRoutes.onGenerateRoute,
    );
  }
}
