import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/auth_storage.dart';
import 'design_system/design_system.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FitnessApp(),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
