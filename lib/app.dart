import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_core/config/router/app_router.dart';
import 'package:flutter_core/config/theme/app_theme.dart';
import 'package:flutter_core/config/environments/environment.constant.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: Environment.nameApp,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
