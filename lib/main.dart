import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config/theme/app_theme.dart';
import 'package:weather_app/presentation/providers/weather_bg_provider.dart';
import 'package:weather_app/presentation/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherBgProvider(),
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      home: const Scaffold(
        body: Center(

          child: HomeScreen(),

        ),
      ),
    );
  }
}