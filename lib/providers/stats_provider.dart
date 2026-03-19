import 'package:flutter/material.dart';
import '../data/task_remote_data_source.dart';
import '../models/task_model.dart';

class StatsProvider extends ChangeNotifier {
  final TaskRemoteDataSource _dataSource;
  List<TaskModel> _allTasks = [];
  bool _isLoading = false;

  StatsProvider(this._dataSource);

  bool get isLoading => _isLoading;

  int get completed => _allTasks.where((t) => t.isCompleted).length;
  int get pending => _allTasks.where((t) => !t.isCompleted && !_isOverdue(t)).length;
  int get overdue => _allTasks.where((t) => !t.isCompleted && _isOverdue(t)).length;

  bool _isOverdue(TaskModel t) {
    final today = DateTime.now();
    final taskDate = t.date;
    return taskDate.isBefore(DateTime(today.year, today.month, today.day));
  }

  // Category distribution: categoryName -> count
  Map<String, int> get categoryDistribution {
    final map = <String, int>{};
    for (final task in _allTasks) {
      if (task.isCompleted) {
        final name = task.category?.name ?? 'Sin categoría';
        map[name] = (map[name] ?? 0) + 1;
      }
    }
    return map;
  }

  // Daily progress for the week: returns list of [completed] per day (Mon-Sun)
  List<int> get weeklyDailyProgress {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return _allTasks.where((t) =>
          t.isCompleted &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day).length;
    });
  }

  // Category totals: categoryName -> total count
  Map<String, int> get categoryTotals {
    final map = <String, int>{};
    for (final task in _allTasks) {
      final name = task.category?.name ?? 'Sin categoría';
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final start = startOfWeek.toIso8601String().split('T')[0];
      final end = endOfWeek.toIso8601String().split('T')[0];
      final data = await _dataSource.getAllTasksInRange(start, end);
      _allTasks = data.map((m) => TaskModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
