import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login(String idKader, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (idKader.trim().isEmpty || password.isEmpty) {
        throw Exception('ID Kader dan password tidak boleh kosong');
      }
      final repo = ref.read(appUserRepositoryProvider);
      final user = await repo.authenticate(idKader.trim(), password);

      if (user != null) {
        ref.read(loggedInUserProvider.notifier).setUser(user);
      } else {
        throw Exception('Login Gagal. Pastikan ID Kader dan Password benar.');
      }
    });
  }
}

final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);
