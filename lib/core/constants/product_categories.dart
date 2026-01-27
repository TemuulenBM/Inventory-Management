/// Барааны категориудын тогтмол жагсаалт
///
/// Product Form болон Products List screen дээр consistency хангахын тулд
/// энэ файлыг ашиглана.
class ProductCategories {
  ProductCategories._(); // Private constructor - instance үүсгэхгүй

  /// Үндсэн категориудын жагсаалт
  static const List<String> values = [
    'Хувцас',
    'Хүнс',
    'Ундаа',
    'Гэр ахуй',
    'Бусад',
  ];

  /// Default категори
  static const String defaultCategory = 'Хувцас';

  /// Категори validate хийх
  static bool isValid(String? category) {
    if (category == null) return false;
    return values.contains(category);
  }

  /// Категори normalize хийх (case-insensitive)
  static String? normalize(String? category) {
    if (category == null) return null;

    final lowercased = category.toLowerCase();
    for (final validCategory in values) {
      if (validCategory.toLowerCase() == lowercased) {
        return validCategory;
      }
    }

    return category; // Олдохгүй бол оригиналыг буцаах
  }
}
