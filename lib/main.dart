import 'package:fasto_qr/core/constants/app_theme.dart';
import 'package:fasto_qr/features/qr/presentation/screens/main_screen.dart';
import 'package:fasto_qr/shared/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppBackground(child: MainScreen()),
    );
  }
}
