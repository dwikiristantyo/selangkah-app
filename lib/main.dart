import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  await SupabaseService.initialize();
  await NotificationService.initialize();
  runApp(const SelangkahApp());
}

class SelangkahApp extends StatelessWidget {
  const SelangkahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SELANGKAH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = SupabaseService.client.auth;
    return StreamBuilder(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const LoginPage() : const HomePage();
      },
    );
  }
}
