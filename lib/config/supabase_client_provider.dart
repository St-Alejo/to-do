import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  final SupabaseClient client;
  static late final SupabaseClientProvider instance;

  SupabaseClientProvider._(this.client);

  static void init({required String supabaseUrl, required String supabaseAnonKey}) {
    // Usa el cliente del singleton de Supabase para compartir la misma sesión
    instance = SupabaseClientProvider._(Supabase.instance.client);
  }
}
