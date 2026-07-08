import 'dart:io';

void main() async {
  final file = File('lib/src/features/dashboard/presentation/widgets/dashboard_screen.dart');
  String content = await file.readAsString();

  final chartStartText = "  Widget _buildUmurBarChart(";
  
  if (content.contains(chartStartText)) {
      final newChartStartIndex = content.indexOf(chartStartText);
      content = content.substring(0, newChartStartIndex) + "}\n";
      await file.writeAsString(content);
      print("Success removing chart.");
  } else {
      print("Could not find chart text");
  }
}
