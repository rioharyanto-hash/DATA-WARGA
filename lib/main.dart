import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/database/local_db_helper.dart';
import 'core/router/app_router.dart';
import 'src/features/settings/presentation/providers/app_user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inisialisasi dengan error handling agar tidak layar putih ---
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('[INIT] Gagal memuat .env: $e');
  }

  try {
    await LocalDbHelper.database;
  } catch (e) {
    debugPrint('[INIT] Gagal inisialisasi Local DB: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    // Auth redirect logic using local loggedInUserProvider
    ref.listen(loggedInUserProvider, (previous, next) {
      final user = next;
      final currentRoute = goRouter.routerDelegate.currentConfiguration.uri
          .toString();

      if (user != null && currentRoute == '/login') {
        goRouter.go('/dashboard');
      } else if (user == null && currentRoute != '/login') {
        goRouter.go('/login');
      }
    });

    return MaterialApp.router(
      title: 'Dasawisma App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Electric Indigo
              brightness: Brightness.light,
            ).copyWith(
              surface: const Color(0xFFF8FAFC), // Slate 50
            ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: goRouter,
    );
  }
}
