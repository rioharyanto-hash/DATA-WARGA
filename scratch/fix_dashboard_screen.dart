import 'dart:io';

void main() async {
  final file = File('lib/src/features/dashboard/presentation/widgets/dashboard_screen.dart');
  String content = await file.readAsString();

  final index = content.lastIndexOf('}');
  
  if (index != -1) {
    final methods = """
  Widget _buildFilterDropdowns(WidgetRef ref) {
    final filterOptionsAsync = ref.watch(dashboardFilterOptionsProvider);
    final selectedRw = ref.watch(dashboardRwFilterProvider);
    final selectedRt = ref.watch(dashboardRtFilterProvider);
    final selectedKader = ref.watch(dashboardKaderFilterProvider);

    return filterOptionsAsync.when(
      data: (options) {
        return Row(
          children: [
            _buildDropdown(
              value: selectedRw,
              items: options['rw'] ?? [],
              hint: 'RW',
              onChanged: (val) => ref.read(dashboardRwFilterProvider.notifier).update(val),
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              value: selectedRt,
              items: options['rt'] ?? [],
              hint: 'RT',
              onChanged: (val) => ref.read(dashboardRtFilterProvider.notifier).update(val),
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              value: selectedKader,
              items: options['kader'] ?? [],
              hint: 'Kader',
              onChanged: (val) => ref.read(dashboardKaderFilterProvider.notifier).update(val),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    // Check if the current value exists in the options
    final effectiveValue = value != null && items.contains(value) ? value : null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: effectiveValue,
        hint: Text(hint, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        dropdownColor: _primaryDark,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        underline: const SizedBox(),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Semua', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
          ...items.map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
""";

    content = content.substring(0, index) + methods;
    await file.writeAsString(content);
    print('Methods added');
  }
}
