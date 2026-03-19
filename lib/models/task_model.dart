import 'category_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String time;
  final String? categoryId;      // nullable: la BD no lo requiere
  final CategoryModel? category;
  final bool isCompleted;
  final DateTime? completedAt;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    this.categoryId,
    this.category,
    required this.isCompleted,
    this.completedAt,
    required this.userId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id:          map['id']         as String? ?? '',
      title:       map['title']      as String? ?? '',
      description: map['description'] as String?,
      date:        DateTime.parse((map['date'] as String? ?? DateTime.now().toIso8601String().split('T')[0])),
      time:        map['time']       as String? ?? '00:00:00',
      categoryId:  map['category_id'] as String?,
      category:    map['categories'] != null
          ? CategoryModel.fromMap(map['categories'] as Map<String, dynamic>)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      userId:    map['user_id']    as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':        title,
    'description':  description,
    'date':         date.toIso8601String().split('T')[0],
    'time':         time,
    'category_id':  categoryId,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIso8601String(),
    'user_id':      userId,
  };

  String get formattedTime {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'P.M' : 'A.M';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
