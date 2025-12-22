import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:my_resep/providers/recipe_provider.dart';
import 'package:my_resep/widgets/recipe_card.dart';
import 'package:my_resep/screens/detail_screen.dart';
import 'package:my_resep/screens/form_screen.dart';
import 'package:my_resep/utils/shared_prefs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; 
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  String get _greeting {
    var hour = DateTime.now().hour;
    if (hour < 4) return 'Lapar Tengah Malam? Semangat Chef!';
    if (hour < 11) return 'Selamat Pagi, Chef!';
    if (hour < 15) return 'Selamat Siang, Chef!';
    if (hour < 18) return 'Selamat Sore, Chef!';
    return 'Selamat Malam, Chef!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavTab = _selectedIndex == 1;

    final headerColor = isDark ? Theme.of(context).cardColor : Colors.teal;
    final headerTextColor = isDark ? Colors.tealAccent : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? null : Colors.grey[100], 
      
      appBar: AppBar(
        title: Text(
          isFavTab ? 'Favorit Saya' : 'myCooking',
          style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: headerColor, 
        iconTheme: IconThemeData(color: headerTextColor), 
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              tooltip: 'Pengaturan',
              splashRadius: 22,
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool?>(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resep berhasil dibuat!'), backgroundColor: Colors.teal)
            );
          }
        },
        backgroundColor: Colors.teal, 
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, 
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() { _selectedIndex = 0; _searchController.clear(); _query = ''; }),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                        color: _selectedIndex == 0 ? Colors.teal : Colors.grey,
                        size: 28,
                      ),
                      Text("Home", style: TextStyle(fontSize: 10, color: _selectedIndex == 0 ? Colors.teal : Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40), 
              Expanded(
                child: InkWell(
                  onTap: () => setState(() { _selectedIndex = 1; _searchController.clear(); _query = ''; }),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIndex == 1 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _selectedIndex == 1 ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      Text("Suka", style: TextStyle(fontSize: 10, color: _selectedIndex == 1 ? Colors.red : Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFavTab) ...[
                  Text(
                    _greeting,
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, 
                      color: headerTextColor 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mau masak apa hari ini?", 
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.white70, fontSize: 14) 
                  ),
                  const SizedBox(height: 20),
                ],

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white, 
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: isFavTab ? 'Cari di favorit...' : 'Cari resep...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => setState(() { _searchController.clear(); _query = ''; }),
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, prov, _) {
                if (prov.listStatus == Status.loading) {
                  return Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: 6,
                      itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                    ),
                  );
                }

                if (prov.listStatus == Status.error) {
                  return Center(child: Text('Error: ${prov.errorMessage}'));
                }

                final items = prov.recipes.where((r) {
                  final q = _query;
                  final matchesSearch = r.title.toLowerCase().contains(q) || r.category.toLowerCase().contains(q);
                  final matchesFav = isFavTab ? prov.isFavorite(r.id) : true;
                  return matchesSearch && matchesFav;
                }).toList();

                if (items.isEmpty) {
                  String title = 'Belum ada resep';
                  String message = 'Yuk, buat resep pertamamu!';
                  IconData icon = Icons.menu_book_rounded;

                  if (_query.isNotEmpty) {
                    title = 'Yah, gak ketemu...'; message = 'Coba kata kunci lain'; icon = Icons.search_off_rounded;
                  } else if (isFavTab) {
                    title = 'Belum ada favorit'; message = 'Tandai resep yang disukai'; icon = Icons.favorite_border_rounded;
                  }

                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.grey[800] : Colors.teal.withOpacity(0.1)),
                            child: Icon(icon, size: 80, color: isDark ? Colors.grey[600] : (isFavTab ? Colors.redAccent : Colors.teal[300])),
                          ),
                          const SizedBox(height: 20),
                          Text(title, style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(message, style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: prov.loadRecipes,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: items.length,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemBuilder: (context, i) {
                      final r = items[i];
                      return RecipeCard(
                        recipe: r,
                        onTap: () async {
                          await Prefs.setLastViewedRecipeId(r.id);
                          if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recipeId: r.id)));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}