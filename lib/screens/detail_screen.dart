import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resep/providers/recipe_provider.dart';
import 'package:my_resep/screens/form_screen.dart';

class DetailScreen extends StatefulWidget {
  final String recipeId;
  const DetailScreen({super.key, required this.recipeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isInit = true;

  final Set<int> _doneIngredients = {}; 
  final Set<int> _doneSteps = {};       

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<RecipeProvider>(context, listen: false).loadDetail(widget.recipeId);
      _isInit = false;
    }
  }

  Widget _buildDetailPlaceholder() {
    return Container(
      color: Colors.grey.shade300, 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade500),
            const SizedBox(height: 8),
            Text("Tidak ada gambar", style: TextStyle(color: Colors.grey.shade600))
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah': return Colors.green;
      case 'sedang': return Colors.orange;
      case 'sulit': return Colors.red;
      default: return Colors.teal;
    }
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Resep?'),
        content: const Text('Resep ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final nav = Navigator.of(context);
      final success = await Provider.of<RecipeProvider>(context, listen: false)
          .deleteRecipe(widget.recipeId);
      
      if (success && mounted) {
        nav.pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil dihapus'), backgroundColor: Colors.teal),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<RecipeProvider>(context);
    final r = prov.selectedRecipe;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0B) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    if (prov.detailStatus == Status.loading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator(color: Colors.teal)));
    }

    if (prov.detailStatus == Status.error || r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Resep')),
        body: Center(child: Text('Gagal memuat: ${prov.errorMessage}')),
      );
    }
    
    final isFav = prov.isFavorite(r.id);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26, 
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    color: isFav ? Colors.red : Colors.white,
                    onPressed: () {
                      prov.toggleFavorite(r.id);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFav ? 'Dihapus dari favorit' : 'Masuk ke favorit'),
                          backgroundColor: Colors.teal,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit Resep')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                    ],
                    onSelected: (val) async {
                      if (val == 'edit') {
                        final updated = await Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => FormScreen(recipe: r))
                        );
                        if (updated == true && mounted) {
                          prov.loadDetail(r.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Resep berhasil diperbarui!'),
                              backgroundColor: Colors.teal,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else if (val == 'delete') {
                        _deleteRecipe(context);
                      }
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  r.thumbnail.isNotEmpty 
                    ? Image.network(
                        r.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => _buildDetailPlaceholder(),
                      )
                    : _buildDetailPlaceholder(),
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor, 
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), 
                ),
                child: Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[300], 
                      borderRadius: BorderRadius.circular(2)
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50, 
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            r.category.toUpperCase(), 
                            style: TextStyle(
                              color: isDark ? Colors.tealAccent : Colors.teal.shade700, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 10
                            )
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.location_on, size: 14, color: subTextColor),
                        Text(" ${r.area}", style: TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      r.title,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Oleh: ${(r.author.isEmpty || r.author == 'Anonymous') ? 'Chef myCooking' : r.author}", 
                      style: TextStyle(color: subTextColor, fontSize: 14)
                    ),
                    
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoItem(Icons.access_time_rounded, r.cookTime, "Waktu", textColor, subTextColor),
                          _verticalDivider(isDark),
                          _infoItem(Icons.room_service_outlined, "${r.servings} Porsi", "Sajian", textColor, subTextColor),
                          _verticalDivider(isDark),
                          _infoItem(Icons.bar_chart_rounded, r.difficulty.isEmpty ? 'Mudah' : r.difficulty, "Level", 
                          textColor, subTextColor, colorOverride: _getDifficultyColor(r.difficulty)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    _sectionTitle("Bahan-bahan", textColor),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: r.ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = r.ingredients[index];
                        final qty = ing['quantity']?.toString() ?? '';
                        final isDone = _doneIngredients.contains(index);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDone ? (isDark ? Colors.grey[800] : Colors.grey[50]) : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDone ? Colors.transparent : (isDark ? Colors.grey[800]! : Colors.grey.shade200)),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            activeColor: Colors.teal,
                            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            title: Text(
                              '${ing['name']}${qty.isNotEmpty ? " ($qty)" : ""}',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? Colors.grey : textColor,
                              ),
                            ),
                            value: isDone,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) _doneIngredients.add(index);
                                else _doneIngredients.remove(index);
                              });
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    _sectionTitle("Cara Memasak", textColor),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: r.instructions.split('\n').length,
                      itemBuilder: (context, index) {
                        final step = r.instructions.split('\n')[index];
                        if (step.trim().isEmpty) return const SizedBox.shrink();
                        
                        final isDone = _doneSteps.contains(index);
                        final stepNumber = index + 1;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isDone) _doneSteps.remove(index);
                              else _doneSteps.add(index);
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 30, height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDone ? Colors.teal : cardColor,
                                      border: Border.all(color: Colors.teal, width: 2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isDone 
                                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                                      : Text('$stepNumber', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                  ),
                                  if (index != r.instructions.split('\n').length - 1)
                                    Container(width: 2, height: 40, color: isDark ? Colors.grey[800] : Colors.grey.shade200, margin: const EdgeInsets.symmetric(vertical: 4)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24, top: 2),
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 16, height: 1.5,
                                      color: isDone ? Colors.grey : textColor,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, String label, Color textColor, Color? subTextColor, {Color? colorOverride}) {
    return Column(
      children: [
        Icon(icon, color: colorOverride ?? Colors.teal, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _verticalDivider(bool isDark) {
    return Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey.shade200);
  }
}