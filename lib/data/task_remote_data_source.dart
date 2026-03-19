import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRemoteDataSource {
  final SupabaseClient _client;
  TaskRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getTasksByDate(String date) async {
    final response = await _client
        .from('tasks')
        .select('*, categories(*)')
        .eq('date', date)
        .order('time');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTasksInRange(
      String startDate, String endDate) async {
    final response = await _client
        .from('tasks')
        .select('*, categories(*)')
        .gte('date', startDate)
        .lte('date', endDate)
        .order('date')
        .order('time');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getCompletedTasks(
      String startDate, String endDate) async {
    final response = await _client
        .from('tasks')
        .select('*, categories(*)')
        .eq('is_completed', true)
        .gte('date', startDate)
        .lte('date', endDate)
        .order('completed_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllTasksInRange(
      String startDate, String endDate) async {
    final response = await _client
        .from('tasks')
        .select('*, categories(*)')
        .gte('date', startDate)
        .lte('date', endDate);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final response = await _client
        .from('tasks')
        .insert(data)
        .select('*, categories(*)')
        .single();
    return response;
  }

  Future<void> toggleComplete(String id, bool isCompleted) async {
    await _client.from('tasks').update({
      'is_completed': isCompleted,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
