import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GoGreenApp());
}

class GoGreenApp extends StatelessWidget {
  const GoGreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoGreen Fleet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
