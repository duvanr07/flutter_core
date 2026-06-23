import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_core/config/router/app_routes.dart';
import 'package:flutter_core/features/counter/screens/counter_page.dart';
import 'package:flutter_core/features/home/screens/environment_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const EnvironmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.counter,
        name: 'counter',
        builder: (context, state) => const CounterPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );
});
