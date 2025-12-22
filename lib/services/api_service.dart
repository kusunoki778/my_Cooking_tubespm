import 'dart:io';
import 'package:dio/dio.dart';
import 'package:my_resep/models/recipe.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://693b70159b80ba7262cd4a45.mockapi.io/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const String _cloudName = "drmfgh6zr";
  static const String _uploadPreset = "drmfgh6zr";

  Future<String?> uploadImage(File file) async {
    try {
      final String url = "https://api.cloudinary.com/v1_1/$_cloudName/image/upload";
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': _uploadPreset,
      });

      final response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
    } catch (e) {
      print("Gagal upload gambar: $e");
    }
    return null;
  }

  Future<List<Recipe>> fetchRecipes() async {
    try {
      final response = await _dio.get('/myresep'); 
      final List data = response.data;
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal ambil data: $e');
    }
  }

  Future<Recipe> fetchRecipeDetail(String id) async {
    try {
      final response = await _dio.get('/myresep/$id');
      return Recipe.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal ambil detail: $e');
    }
  }

  Future<bool> createRecipe(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/myresep', data: data);
      return response.statusCode == 201; 
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/myresep/$id', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecipe(String id) async {
    try {
      final response = await _dio.delete('/myresep/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}