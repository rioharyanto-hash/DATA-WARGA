import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  // Update header flexes for generateProfilUsiaRingkasanPortraitPdf
  for (int i = 9358; i < 9380; i++) {
    if (lines[i].contains("'UMUR',") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 2,', 'flex: 4,');
    }
    if (lines[i].contains("'P',") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 3,', 'flex: 2,');
    }
    if (lines[i].contains("'W',") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 3,', 'flex: 2,');
    }
  }

  // Update TOTAL footer flexes
  for (int i = 9406; i < 9425; i++) {
    if (lines[i].contains("'TOTAL',") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 2,', 'flex: 4,');
    }
    if (lines[i].contains("buildBreakdown(perKelompokData, 'total_P'),") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 3,', 'flex: 2,');
    }
    if (lines[i].contains("buildBreakdown(perKelompokData, 'total_W'),") && lines[i+1].contains("flex:")) {
      lines[i+1] = lines[i+1].replaceAll('flex: 3,', 'flex: 2,');
    }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Patched profil lebar!');
}
