import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PendataanScreen extends ConsumerWidget {
  const PendataanScreen({super.key});

  // ── Design tokens ──────────────────────────────────────────────────
  static const _bgColor = Color(0xFFF8FAFC); // Slate 50
  static const _charcoal = Color(0xFF0F172A); // Slate 900
  static const _subtitle = Color(0xFF64748B); // Slate 500
  static const _cardRadius = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendataan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Pilih formulir input yang ingin Anda isi',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _buildGrid(context),
    );
  }

  // ── Grid Menu ────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: isDesktop ? 2 : 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: isDesktop ? 2.2 : 2.5,
          children: [
            _buildMenuCard(
              context,
              title: 'Data Bangunan',
              subtitle: 'Input Bangunan, KRT, KK & Warga',
              icon: Icons.account_balance_rounded,
              color: const Color(0xFF3B82F6), // Blue
              onTap: () => context.push('/bangunan-list'),
              delay: 100,
            ),

            _buildMenuCard(
              context,
              title: 'Mutasi Ibu Hamil & Warga',
              subtitle: 'Kehamilan, kelahiran, mutasi datang/pindah',
              icon: Icons.pregnant_woman_rounded,
              color: const Color(0xFFEC4899), // Pink
              onTap: () {
                context.push('/form-mutasi-master');
              },
              delay: 400,
            ),
            _buildMenuCard(
              context,
              title: 'Data LAMPID',
              subtitle: 'Riwayat data warga meninggal, pindah, datang, lahir',
              icon: Icons.history_edu_rounded,
              color: const Color(0xFFF59E0B), // Amber
              onTap: () {
                context.push('/lampid-list');
              },
              delay: 700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _subtitle,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0);
  }
}
