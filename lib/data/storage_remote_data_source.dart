import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRemoteDataSource {
  final SupabaseClient _client;
  StorageRemoteDataSource(this._client);

  Future<String> uploadFile(
      String userId, String taskId, String fileName, Uint8List bytes) async {
    final path = '$userId/$taskId/$fileName';
    await _client.storage
        .from('task-attachments')
        .uploadBinary(path, bytes);
    return _client.storage.from('task-attachments').getPublicUrl(path);
  }
}
