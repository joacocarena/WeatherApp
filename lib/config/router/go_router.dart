import 'package:go_router/go_router.dart';
import 'package:weather_app/presentation/screens/home_screen.dart';
import 'package:weather_app/presentation/screens/map_and_extras_screen.dart';

final router = GoRouter(
  routes: [
    
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/mapScren',
      builder: (context, state) => const MapAndExtrasScreen(),
    ),

  ]
);