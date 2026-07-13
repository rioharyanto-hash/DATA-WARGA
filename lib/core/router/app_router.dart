import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/features/auth/presentation/widgets/login_screen.dart';
import '../../src/features/dashboard/presentation/widgets/dashboard_screen.dart';
import '../../src/features/pendataan/presentation/widgets/pendataan_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_bangunan_screen.dart';
import '../../src/features/pendataan/presentation/screens/detail_bangunan_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_krt_screen.dart';
import '../../src/features/pendataan/presentation/screens/detail_krt_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_keluarga_screen.dart';
import '../../src/features/pendataan/presentation/screens/detail_keluarga_screen.dart';
import '../../src/features/pendataan/presentation/screens/view_individu_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_individu_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_mutasi_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_mutasi_master_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_input_catatan_keluarga_screen.dart';
import '../../src/features/pendataan/presentation/screens/form_input_potensi_warga_screen.dart';
import '../../src/features/pendataan/presentation/screens/bangunan_list_screen.dart';
import '../../src/features/pendataan/presentation/screens/search_keluarga_screen.dart';
import '../../src/features/pendataan/presentation/screens/lampid_list_screen.dart';
import '../../src/features/navigation/presentation/widgets/main_layout_screen.dart';
import '../../src/features/report/presentation/screens/report_screen.dart';
import '../../src/features/data_warga/presentation/screens/data_warga_screen.dart';
import '../../src/features/settings/presentation/screens/settings_screen.dart';
import '../../src/features/settings/presentation/screens/user_list_screen.dart';
import '../../src/features/settings/presentation/screens/form_user_screen.dart';
import '../../src/features/settings/presentation/screens/profil_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _pendataanNavigatorKey = GlobalKey<NavigatorState>();
final _laporanNavigatorKey = GlobalKey<NavigatorState>();
final _dataWargaNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _pendataanNavigatorKey,
            routes: [
              GoRoute(
                path: '/pendataan',
                builder: (context, state) => const PendataanScreen(),
              ),
              GoRoute(
                path: '/bangunan-list',
                builder: (context, state) => const BangunanListScreen(),
              ),
              GoRoute(
                path: '/lampid-list',
                builder: (context, state) => const LampidListScreen(),
              ),
              GoRoute(
                path: '/search-keluarga',
                builder: (context, state) {
                  final mode = state.uri.queryParameters['mode'] ?? 'master';
                  return SearchKeluargaScreen(mode: mode);
                },
              ),
              // Form & Detail routes (rendered inside shell so sidebar stays visible)
              GoRoute(
                path: '/form-bangunan',
                builder: (context, state) => const FormBangunanScreen(),
              ),
              GoRoute(
                path: '/form-bangunan/:bangunanId',
                builder: (context, state) {
                  final bangunanId = state.pathParameters['bangunanId'];
                  return FormBangunanScreen(bangunanId: bangunanId);
                },
              ),
              GoRoute(
                path: '/detail-bangunan/:bangunanId',
                builder: (context, state) {
                  final bangunanId = state.pathParameters['bangunanId']!;
                  return DetailBangunanScreen(bangunanId: bangunanId);
                },
              ),
              GoRoute(
                path: '/form-krt/:bangunanId',
                builder: (context, state) {
                  final bangunanId = state.pathParameters['bangunanId']!;
                  return FormKrtScreen(bangunanId: bangunanId);
                },
              ),
              GoRoute(
                path: '/form-krt-edit/:krtId',
                builder: (context, state) {
                  final krtId = state.pathParameters['krtId']!;
                  return FormKrtScreen(krtId: krtId);
                },
              ),
              GoRoute(
                path: '/detail-krt/:krtId',
                builder: (context, state) {
                  final krtId = state.pathParameters['krtId']!;
                  return DetailKrtScreen(krtId: krtId);
                },
              ),
              GoRoute(
                path: '/form-keluarga/:krtId',
                builder: (context, state) {
                  final krtId = state.pathParameters['krtId']!;
                  return FormKeluargaScreen(krtId: krtId);
                },
              ),
              GoRoute(
                path: '/form-keluarga-edit/:keluargaId',
                builder: (context, state) {
                  final keluargaId = state.pathParameters['keluargaId']!;
                  return FormKeluargaScreen(keluargaId: keluargaId);
                },
              ),
              GoRoute(
                path: '/detail-keluarga/:keluargaId',
                builder: (context, state) {
                  final keluargaId = state.pathParameters['keluargaId']!;
                  final mode = state.uri.queryParameters['mode'] ?? 'master';
                  return DetailKeluargaScreen(
                    keluargaId: keluargaId,
                    mode: mode,
                  );
                },
              ),
              GoRoute(
                path: '/view-individu/:individuId',
                builder: (context, state) {
                  final individuId = state.pathParameters['individuId']!;
                  final isReadOnly = state.uri.queryParameters['isReadOnly'] == 'true';
                  return ViewIndividuScreen(individuId: individuId, isReadOnly: isReadOnly);
                },
              ),
              GoRoute(
                path: '/form-individu/:keluargaId',
                builder: (context, state) {
                  final keluargaId = state.pathParameters['keluargaId']!;
                  return FormIndividuScreen(keluargaId: keluargaId);
                },
              ),
              GoRoute(
                path: '/form-individu-edit/:keluargaId/:individuId',
                builder: (context, state) {
                  final keluargaId = state.pathParameters['keluargaId']!;
                  final individuId = state.pathParameters['individuId']!;
                  return FormIndividuScreen(
                    keluargaId: keluargaId,
                    individuId: individuId,
                  );
                },
              ),
              GoRoute(
                path: '/form-mutasi-master',
                name: 'form-mutasi-master',
                builder: (context, state) => const FormMutasiMasterScreen(),
              ),
              GoRoute(
                path: '/form-individu-lahir',
                name: 'form-individu-lahir',
                builder: (context, state) => const FormIndividuScreen(
                  keluargaId: '',
                  jenisMutasi: 'Lahir',
                ),
              ),
              GoRoute(
                path: '/form-keluarga-datang',
                name: 'form-keluarga-datang',
                builder: (context, state) =>
                    const FormKeluargaScreen(krtId: '', jenisMutasi: 'Datang'),
              ),
              GoRoute(
                path: '/form-individu-datang/:keluargaId',
                name: 'form-individu-datang',
                builder: (context, state) {
                  final keluargaId = state.pathParameters['keluargaId']!;
                  return FormIndividuScreen(
                    keluargaId: keluargaId,
                    jenisMutasi: 'Datang',
                  );
                },
              ),
              GoRoute(
                path: '/form-mutasi/:bangunanId',
                name: 'form-mutasi',
                builder: (context, state) {
                  final bangunanId = state.pathParameters['bangunanId']!;
                  final defaultJenisMutasi =
                      state.uri.queryParameters['defaultJenisMutasi'];
                  final idIndividuAsal =
                      state.uri.queryParameters['idIndividuAsal'];
                  final defaultNama = state.uri.queryParameters['defaultNama'];
                  final defaultNik = state.uri.queryParameters['defaultNik'];

                  return FormMutasiScreen(
                    bangunanId: bangunanId,
                    idIndividuAsal: idIndividuAsal,
                    defaultNama: defaultNama,
                    defaultNik: defaultNik,
                    defaultJenisMutasi: defaultJenisMutasi,
                  );
                },
              ),
              GoRoute(
                path: '/form-catatan-keluarga/:individuId',
                builder: (context, state) {
                  final individuId = state.pathParameters['individuId']!;
                  return FormInputCatatanKeluargaScreen(individuId: individuId);
                },
              ),
              GoRoute(
                path: '/form-potensi-warga/:individuId',
                builder: (context, state) {
                  final individuId = state.pathParameters['individuId']!;
                  return FormInputPotensiWargaScreen(individuId: individuId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _laporanNavigatorKey,
            routes: [
              GoRoute(
                path: '/laporan',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _dataWargaNavigatorKey,
            routes: [
              GoRoute(
                path: '/data-warga',
                builder: (context, state) => const DataWargaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/profil',
                builder: (context, state) => const ProfilScreen(),
              ),
              GoRoute(
                path: '/user-list',
                builder: (context, state) => const UserListScreen(),
              ),
              GoRoute(
                path: '/form-user',
                builder: (context, state) => const FormUserScreen(),
              ),
              GoRoute(
                path: '/form-user/:userId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return FormUserScreen(userId: userId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
