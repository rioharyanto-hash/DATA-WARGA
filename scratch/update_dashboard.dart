import 'dart:io';

void main() async {
  final file = File('lib/src/features/dashboard/presentation/widgets/dashboard_screen.dart');
  String content = await file.readAsString();

  // Find the start of the Demografi Grid
  final gridStartText = "                          // ── Demografi Grid ──";
  final chartStartText = "  Widget _buildUmurBarChart(";
  
  if (content.contains(gridStartText) && content.contains(chartStartText)) {
    final gridStartIndex = content.indexOf(gridStartText);
    
    // We want to replace from gridStartText up to the end of the `LayoutBuilder` which is followed by `.animate()`.
    // Actually, looking at the code, we can just replace everything from `// ── Demografi Grid ──` up to `const SizedBox(height: 28),` (which is at line 318).
    final gridEndIndex = content.indexOf("const SizedBox(height: 28),", gridStartIndex);
    
    final newGridCode = """                          // ── Demografi Grid ──
                          LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 2;
                              if (constraints.maxWidth >= 800) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth >= 600) {
                                crossAxisCount = 3;
                              }

                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 2.2,
                                children: [
                                  // Kelompok Umur
                                  _buildMiniStatCard('Balita (0-4 thn)', (summary.umurGrouping['Balita (0-4)'] ?? 0).toString(), Icons.child_care_rounded, const Color(0xFF10B981)),
                                  _buildMiniStatCard('Anak (5-9 thn)', (summary.umurGrouping['Anak (5-9)'] ?? 0).toString(), Icons.face_rounded, const Color(0xFF10B981)),
                                  _buildMiniStatCard('Remaja (10-24 thn)', (summary.umurGrouping['Remaja (10-24)'] ?? 0).toString(), Icons.directions_run_rounded, const Color(0xFF10B981)),
                                  _buildMiniStatCard('Dewasa (25-59 thn)', (summary.umurGrouping['Dewasa (25-59)'] ?? 0).toString(), Icons.person_rounded, const Color(0xFF10B981)),
                                  _buildMiniStatCard('Lansia (>=60 thn)', summary.jumlahLansia.toString(), Icons.elderly_rounded, const Color(0xFFF59E0B)),
                                  
                                  // Gender
                                  _buildMiniStatCard('Laki-laki', summary.jumlahLakiLaki.toString(), Icons.man_rounded, const Color(0xFF3B82F6)),
                                  _buildMiniStatCard('Perempuan', summary.jumlahPerempuan.toString(), Icons.woman_rounded, const Color(0xFFEC4899)),
                                  
                                  // WUS / PUS
                                  _buildMiniStatCard('WUS', summary.jumlahWus.toString(), Icons.female_rounded, const Color(0xFFEC4899)),
                                  _buildMiniStatCard('PUS', summary.jumlahPus.toString(), Icons.favorite_rounded, const Color(0xFF8B5CF6)),
                                  
                                  // Disabilitas
                                  _buildMiniStatCard('Disabilitas', summary.jumlahDisabilitas.toString(), Icons.accessible_rounded, const Color(0xFFEF4444)),
                                  
                                  // LAMPID
                                  _buildMiniStatCard('Lahir', summary.jumlahLahir.toString(), Icons.child_friendly_rounded, const Color(0xFF06B6D4)),
                                  _buildMiniStatCard('Meninggal', summary.jumlahMeninggal.toString(), Icons.sentiment_very_dissatisfied_rounded, const Color(0xFF64748B)),
                                  _buildMiniStatCard('Pindah', summary.jumlahPindah.toString(), Icons.flight_takeoff_rounded, const Color(0xFFF59E0B)),
                                  _buildMiniStatCard('Datang', summary.jumlahDatang.toString(), Icons.flight_land_rounded, const Color(0xFF10B981)),
                                ],
                              );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                          
                          """;

      content = content.replaceRange(gridStartIndex, gridEndIndex, newGridCode);
      
      // Now remove the chart function
      final newChartStartIndex = content.indexOf(chartStartText);
      if (newChartStartIndex != -1) {
         content = content.substring(0, newChartStartIndex) + "}\n";
      }
      
      await file.writeAsString(content);
      print("Success replacing layout and removing chart.");
  } else {
      print("Could not find grid or chart text");
  }
}
