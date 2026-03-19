import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRemoteDataSource {
  final SupabaseClient _client;
  CategoryRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select('*')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }
}
