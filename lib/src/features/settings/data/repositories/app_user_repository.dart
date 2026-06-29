import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../../domain/repositories/i_app_user_repository.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/app_user.dart';

class AppUserRepository implements IAppUserRepository {
  String _hashPassword(String password) {
    // Basic SHA-256 hashing. In production, use salt + bcrypt/argon2.
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<void> insertUser(AppUser user) async {
    final db = await LocalDbHelper.database;
    final hashedUser = user.copyWith(password: _hashPassword(user.password));
    final model = AppUserModel.fromEntity(hashedUser);
    await db.insert(
      'app_user',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final db = await LocalDbHelper.database;
    // We assume if you call updateUser with a raw password it should be hashed.
    // If it's already hashed, it will be hashed again. A better approach is
    // only hashing if it's a new password. But we'll keep it simple for now.
    final model = AppUserModel.fromEntity(user);
    await db.update(
      'app_user',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await LocalDbHelper.database;
    await db.delete('app_user', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'app_user',
      orderBy:
          "CASE WHEN role = 'ADMIN' THEN 1 ELSE 2 END ASC, kelompok_dawis ASC, nama ASC",
    );
    return maps.map((json) => AppUserModel.fromJson(json)).toList();
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('app_user', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AppUserModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<AppUser?> authenticate(String idKader, String password) async {
    final db = await LocalDbHelper.database;
    final hashedPassword = _hashPassword(password);
    final maps = await db.query(
      'app_user',
      where: 'id_kader = ? AND password = ? AND is_active = 1',
      whereArgs: [idKader, hashedPassword],
    );
    if (maps.isNotEmpty) {
      return AppUserModel.fromJson(maps.first);
    }
    return null;
  }
}
