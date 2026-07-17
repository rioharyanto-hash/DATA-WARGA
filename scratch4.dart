import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  final supabase = Supabase.instance.client;
  final response = await supabase.from('krt').select().limit(1);
  if (response.isNotEmpty) {
    print(response.first.keys.toList());
  } else {
    print('No data');
  }
}
