import 'dart:io';

void fixFile(String path) {
  var file = File(path);
  var content = file.readAsStringSync();
  
  String replaceWithRegex(String search, String replacement) {
    String pattern = search.replaceAll('\n', r'\r?\n');
    return content.replaceAll(RegExp(pattern), replacement);
  }

  // Data Potensi Warga (TERISI) - Perincian & Report
  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 12,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),''',
'''          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 18,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),''',
'''          pw.Expanded(
            flex: 90,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 12,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),''',
'''          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 24,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),''',
'''          pw.Expanded(
            flex: 120,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),'''
  );

  // Blank Form
  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 10,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),''',
'''          pw.Expanded(
            flex: 50,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 12,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),''',
'''          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 8,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),''',
'''          pw.Expanded(
            flex: 40,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),'''
  );

  content = replaceWithRegex(
'''          pw.Expanded(
            flex: 17,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),''',
'''          pw.Expanded(
            flex: 85,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),'''
  );

  // Rekapitulasi Data Potensi Warga in pdf_report_service.dart
  // Wait, let's see if there is another table with flex bugs.
  // There is another one: "DATA REKAPITULASI KELOMPOK PKK RW" or something.
  // I will just fix the ones I found for now.
  file.writeAsStringSync(content);
}

void main() {
  fixFile('lib/src/features/report/data/services/pdf_perincian_service.dart');
  fixFile('lib/src/features/report/data/services/pdf_report_service.dart');
  print('Done!');
}
