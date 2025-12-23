import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:provider/provider.dart';
import 'package:my_resep/models/recipe.dart';
import 'package:my_resep/providers/recipe_provider.dart';
import 'package:my_resep/services/api_service.dart';
import 'package:my_resep/utils/shared_prefs.dart';

class FormScreen extends StatefulWidget {
  final Recipe? recipe;
  const FormScreen({super.key, this.recipe});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _areaCtrl = TextEditingController(); 
  final _thumbnailCtrl = TextEditingController();
  final _cookTimeCtrl = TextEditingController(); 
  final _servingsCtrl = TextEditingController();

  String _selectedDifficulty = 'Mudah';
  String _selectedCategory = 'Makanan Utama'; 
  
  File? _selectedImageFile;

  final List<String> _categories = [
    'Makanan Utama', 'Sarapan', 'Cemilan', 'Minuman', 'Dessert', 'Lainnya',
  ];

  List<Map<String, String>> _ingredients = [];
  List<String> _steps = [];

  bool _isLoading = false;
  String _loadingMessage = 'Menyimpan...';

  @override
  void initState() {
    super.initState();
    _thumbnailCtrl.addListener(() => setState(() {}));

    if (widget.recipe != null) {
      final r = widget.recipe!;
      _titleCtrl.text = r.title;
      _areaCtrl.text = r.area;
      _thumbnailCtrl.text = r.thumbnail;
      _cookTimeCtrl.text = r.cookTime;
      _servingsCtrl.text = r.servings.toString();
      
      if (['Mudah', 'Sedang', 'Sulit'].contains(r.difficulty)) _selectedDifficulty = r.difficulty;
      _selectedCategory = _categories.contains(r.category) ? r.category : 'Lainnya';

      _ingredients = List<Map<String, String>>.from(r.ingredients.map((i) => {
        'name': i['name'].toString(),
        'quantity': i['quantity']?.toString() ?? '',
      }));

      _steps = r.instructions.isNotEmpty ? r.instructions.split('\n') : [''];

    } else {
      _ingredients.add({'name': '', 'quantity': ''});
      _steps.add(''); 
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _areaCtrl.dispose();
    _thumbnailCtrl.dispose(); 
    _cookTimeCtrl.dispose();
    _servingsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 50); 
    
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
        _thumbnailCtrl.clear(); 
      });
    }
  }

  void _addIngredient() => setState(() => _ingredients.add({'name': '', 'quantity': ''}));
  void _removeIngredient(int index) => setState(() => _ingredients.removeAt(index));

  void _addStep() => setState(() => _steps.add(''));
  void _removeStep(int index) => setState(() => _steps.removeAt(index));

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final validIngredients = _ingredients.where((i) => i['name']!.isNotEmpty).toList();
    final validSteps = _steps.where((s) => s.trim().isNotEmpty).toList();

    if (validIngredients.isEmpty || validSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal 1 bahan & 1 langkah!')));
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Mengupload Gambar...';
    });

    String finalThumbnailUrl = _thumbnailCtrl.text;

    if (_selectedImageFile != null) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final cloudUrl = await apiService.uploadImage(_selectedImageFile!);
      
      if (cloudUrl != null) {
        finalThumbnailUrl = cloudUrl; 
      } else {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal upload gambar. Cek internet!')));
        return; 
      }
    }

    setState(() => _loadingMessage = 'Menyimpan Resep...');

    final session = await Prefs.getUserSession();
    String currentUser = session['fullname']!.isNotEmpty 
        ? session['fullname']! 
        : (session['username']!.isNotEmpty ? session['username']! : 'Chef myCooking');

    final data = {
      'title': _titleCtrl.text,
      'category': _selectedCategory,
      'area': _areaCtrl.text,
      'instructions': validSteps.join('\n'), 
      'thumbnail': finalThumbnailUrl, 
      'difficulty': _selectedDifficulty,
      'cookTime': _cookTimeCtrl.text, 
      'servings': int.tryParse(_servingsCtrl.text) ?? 1,
      'ingredients': validIngredients,
      'author': currentUser, 
    };

    final prov = Provider.of<RecipeProvider>(context, listen: false);
    bool success;

    if (widget.recipe != null) {
      success = await prov.updateRecipe(widget.recipe!.id, data);
    } else {
      success = await prov.createRecipe(data);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.errorMessage)));
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  InputDecoration _inputDecor(String label, {String? hint, IconData? icon}) {
    final fillColor = _isDark ? Colors.grey[800] : Colors.grey.shade50;
    final borderColor = _isDark ? Colors.grey[600]! : Colors.grey.shade300;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? const Color(0xFF0A0A0B) : Colors.white;
    final textColor = _isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Edit Resep' : 'Resep Baru', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2)) 
              : const Icon(Icons.check, color: Colors.teal, size: 28),
            onPressed: _isLoading ? null : _saveForm,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Informasi Dasar", Icons.info_outline),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecor('Nama Resep', hint: 'Misal: Nasi Goreng Spesial'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true, 
                      value: _selectedCategory,
                      decoration: _inputDecor('Kategori'),
                      dropdownColor: _isDark ? Colors.grey[800] : Colors.white, 
                      items: _categories.map((c) => DropdownMenuItem(
                        value: c, 
                        child: Text(c, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14))
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 12), 
                  Expanded(
                    child: TextFormField(
                      controller: _areaCtrl,
                      decoration: _inputDecor('Asal Daerah', hint: 'Jawa'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _cookTimeCtrl, decoration: _inputDecor('Waktu', hint: '15 menit', icon: Icons.timer_outlined))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _servingsCtrl, keyboardType: TextInputType.number, decoration: _inputDecor('Porsi', hint: '2', icon: Icons.people_outline))),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: _inputDecor('Tingkat Kesulitan', icon: Icons.bar_chart),
                dropdownColor: _isDark ? Colors.grey[800] : Colors.white,
                items: ['Mudah', 'Sedang', 'Sulit'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) => setState(() => _selectedDifficulty = val!),
              ),

              const Divider(height: 40, thickness: 1),

              _sectionHeader("Foto Makanan", Icons.camera_alt_outlined),
              
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isDark ? Colors.grey[900] : Colors.grey[100], 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isDark ? Colors.grey[700]! : Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _selectedImageFile != null
                      ? Image.file(_selectedImageFile!, fit: BoxFit.cover) 
                      : _thumbnailCtrl.text.isNotEmpty
                          ? Image.network(
                              _thumbnailCtrl.text, 
                              fit: BoxFit.cover, 
                              errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                            ) 
                          : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey), Text('Belum ada gambar', style: TextStyle(color: Colors.grey))])),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ExpansionTile(
                title: const Text('Atau input URL manual', style: TextStyle(fontSize: 14)),
                children: [
                  TextFormField(
                    controller: _thumbnailCtrl,
                    decoration: _inputDecor('URL Gambar', hint: 'https://...', icon: Icons.link),
                    onChanged: (val) {
                      if (val.isNotEmpty) setState(() => _selectedImageFile = null);
                    },
                  ),
                ],
              ),

              const Divider(height: 40, thickness: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Bahan-bahan", Icons.shopping_basket_outlined),
                  TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add_circle, color: Colors.teal), label: const Text('Tambah', style: TextStyle(color: Colors.teal))),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: TextFormField(initialValue: _ingredients[i]['name'], decoration: _inputDecor('Bahan', hint: 'Telor'), onChanged: (val) => _ingredients[i]['name'] = val)),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: TextFormField(initialValue: _ingredients[i]['quantity'], decoration: _inputDecor('Jml', hint: '2 btr'), onChanged: (val) => _ingredients[i]['quantity'] = val)),
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeIngredient(i)),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 40, thickness: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Cara Memasak", Icons.format_list_numbered),
                  TextButton.icon(onPressed: _addStep, icon: const Icon(Icons.add_circle, color: Colors.teal), label: const Text('Tambah', style: TextStyle(color: Colors.teal))),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, right: 8),
                          child: CircleAvatar(radius: 12, backgroundColor: Colors.teal.shade100, child: Text('${i+1}', style: TextStyle(color: Colors.teal.shade800, fontSize: 12, fontWeight: FontWeight.bold))),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: _steps[i],
                            maxLines: null,
                            decoration: _inputDecor('Langkah ${i+1}', hint: 'Jelaskan detailnya...'),
                            onChanged: (val) => _steps[i] = val,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeStep(i)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity, 
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_rounded),
                  label: Text(_isLoading ? _loadingMessage : 'SIMPAN RESEP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}