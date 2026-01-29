/// Монгол төгрөгийн formatting utilities
class CurrencyFormatter {
  /// Format integer to currency string: 2500 → "₮2,500"
  static String format(int amount) {
    final str = amount.toString();
    final formatted = str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '₮$formatted';
  }

  /// Format with symbol at end: 2500 → "2,500₮"
  static String formatWithSymbolAtEnd(int amount) {
    final str = amount.toString();
    final formatted = str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formatted₮';
  }

  /// Format without symbol: 2500 → "2,500"
  static String formatWithoutSymbol(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Parse user input: "2500" or "2,500" → 2500
  static int parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}
