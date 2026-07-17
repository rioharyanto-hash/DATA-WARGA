import 'dart:convert';
import 'dart:io';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1];
  }

  print('URL: $url');

  // Create a minimal Dart script that queries the Supabase API via HTTP
  final response = await HttpClient().getUrl(
    Uri.parse('$url/rest/v1/krt?limit=1'),
  );
  response.headers.add('apikey', key);
  response.headers.add('Authorization', 'Bearer $key');
  final request = await response.close();
  final responseBody = await request.transform(utf8.decoder).join();
  print(responseBody);
}
