import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config/router/go_router.dart';
import 'package:weather_app/config/theme/app_theme.dart';
import 'package:weather_app/presentation/providers/weather_bg_provider.dart';

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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: router,
    );
  }
}