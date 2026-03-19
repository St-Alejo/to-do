import 'package:flutter/material.dart';
import '../data/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRemoteDataSource _dataSource;
  List<TaskModel> _todayTasks = [];
  List<TaskModel> _monthTasks = [];
  List<TaskModel> _weekTasks = [];
  bool _isLoading = false;

  TaskProvider(this._dataSource);

  List<TaskModel> get todayTasks => _todayTasks;
  List<TaskModel> get monthTasks => _monthTasks;
  List<TaskModel> get weekTasks => _weekTasks;
  bool get isLoading => _isLoading;

  int get todayTotal => _todayTasks.length;
  int get todayCompleted => _todayTasks.where((t) => t.isCompleted).length;
  double get todayProgress => todayTotal > 0 ? todayCompleted / todayTotal : 0;

  int get weekTotal => _weekTasks.length;
  int get weekCompleted => _weekTasks.where((t) => t.isCompleted).length;
  int get weekPending => weekTotal - weekCompleted;
  double get weekProgress => weekTotal > 0 ? weekCompleted / weekTotal : 0;

  Future<void> loadTodayTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final data = await _dataSource.getTasksByDate(today);
      _todayTasks = data.map((m) => TaskModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading today tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeekTasks() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final start = startOfWeek.toIso8601String().split('T')[0];
      final end = endOfWeek.toIso8601String().split('T')[0];
      final data = await _dataSource.getAllTasksInRange(start, end);
      _weekTasks = data.map((m) => TaskModel.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading week tasks: $e');
    }
  }

  Future<void> loadMonthTasks(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final data = await _dataSource.getTasksInRange(startStr, endStr);
      _monthTasks = data.map((m) => TaskModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading month tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id, bool value) async {
    try {
      await _dataSource.toggleComplete(id, value);
      final idx = _todayTasks.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final task = _todayTasks[idx];
        _todayTasks[idx] = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          date: task.date,
          time: task.time,
          categoryId: task.categoryId,
          category: task.category,
          isCompleted: value,
          completedAt: value ? DateTime.now() : null,
          userId: task.userId,
          createdAt: task.createdAt,
        );
        notifyListeners();
      }
      final mIdx = _monthTasks.indexWhere((t) => t.id == id);
      if (mIdx != -1) {
        final task = _monthTasks[mIdx];
        _monthTasks[mIdx] = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          date: task.date,
          time: task.time,
          categoryId: task.categoryId,
          category: task.category,
          isCompleted: value,
          completedAt: value ? DateTime.now() : null,
          userId: task.userId,
          createdAt: task.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling complete: $e');
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    try {
      final data = await _dataSource.createTask(taskData);
      final task = TaskModel.fromMap(data);
      final today = DateTime.now().toIso8601String().split('T')[0];
      if (task.date.toIso8601String().split('T')[0] == today) {
        _todayTasks.add(task);
        _todayTasks.sort((a, b) => a.time.compareTo(b.time));
      }
      _monthTasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dataSource.deleteTask(id);
      _todayTasks.removeWhere((t) => t.id == id);
      _monthTasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  List<TaskModel> getTasksForDay(DateTime day) {
    return _monthTasks.where((t) =>
        t.date.year == day.year &&
        t.date.month == day.month &&
        t.date.day == day.day).toList();
  }
}
