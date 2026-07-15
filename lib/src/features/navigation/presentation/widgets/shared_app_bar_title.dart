import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

class SharedAppBarTitle extends ConsumerWidget {
  final String title;
  final String subtitle;

  const SharedAppBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  String _getRoleLabel(dynamic user) {
    switch (user.role) {
      case 'KADER':
        return 'Kader ${user.kelompokDawis}';
      case 'RT':
        return 'Ketua RT ${user.rt}';
      case 'RW':
        return 'Ketua RW ${user.rw}';
      case 'ADMIN':
        return 'Administrator';
      default:
        return user.role;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      );
    }

    return Row(
      children: [
        // User Info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.nama,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getRoleLabel(user),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),

        // Vertical divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 32,
          width: 1,
          color: Colors.white.withAlpha(76), // 0.3 * 255 = 76
        ),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
