import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smrs/src/core/router/router.dart';
import 'package:smrs/src/core/theme/app_theme.dart';
import 'package:smrs/src/core/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'SMRS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(themeState.valueOrNull?.seedColor ?? Colors.blue),
      darkTheme: AppTheme.dark(
        themeState.valueOrNull?.seedColor ?? Colors.blue,
      ),
      themeMode: themeState.valueOrNull?.themeMode ?? ThemeMode.system,
      routerConfig: router,
    );
  }
}
