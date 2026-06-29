import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawis/src/features/settings/domain/entities/app_user.dart';
import 'package:dawis/src/features/settings/domain/repositories/i_app_user_repository.dart';
import 'package:dawis/src/features/settings/data/repositories/app_user_repository.dart';

final appUserRepositoryProvider = Provider<IAppUserRepository>(
  (ref) => AppUserRepository(),
);

final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final repository = ref.read(appUserRepositoryProvider);
  return repository.getAllUsers();
});

/// Holds the currently logged-in AppUser. Set after successful local auth.
class LoggedInUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser user) => state = user;
  void clearUser() => state = null;
}

final loggedInUserProvider = NotifierProvider<LoggedInUserNotifier, AppUser?>(
  LoggedInUserNotifier.new,
);
