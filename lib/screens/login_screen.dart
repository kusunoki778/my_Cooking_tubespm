import 'package:flutter/material.dart';
import 'package:my_resep/services/auth_service.dart';
import 'package:my_resep/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullnameCtrl = TextEditingController(); 
  
  final _authService = AuthService();
  
  bool _isLoginMode = true; 
  bool _isLoading = false;
  bool _obscurePass = true;

  void _submit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final fullname = _fullnameCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua data!')));
      return;
    }

    setState(() => _isLoading = true);

    if (_isLoginMode) {
      // PROSES LOGIN
      bool success = await _authService.login(username, password);
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Gagal! Username/Password Salah.'), backgroundColor: Colors.red),
        );
      }
    } else {
      String hasil = await _authService.register(username, password, fullname);
      setState(() => _isLoading = false);

      if (hasil == "BERHASIL") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register Berhasil! Silakan Login.'), backgroundColor: Colors.teal),
        );
        setState(() {
          _isLoginMode = true;
          _usernameCtrl.clear();
          _passwordCtrl.clear();
          _fullnameCtrl.clear();
        });

      } else if (hasil == "KEMBAR") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah dipakai orang lain! Ganti nama unik.'), backgroundColor: Colors.orange),
        );

      } else {
        String errorMsg = hasil.replaceAll("Exception:", "").replaceAll("DioException", "");
        if (errorMsg.contains("404")) errorMsg = "Error 404: URL Salah / Endpoint User Tidak Ditemukan";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.shade100, 
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal,
                      ),
                      padding: const EdgeInsets.all(15), 
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.restaurant, size: 40, color: Colors.white);
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    _isLoginMode ? 'Selamat Datang' : 'Buat Akun Baru',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 30),

                  if (!_isLoginMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: _fullnameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLoginMode ? 'MASUK' : 'DAFTAR', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode; 
                        _usernameCtrl.clear();
                        _passwordCtrl.clear();
                        _fullnameCtrl.clear();
                      });
                    },
                    child: Text(
                      _isLoginMode 
                        ? 'Belum punya akun? Daftar sekarang' 
                        : 'Sudah punya akun? Masuk di sini',
                      style: const TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}