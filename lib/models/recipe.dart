class Recipe {
  final String id;
  final String title;
  final String thumbnail;
  final String instructions;
  final List<Map<String, dynamic>> ingredients;
  final String cookTime;
  final int servings;
  final String category;
  final String area;
  final String author;
  final String difficulty;

  Recipe({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.instructions,
    required this.ingredients,
    required this.cookTime,
    required this.servings,
    required this.category,
    required this.area,
    required this.author,
    required this.difficulty,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedIngredients = [];

    if (json['ingredients'] is List) {
      parsedIngredients = (json['ingredients'] as List).map((e) {
        if (e is Map) {
          return {
            'name': e['name']?.toString() ?? '',
            'quantity': e['quantity']?.toString() ?? ''
          };
        } else {
          return {
            'name': e.toString(),
            'quantity': '-'
          };
        }
      }).toList();
    }

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      thumbnail: json['thumbnail']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      ingredients: parsedIngredients,
      cookTime: json['cookTime']?.toString() ?? '15 mnt',
      servings: int.tryParse(json['servings']?.toString() ?? '1') ?? 1,
      category: json['category']?.toString() ?? 'Lainnya',
      area: json['area']?.toString() ?? '-',
      author: json['author']?.toString() ?? 'Chef myCooking', 
      difficulty: json['difficulty']?.toString() ?? 'Mudah',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'instructions': instructions,
      'ingredients': ingredients,
      'cookTime': cookTime,
      'servings': servings,
      'category': category,
      'area': area,
      'author': author, 
      'difficulty': difficulty,
    };
  }
}