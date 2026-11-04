import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/api_client.dart';
import 'providers/locale_provider.dart';
import 'screens/intro_screen.dart';
import 'screens/main_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();
  runApp(const ProviderScope(child: NumberEightApp()));
}

class NumberEightApp extends ConsumerWidget {
  const NumberEightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'NUMBER EIGHT Specialty Coffee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return const MainScreen();
    } else {
      return const IntroScreen();
    }
  }
}
