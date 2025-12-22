import 'package:flutter/material.dart';
import 'package:my_resep/utils/shared_prefs.dart'; 
import 'package:my_resep/models/recipe.dart';
import 'package:my_resep/services/api_service.dart'; 

enum Status { initial, loading, success, error }

class RecipeProvider extends ChangeNotifier {
  final ApiService api; 

  RecipeProvider({required this.api});

  List<Recipe> _recipes = [];
  Status _listStatus = Status.initial;
  String _errorMessage = '';
  
  Recipe? _selectedRecipe;
  Status _detailStatus = Status.initial;
  List<String> _favoriteIds = [];

  List<Recipe> get recipes => _recipes;
  Status get listStatus => _listStatus;
  String get errorMessage => _errorMessage;
  Recipe? get selectedRecipe => _selectedRecipe;
  Status get detailStatus => _detailStatus;
  
  Future<void> loadRecipes() async {
    _listStatus = Status.loading;
    notifyListeners();
    try {
      _recipes = await api.fetchRecipes(); 
      _listStatus = Status.success;
      await _loadFavoritesFromPrefs(); 
    } catch (e) {
      _listStatus = Status.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadDetail(String id) async {
    _detailStatus = Status.loading;
    _selectedRecipe = null;
    notifyListeners();
    try {
      final index = _recipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _selectedRecipe = _recipes[index];
      } else {
        _selectedRecipe = await api.fetchRecipeDetail(id);
      }
      _detailStatus = Status.success;
    } catch (e) {
      _detailStatus = Status.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createRecipe(Map<String, dynamic> data) async {
    try {
      final success = await api.createRecipe(data);
      if (success) {
        await loadRecipes(); 
      } else {
        _errorMessage = 'Gagal upload data';
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    try {
      final success = await api.updateRecipe(id, data);
      
      if (success) {
        final freshRecipe = await api.fetchRecipeDetail(id);
        _selectedRecipe = freshRecipe;

        final index = _recipes.indexWhere((r) => r.id == id);
        if (index != -1) {
          _recipes[index] = freshRecipe;
        }
        notifyListeners(); 
      } else {
        _errorMessage = 'Gagal update data';
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteRecipe(String id) async {
    try {
      final success = await api.deleteRecipe(id);
      if (success) {
        _recipes.removeWhere((r) => r.id == id);
        notifyListeners();
      } else {
        _errorMessage = 'Gagal hapus data';
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    
    await Prefs.setFavorites(_favoriteIds);
  }

  Future<void> _loadFavoritesFromPrefs() async {
    _favoriteIds = await Prefs.getFavorites();
    notifyListeners();
  }
}