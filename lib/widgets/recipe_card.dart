import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resep/models/recipe.dart';
import 'package:my_resep/providers/recipe_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200, 
      child: Center(
        child: Icon(
          Icons.restaurant, 
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand, 
                children: [
                  recipe.thumbnail.isEmpty
                      ? _buildPlaceholder() 
                      : recipe.thumbnail.startsWith('http')
                          ? Image.network(
                              recipe.thumbnail,
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(), 
                            )
                          : Image.file(
                              File(recipe.thumbnail),
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(), 
                            ),
                  
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<RecipeProvider>( 
                      builder: (context, prov, child) {
                        final isFav = prov.isFavorite(recipe.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                            ]
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                prov.toggleFavorite(recipe.id);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFav ? 'Dihapus dari favorit' : 'Masuk ke favorit'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.teal,
                                    behavior: SnackBarBehavior.floating, 
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.teal[400]),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cookTime, 
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}