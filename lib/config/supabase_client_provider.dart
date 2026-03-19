import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  final SupabaseClient client;
  static late final SupabaseClientProvider instance;

  SupabaseClientProvider._(this.client);

  static void init({required String supabaseUrl, required String supabaseAnonKey}) {
    final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    instance = SupabaseClientProvider._(client);
  }
}
