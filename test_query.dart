import 'package:supabase/supabase.dart';
import 'dart:convert';

void main() async {
  final supabase = SupabaseClient(
    'https://sksraxlnkaulhfgxhfrg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrc3JheGxua2F1bGhmZ3hoZnJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwMzEzMzQsImV4cCI6MjA5OTYwNzMzNH0._tChsaU9LXGNNeqBES_AvwZyZhuT9YlRUz9DXtUuJxU',
  );

  final nik = '3175011201700002';
  try {
    final response = await supabase
        .from('individu')
        .select(
          'nama_lengkap, alamat_domisili, alamat_ktp, keluarga(krt(bangunan(alamat_lengkap, rt, rw)))',
        )
        .eq('nik', nik)
        .maybeSingle();

    print(jsonEncode(response));
  } catch (e) {
    print('Error: $e');
  }
}
