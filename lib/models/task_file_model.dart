class TaskFileModel {
  final String id;
  final String taskId;
  final String fileUrl;
  final String fileName;
  final DateTime createdAt;

  TaskFileModel({
    required this.id,
    required this.taskId,
    required this.fileUrl,
    required this.fileName,
    required this.createdAt,
  });

  factory TaskFileModel.fromMap(Map<String, dynamic> map) {
    return TaskFileModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      fileUrl: map['file_url'] as String,
      fileName: map['file_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
