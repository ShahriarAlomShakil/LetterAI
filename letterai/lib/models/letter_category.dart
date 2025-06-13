class LetterCategory {
  final String id;
  final String name;
  final String icon;
  final List<LetterSubcategory> subcategories;
  
  const LetterCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}

class LetterSubcategory {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  
  const LetterSubcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
  });
}
