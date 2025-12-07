import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart'; // TODO: User needs to generate this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Add firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Temporary workaround for building without config
  //try {
  //  await Firebase.initializeApp();
  // } catch (e) {
  // debugPrint("Firebase not initialized: $e");
  //}

  runApp(const ProviderScope(child: MyApp()));
}

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
