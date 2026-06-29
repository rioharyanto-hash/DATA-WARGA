import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return repository.authStateChanges;
});

class BypassAdminNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setBypass(bool val) => state = val;
}

final bypassAdminProvider = NotifierProvider<BypassAdminNotifier, bool>(
  BypassAdminNotifier.new,
);

final currentUserProvider = Provider<User?>((ref) {
  final isBypass = ref.watch(bypassAdminProvider);
  if (isBypass) {
    return User(
      id: 'admin',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
      email: 'admin@dawis.id',
    );
  }
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithEmailPassword(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});
