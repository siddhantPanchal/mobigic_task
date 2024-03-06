import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pushReplacementNamed("/game");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text(
          "Lets Play Word Finding",
          style: TextStyle(
            fontSize: 23 * 1.5,
          ),
        )
            .animate()
            .rotate(
              delay: 400.milliseconds,
              duration: 600.milliseconds,
              end: -1.05,
              curve: Curves.easeOutBack,
            )
            .scale(
              duration: 600.milliseconds,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
