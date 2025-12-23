import 'package:dio/dio.dart';
import 'package:my_resep/utils/shared_prefs.dart';

class AuthService {
  final String _authority = '693b70159b80ba7262cd4a45.mockapi.io';
  final String _path = '/api/v1/users';

  final Dio _dio = Dio();

  Future<String> register(String username, String password, String fullname) async {
    try {
      final cleanUrl = Uri.https(_authority, _path);
  
      await _dio.postUri(cleanUrl, data: {
        'username': username, 
        'password': password,
        'fullname': fullname,
      });
      
      return "BERHASIL"; 
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return "ERROR 404: URL Salah.";
      }
      return "ERROR KONEKSI: $e";
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final cleanUrl = Uri.https(_authority, _path, {
        'username': username,
        'password': password
      });
      
      print("LOGIN CEK KE: $cleanUrl"); 

      final response = await _dio.getUri(cleanUrl);
      List users = response.data;
      
      if (users.isNotEmpty) {
        final user = users[0];

        if (user['username'] == username && user['password'] == password) {
             await Prefs.saveUserSession(
              user['id'].toString(), 
              user['username'],
              user['fullname'] ?? user['username'], 
              "", 
            );
            return true;
        }
      }
      return false; 
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await Prefs.clearSession();
  }
}