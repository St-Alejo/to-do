class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String icon;
  final String userId;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.userId,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id:        map['id']         as String? ?? '',
      name:      map['name']       as String? ?? '',
      color:     map['color']      as String? ?? '#2DB77B',
      icon:      map['icon']       as String? ?? 'category',
      userId:    map['user_id']    as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':    name,
    'color':   color,
    'icon':    icon,
    'user_id': userId,
  };
}
