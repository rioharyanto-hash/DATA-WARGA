import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(r"\${r[", r"${r[");
  
  // Also for the totals like \$tKrt
  content = content.replaceAll(r"\$tKrt", r"$tKrt");
  content = content.replaceAll(r"\$tKk", r"$tKk");
  content = content.replaceAll(r"\$tL", r"$tL");
  content = content.replaceAll(r"\$tP", r"$tP");
  content = content.replaceAll(r"\$tJumlah", r"$tJumlah");
  content = content.replaceAll(r"\$tBalita", r"$tBalita");
  content = content.replaceAll(r"\$tAnak", r"$tAnak");
  content = content.replaceAll(r"\$tRemaja", r"$tRemaja");
  content = content.replaceAll(r"\$tDewasa", r"$tDewasa");
  content = content.replaceAll(r"\$tLansia", r"$tLansia");
  content = content.replaceAll(r"\$tJumlahKeluarga", r"$tJumlahKeluarga");
  content = content.replaceAll(r"\$tPus", r"$tPus");
  content = content.replaceAll(r"\$tMow", r"$tMow");
  content = content.replaceAll(r"\$tMop", r"$tMop");
  content = content.replaceAll(r"\$tIud", r"$tIud");
  content = content.replaceAll(r"\$tImplant", r"$tImplant");
  content = content.replaceAll(r"\$tSuntik", r"$tSuntik");
  content = content.replaceAll(r"\$tPil", r"$tPil");
  content = content.replaceAll(r"\$tKondom", r"$tKondom");
  content = content.replaceAll(r"\$tJumlahKb", r"$tJumlahKb");
  content = content.replaceAll(r"\$tTial", r"$tTial");
  content = content.replaceAll(r"\$tIat", r"$tIat");
  content = content.replaceAll(r"\$tIas", r"$tIas");
  content = content.replaceAll(r"\$tHamil", r"$tHamil");
  content = content.replaceAll(r"\$tJumlahBukanKb", r"$tJumlahBukanKb");
  
  // Same for rekap
  content = content.replaceAll(r"\${r", r"${r");
  content = content.replaceAll(r"\$t", r"$t");
  content = content.replaceAll(r"\$j", r"$j");
  content = content.replaceAll(r"\$b", r"$b");
  content = content.replaceAll(r"\$r", r"$r");
  content = content.replaceAll(r"\$p", r"$p");
  content = content.replaceAll(r"\$l", r"$l");
  content = content.replaceAll(r"\$w", r"$w");
  content = content.replaceAll(r"\$i", r"$i");
  content = content.replaceAll(r"\$s", r"$s");
  content = content.replaceAll(r"\$d", r"$d");
  content = content.replaceAll(r"\$k", r"$k");
  content = content.replaceAll(r"\$u", r"$u");
  content = content.replaceAll(r"\$m", r"$m");

  file.writeAsStringSync(content);
  print('Unescaped variables!');
}
