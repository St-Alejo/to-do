import 'package:flutter/material.dart';
import '../data/category_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRemoteDataSource _dataSource;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this._dataSource);

  // Categorías hardcodeadas que se usan cuando la tabla no existe aún
  static final List<CategoryModel> _fallback = [
    CategoryModel(id: 'local-healthy',   name: 'Healthy',   color: '#4CAF50', icon: 'fitness_center', userId: '', createdAt: DateTime(2024)),
    CategoryModel(id: 'local-design',    name: 'Design',    color: '#FF9800', icon: 'palette',        userId: '', createdAt: DateTime(2024)),
    CategoryModel(id: 'local-job',       name: 'Job',       color: '#2196F3', icon: 'work',           userId: '', createdAt: DateTime(2024)),
    CategoryModel(id: 'local-education', name: 'Education', color: '#9C27B0', icon: 'school',         userId: '', createdAt: DateTime(2024)),
    CategoryModel(id: 'local-sport',     name: 'Sport',     color: '#F44336', icon: 'sports_soccer',  userId: '', createdAt: DateTime(2024)),
  ];

  List<CategoryModel> get categories =>
      _categories.isEmpty ? _fallback : _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _dataSource.getCategories();
      _categories = data.map((m) => CategoryModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading categories (usando fallback locales): $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
