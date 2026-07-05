import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainLayoutScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutScreen({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  // ── Design tokens ──────────────────────────────────────────────────
  static const _primaryDark = Color(0xFF4338CA); // Indigo 700
  static const _bgBody = Color(0xFFF8FAFC); // Slate 50
  static const _textMuted = Color(0xFF64748B); // Slate 500

  // Navigation items definition
  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Pendataan',
    ),
    _NavItem(
      icon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      label: 'Laporan',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Pengaturan',
    ),
  ];

  // ── Desktop sidebar ────────────────────────────────────────────────
  Widget _buildSidebar(int currentIndex) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1), // Slate 200
        ),
      ),
      child: Column(
        children: [
          // ── App branding ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ),
          const SizedBox(height: 24),

          // ── Navigation items ───────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final selected = i == currentIndex;
                return _SidebarNavTile(
                      icon: selected ? item.activeIcon : item.icon,
                      label: item.label,
                      selected: selected,
                      onTap: () => _goBranch(i),
                    )
                    .animate()
                    .fadeIn(delay: (100 * i).ms)
                    .slideX(begin: -0.1, end: 0);
              },
            ),
          ),

          // ── Version label ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              'Dasawisma App v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Web Wide Screen
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            backgroundColor: _bgBody,
            body: Row(
              children: [
                _buildSidebar(navigationShell.currentIndex),
                Expanded(
                  child: Container(
                    color: _bgBody,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: navigationShell,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Narrow Screen
        return Scaffold(
          backgroundColor: _bgBody,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: navigationShell,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              indicatorColor: const Color(0xFFEEF2FF), // Indigo 50
              height: 72,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: _textMuted),
                  selectedIcon: Icon(
                    Icons.dashboard_rounded,
                    color: _primaryDark,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined, color: _textMuted),
                  selectedIcon: Icon(
                    Icons.assignment_rounded,
                    color: _primaryDark,
                  ),
                  label: 'Pendataan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart_outline, color: _textMuted),
                  selectedIcon: Icon(Icons.pie_chart, color: _primaryDark),
                  label: 'Laporan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, color: _textMuted),
                  selectedIcon: Icon(
                    Icons.settings_rounded,
                    color: _primaryDark,
                  ),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Helper data class ──────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Sidebar navigation tile ────────────────────────────────────────────
class _SidebarNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _primaryLight = Color(0xFF6366F1); // Indigo 500
  static const _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? const Color(0xFFEEF2FF)
            : Colors.transparent, // Indigo 50
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: _primaryLight.withValues(alpha: 0.1),
          highlightColor: _primaryLight.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(
                      color: _primaryLight.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : Border.all(color: Colors.transparent, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? _primaryLight : _textMuted,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _primaryLight : _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
