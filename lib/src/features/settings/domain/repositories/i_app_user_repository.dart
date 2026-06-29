import '../entities/app_user.dart';

abstract class IAppUserRepository {
  Future<void> insertUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<void> deleteUser(String id);
  Future<List<AppUser>> getAllUsers();
  Future<AppUser?> getUserById(String id);
  Future<AppUser?> authenticate(String idKader, String password);
}
