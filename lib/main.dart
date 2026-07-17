import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/database/local_db_helper.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';
import 'src/features/settings/presentation/providers/app_user_provider.dart';
import 'core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inisialisasi dengan error handling agar tidak layar putih ---
  try {
    await dotenv.load(fileName: ".env");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null && supabaseAnonKey != null) {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('[INIT] Gagal memuat .env atau inisialisasi Supabase: $e');
  }

  try {
    await LocalDbHelper.database;
    // Jalankan sinkronisasi secara asynchronous (background) agar tidak memblokir UI
    SyncService.syncSupabaseToLocal();
  } catch (e) {
    debugPrint('[INIT] Gagal inisialisasi Local DB atau Sync: $e');
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
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
