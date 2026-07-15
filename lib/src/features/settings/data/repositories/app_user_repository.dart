import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/i_app_user_repository.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/app_user.dart';

class AppUserRepository implements IAppUserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _hashPassword(String password) {
    // Basic SHA-256 hashing. In production, use salt + bcrypt/argon2.
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<void> insertUser(AppUser user) async {
    final hashedUser = user.copyWith(password: _hashPassword(user.password));
    final model = AppUserModel.fromEntity(hashedUser);

    await _supabase.from('app_user').upsert(model.toJson());
  }

  @override
  Future<void> updateUser(AppUser user) async {
    // Check if the password is already a 64-character hex string (SHA-256 hash)
    final isAlreadyHashed = RegExp(
      r'^[a-fA-F0-9]{64}$',
    ).hasMatch(user.password);

    final updatedUser = isAlreadyHashed
        ? user
        : user.copyWith(password: _hashPassword(user.password));

    final model = AppUserModel.fromEntity(updatedUser);

    await _supabase.from('app_user').update(model.toJson()).eq('id', user.id);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _supabase.from('app_user').delete().eq('id', id);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    // Ordering logic mapping from SQL:
    // ORDER BY CASE WHEN role = 'ADMIN' THEN 1 ELSE 2 END ASC, kelompok_dawis ASC, nama ASC
    // In Supabase we can fetch all and sort in memory, or use a Postgres view.
    // Given the small size of app_user, fetching and sorting in Dart is easy.
    final response = await _supabase.from('app_user').select();

    final users = response.map((json) => AppUserModel.fromJson(json)).toList();

    // Sort in memory
    users.sort((a, b) {
      final aRoleWeight = a.role == 'ADMIN' ? 1 : 2;
      final bRoleWeight = b.role == 'ADMIN' ? 1 : 2;

      if (aRoleWeight != bRoleWeight) {
        return aRoleWeight.compareTo(bRoleWeight);
      }

      final aKelompok = a.kelompokDawis ?? '';
      final bKelompok = b.kelompokDawis ?? '';
      final kelompokCompare = aKelompok.compareTo(bKelompok);
      if (kelompokCompare != 0) {
        return kelompokCompare;
      }

      return a.nama.compareTo(b.nama);
    });

    return users;
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final response = await _supabase
        .from('app_user')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      return AppUserModel.fromJson(response);
    }
    return null;
  }

  @override
  Future<AppUser?> authenticate(String idKader, String password) async {
    final hashedPassword = _hashPassword(password);

    final response = await _supabase
        .from('app_user')
        .select()
        .eq('id_kader', idKader)
        .eq('password', hashedPassword)
        .eq('is_active', 1)
        .maybeSingle();

    if (response != null) {
      return AppUserModel.fromJson(response);
    }
    return null;
  }
}
